import 'dart:convert';
import 'package:web3_smartwatch_sdk/web3_smartwatch_sdk.dart' show WalletImpl;
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

class ConnectionInfo {
  final String account;
  final String chainId;

  ConnectionInfo({required this.account, required this.chainId});

  factory ConnectionInfo.fromJson(Map<String, dynamic> json) {
    return ConnectionInfo(
      account: json['account'],
      chainId: json['chainId'],
    );
  }
}

class RPCManager {
  static final RPCManager _instance = RPCManager._internal();
  factory RPCManager() => _instance;
  RPCManager._internal();

  final Map<String, String> _rpcEndpoints = {
    '0x1': 'https://mainnet.infura.io/v3/YOUR_KEY',
    '0x5': 'https://goerli.infura.io/v3/YOUR_KEY',
  };

  // cache created providers
  final Map<String, Web3Client> _providerCache = {};

  /// add or update rpc config
  void updateRpcConfig(String chainId, String url) {
    _rpcEndpoints[chainId] = url;
    _providerCache.remove(chainId); 
  }

  /// get provider
  Web3Client getProvider(String chainId, {bool forceNew = false}) {
    if (!_rpcEndpoints.containsKey(chainId)) {
      throw ArgumentError('Unsupported chainId: $chainId');
    }

    // use cache to avoid duplicate creation
    if (!forceNew && _providerCache.containsKey(chainId)) {
      return _providerCache[chainId]!;
    }

    final client = Web3Client(
      _rpcEndpoints[chainId]!,
      http.Client(),
    );
    return _providerCache[chainId] = client;
  }
}



class EIP1193Provider {
  WalletImpl? _wallet;
  String _chainId = '0x1';

  setWallet(WalletImpl wallet) {
    _wallet = wallet;
  }

  Future<void> switchChain(String chainId) async {
    _chainId = chainId;
  }

  Future<List<dynamic>> connect({String chainId = '0x1'}) async {
    if (_wallet != null) {
      return [_wallet!.address, _chainId];
    }
    return [];
  }

  Future<String> sendTransaction(Transaction tx) async {
    if (_wallet != null) {
        final signedTx = await _wallet!.signTransaction(tx, _chainId);
        final provider = RPCManager().getProvider(_chainId);
        return provider.sendRawTransaction(signedTx);
      }
    return "";
  }

  Future<String> signMessage(String message) async {
    if (_wallet != null) {
      return _wallet!.signMessage(message);
    }
      return "";
  }

  
}
