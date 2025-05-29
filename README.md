# Web3 Smartwatch SDK

A Flutter SDK for integrating Web3 wallet functionality into smartwatch applications. This SDK provides a bridge between your Flutter application and Web3 operations, making it easy to implement blockchain interactions in your smartwatch app.

## Features

- Wallet creation and management
- Token balance queries (native and ERC20 tokens)
- Message signing and verification
- Smart contract interactions
- EIP-1193 compliant provider implementation
- Secure authentication dialogs
- JavaScript bridge for Web3 operations

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  web3_smartwatch_sdk: ^1.0.0
```

## Quick Start

1. Initialize the SDK:
```dart
import 'package:web3_smartwatch_sdk/web3_smartwatch_sdk.dart';

void main() async {
    final sdk = Web3SmartwatchSdk();
    // Your code here
}
```

2. Create and manage wallets:
```dart
// Create a new wallet
final createWalletResponse = await sdk.createWallet();
print('Wallet created with address: ${createWalletResponse.address}');

// Get wallet instance
final wallet = await sdk.getWallet();
```

3. Query token balances:
```dart
// Get native token balance
final balance = await wallet.getBalance();

// Get ERC20 token balance
const tokenAddress = '0xdAC17F958D2ee523a2206206994597C13D831ec7'; // USDT
final tokenBalance = await wallet.getBalanceByContractAddress(tokenAddress);
```

4. Sign messages:
```dart
const message = 'Hello Web3 Smartwatch!';
final signature = await wallet.signMessage(message);
final isValid = await wallet.verifyMessage(message: message, signature: signature);
```

## Security

The SDK implements secure authentication dialogs for sensitive operations and provides a safe bridge between your Flutter application and Web3 operations.

## Documentation

For more detailed examples and API documentation, please check the `docs/examples.md` file.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
