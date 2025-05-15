import 'dart:typed_data';
import 'package:web3dart/web3dart.dart' show Transaction;

class CreateWalletResponse {
  /// The address of the wallet
  final String address;

  /// The private key of the wallet
  final String privateKey;

  /// The did of the wallet
  final String did;

  /// The mnemonic of the wallet
  final String mnemonic;

  CreateWalletResponse({
    required this.address,
    required this.privateKey,
    required this.did,
    required this.mnemonic,
  });
}

class Balance {
  final String balance;
  final String decimals;

  Balance({
    required this.balance,
    required this.decimals,
  });
}

abstract class Wallet {
  final String address;
  final String privateKey;
  final String did;
  final String mnemonic;

  Wallet({
    required this.address,
    required this.privateKey,
    required this.did,
    required this.mnemonic,
  });

  Future<Balance> getBalance();

  /// Returns the balance of the token by the contract address.
  /// For example, if you want to get the balance of USDC, you can use `getBalanceByContractAddress('USDC Contract Address')`.
  /// Or an NFT's balance, you can use `getBalanceByContractAddress('NFT Contract Address')`.
  Future<Balance?> getBalanceByContractAddress(String contractAddress);

  /// Signs a message with the private key of the wallet.
  /// This is used for signing messages to verify the ownership of the wallet.
  Future<String> signMessage(String message);

  /// Verifies a message with the signature.
  /// Message is the original message that was signed.
  /// Signature is the signature that was returned from the `signMessage` function.
  /// Returns true if the signature is valid, otherwise returns false.
  Future<bool> verifyMessage({
    required String message,
    required String signature,
  });

  Future<Uint8List> signTransaction(Transaction tx, String chainId);
}

class PaginatedResult<T> {
  /// Data of the page
  final List<T> data;

  /// Page number
  final int page;

  /// Size of the page
  final int pageSize;

  /// Total number of pages
  final int totalPages;

  /// Total number of items
  final int total;

  PaginatedResult({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.total,
  });
}

abstract class NFTAsset {
  /// The name of the NFT asset
  final String name;

  /// The description of the NFT asset
  final String description;

  /// The static resource link of the NFT asset
  final String dataLink;

  /// The token id of the NFT asset
  final String tokenId;

  /// The amount of the NFT asset if the NFT is using ERC1155
  /// otherwise it is null. This is not the balance of the NFT asset.
  final int? amount;

  /// The metadata of the NFT asset
  final Map<String, dynamic> metadata;

  /// The contract address of the NFT asset
  final String contractAddress;

  NFTAsset({
    required this.name,
    required this.description,
    required this.dataLink,
    required this.tokenId,
    required this.amount,
    required this.metadata,
    required this.contractAddress,
  });

  Future<Balance> getBalance(Wallet wallet);
}

class DidRegistrationResponse {
  final String registerAddress;
  final String did;

  DidRegistrationResponse({required this.registerAddress, required this.did});
}

abstract class TokenAsset {
  /// The name of the token, for example, USDC
  final String name;

  /// The symbol of the token, for example, USDC
  final String symbol;

  /// The contract address of the token
  final String contractAddress;

  /// The decimals of the token. For example, USDC has 6 decimals.
  final String decimals;

  /// The description of the token
  final String? description;

  TokenAsset({
    required this.name,
    required this.symbol,
    required this.contractAddress,
    required this.decimals,
    required this.description,
  });

  /// Returns the balance of the token in the original unit.
  /// For example, USDC has 6 decimals.
  /// If the balance is `1,000,000`, it will return `1.000000`.
  /// You can use the `format` function to format `1,000,000` to `1.000000` and use `parse` to convert `1.000000` to `1,000,000`.
  Future<Balance> getBalance(Wallet wallet);
}

abstract class Web3SmartwatchInterface {
  /// Creates a new wallet and returns the address, private key, did, and mnemonic.
  /// If did is provided, it will be used to create the wallet.
  Future<CreateWalletResponse> createWallet({
    String? did,
  });

  /// Returns the wallet info if the wallet is created, otherwise returns null.
  /// Notice this may throw an error if the wallet unlocking fails.
  Future<Wallet?> getWallet();
}
