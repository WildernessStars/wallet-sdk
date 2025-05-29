import 'package:dio/dio.dart' show DioException, DioExceptionType, Response;
import "package:hex/hex.dart";
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:openapi/openapi.dart';
import 'package:web3_smartwatch_sdk/src/interface.dart';
import 'package:web3_smartwatch_sdk/src/networkClient.dart';
import 'package:web3dart/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:retry/retry.dart';
import 'package:web3dart/web3dart.dart' show EthPrivateKey, Transaction,signTransactionRaw;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'provider1193.dart';


class WalletImpl extends Wallet {
  final EthPrivateKey _ethPrivateKey;
  final Future<Balance> Function(String address) _getAddressBalance;
  final Future<Balance?> Function(String address, String contractAddress)
      _getAddressBalanceByToken;

  WalletImpl({
    required super.address,
    required super.privateKey,
    required super.did,
    required super.mnemonic,
    required EthPrivateKey ethPrivateKey,
    required Future<Balance> Function(String address) getAddressBalance,
    required Future<Balance?> Function(String address, String contractAddress)
        getAddressBalanceByToken,
  })  : _ethPrivateKey = ethPrivateKey,
        _getAddressBalance = getAddressBalance,
        _getAddressBalanceByToken = getAddressBalanceByToken,
        super();
  @override
  Future<Balance> getBalance() => _getAddressBalance(address);

  @override
  Future<Balance?> getBalanceByContractAddress(String contractAddress) =>
      _getAddressBalanceByToken(address, contractAddress);

  @override
  Future<String> signMessage(String message) async {
    final messageBytes = utf8.encode(message);
    final signature =
        _ethPrivateKey.signToUint8List(messageBytes, isEIP1559: false);
    return HEX.encode(signature);
  }

  @override
  Future<bool> verifyMessage(
      {required String message, required String signature}) async {
    try {
      final messageBytes = utf8.encode(message);
      final messageHash = keccak256(messageBytes);
      final signatureBytes = hexToBytes(signature);
      if (signatureBytes.length != 65) return false;
      final Uint8List r = signatureBytes.sublist(0, 32);
      final Uint8List s = signatureBytes.sublist(32, 64);
      int v = signatureBytes[64];
      if (v != 27 && v != 28) {
        return false;
      }
      final msgSignature =
          MsgSignature(bytesToUnsignedInt(r), bytesToUnsignedInt(s), v);
      final publicKey = _ethPrivateKey.publicKey;
      // remove the leading 04
      final publicKeyBytes = publicKey.getEncoded(false).sublist(1);
      final isValid =
          isValidSignature(messageHash, msgSignature, publicKeyBytes);
      return isValid;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Uint8List> signTransaction(Transaction tx, String chainId) async {
    final signedTx = signTransactionRaw(tx, _ethPrivateKey, chainId: int.parse(chainId));
    return signedTx;
  }
  
}

class Web3SmartwatchSdk extends Openapi implements Web3SmartwatchInterface {
  Wallet? _cachedWallet;
  String? _currentWalletAddress;
  late final EIP1193Provider? _provider;
  final FlutterSecureStorage _secureStorage;
  final RetryOptions _retryOptions;

  Web3SmartwatchSdk({
    FlutterSecureStorage? secureStorage,
    super.basePathOverride,
    super.dio,
    required Map<String, String> rpcConfig,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _retryOptions = RetryOptions(// retry options for api calls
          delayFactor: Duration(seconds: 1),
          maxDelay: Duration(seconds: 10),
          maxAttempts: 5,
          randomizationFactor: 0.25,
        ), 
        _provider = EIP1193Provider( // provider for web3
          providerResolver: (chainId) => RPCManager().getProvider(chainId),
        ) {
          RPCManager().initialize(rpcConfig);
        }

  Future<String?> _loadPrivateKey(String address) async {
    final encryptedData =
        await _secureStorage.read(key: 'private_key_$address');
    if (encryptedData == null) return null;

    return encryptedData;
  }

  void setCurrentWalletAddress(String address) {
    _currentWalletAddress = address;
  }

  // isRetriable is a helper function to determine if an exception is retriable
  Future<bool> _isRetriable(Exception e) async {
    if (e is! DioException) return false;
    if ([
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
      DioExceptionType.unknown
    ].contains(e.type)) {
      return true;
    }

    if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      if (statusCode == null) return false;

      if (statusCode >= 500 && statusCode < 600) return true;

      if (statusCode == 429) {
        final retryAfter = e.response?.headers.value('Retry-After');
        if (retryAfter != null) {
          final seconds =
              int.tryParse(retryAfter) ?? 60; // default to 60 seconds
          await Future.delayed(Duration(seconds: seconds));
          return true;
        }
      }
    }
    return false;
  }

  // Try to find the token in current page
  Balance? _getTokenBalanceFromResponse(
      Response<ApiUserAddressBalanceGet200Response> response,
      String contractAddress) {
    final tokens = response.data?.tokens;
    if (tokens == null) return null;

    for (final token in tokens) {
      try {
        if (token.address.toLowerCase() == contractAddress.toLowerCase()) {
          return Balance(
            balance: token.balance ?? '0',
            decimals: token.decimals?.toString() ?? '18',
          );
        }
      } catch (e) {
        throw Exception('Invalid token format: $e');
      }
    }
    return null;
  }

  /// Get balance for an address (internal method used by WalletImpl)
  Future<Balance> getAddressBalance(String address) async {
    return Balance(balance: "0", decimals: "18");
  }

  /// Get token balance for an address (internal method used by WalletImpl)
  Future<Balance?> getAddressBalanceByToken(
      String address, String contractAddress) async {
    String? nextPageToken;
    try {
      do {
        final response = await _retryOptions.retry(
          () => getUserApi().apiUserAddressBalanceGet(
            address: address,
            pageToken: nextPageToken,
          ),
          retryIf: (e) => _isRetriable(e),
        );
        try {
          final balance =
              _getTokenBalanceFromResponse(response, contractAddress);
          if (balance != null) return balance;
        } catch (e) {
          print('Error processing token: $e');
        }
        nextPageToken = response.data?.nextPageToken;
      } while (nextPageToken?.isNotEmpty ?? false);
      return null;
    } catch (e) {
      print('Error in getAddressBalanceByToken: $e');
      rethrow;
    }
  }

  @override
  Future<CreateWalletResponse> createWallet({String? did}) async {
    final String mnemonic = bip39.generateMnemonic();
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    final path = "m/44'/60'/0'/0/0";
    final childKey = root.derivePath(path);
    final privateKeyBytes = childKey.privateKey!;
    final privateKeyHex = HEX.encode(privateKeyBytes);
    final ethPrivateKey = EthPrivateKey.fromHex(privateKeyHex);
    final address = ethPrivateKey.address.hex;

    await _secureStorage.write(
        key: 'private_key_$address', value: privateKeyHex);
    await _secureStorage.write(key: 'current_wallet_address', value: address);

    return CreateWalletResponse(
      address: address,
      privateKey: privateKeyHex,
      did: did ?? "",
      mnemonic: mnemonic,
    );
  }

  @override
  Future<Wallet?> getWallet() async {
    if (_cachedWallet != null) return _cachedWallet;
    // First try to get the current wallet address from secure storage
    _currentWalletAddress ??=
        await _secureStorage.read(key: 'current_wallet_address');
    if (_currentWalletAddress == null) return null;

    final String? privateKey = await _loadPrivateKey(_currentWalletAddress!);
    if (privateKey == null) return null;

    final ethPrivateKey = EthPrivateKey.fromHex(privateKey);
    final String address = ethPrivateKey.address.hex;
    _cachedWallet = WalletImpl(
      address: address,
      privateKey: privateKey,
      did: "",
      mnemonic: "",
      ethPrivateKey: ethPrivateKey,
      getAddressBalance: getAddressBalance,
      getAddressBalanceByToken: getAddressBalanceByToken,
    );
    return _cachedWallet;
  }

  Future<EIP1193Provider> getProvider() async {
    final wallet = await getWallet();
    if (wallet == null) {
      throw Exception("Wallet not initialized");
    }
    _provider!.setWallet(wallet as WalletImpl);
    return _provider;
  }
}
