# Web3 Smartwatch SDK Example Documentation

### 1.SDK Initialization

```dart
import 'package:web3_smartwatch_sdk/web3_smartwatch_sdk.dart';

void main() async {
    // Initialize the SDK
    final sdk = Web3SmartwatchSdk();
    // write your codes
}


```
### 2.Wallet Creation & Retrieval

```dart
try {
    // Create a new wallet
    print('Creating a new wallet...');
    final createWalletResponse = await sdk.createWallet();
    print('Wallet created with address: ${createWalletResponse.address}');  
    // Get the wallet instance
    final wallet = await sdk.getWallet();
    if (wallet == null) {
        print('Failed to get wallet');
        return;
    }   
} catch (e) {
    print('Error: $e');
}
```


### 3.Token Balance Query

```dart
// Example 2: Get balance of a specific token
print('\nExample 2: Getting balance of a specific token...');
const usdtContractAddress = '0xdAC17F958D2ee523a2206206994597C13D831ec7'; // USDT on Ethereum
try {
    print('Fetching USDT balance (may take a moment if token is in later pages)...');
    final tokenBalance = await     wallet.getBalanceByContractAddress(usdtContractAddress);
    if (tokenBalance != null) {
        print('USDT Balance: ${tokenBalance.balance} (decimals: ${tokenBalance.decimals})');
    } else {
    print('No balance found for USDT (token might not exist in wallet)');
    }
} catch (e) {
   print('Error getting USDT balance: $e');
}
```

### 4.Multiple tokens

```dart
// Example 3: Get balance of multiple tokens (with error handling)
print('\nExample 3: Getting balances of multiple tokens...');
final tokenAddresses = [
    '0xdAC17F958D2ee523a2206206994597C13D831ec7', // USDT
    '0x0000000000000000000000000000000000000000', // Native token
];

for (final tokenAddress in tokenAddresses) {
    try {
        print('\nFetching balance for $tokenAddress...');
        final tokenBalance = await wallet.getBalanceByContractAddress(tokenAddress);
        if (tokenBalance != null) {
            print('Token ($tokenAddress)');
            print('  Balance: ${tokenBalance.balance}');
            print('  Decimals: ${tokenBalance.decimals}');
        } else {
            print('No balance found for token: $tokenAddress');
            print('(Token might not exist in wallet or might be on a different network)');
        }
    } catch (e) {
        print('Error getting balance for token $tokenAddress:');
        print('  Error details: $e');
        print('  Continuing with next token...');
    }
}
```


### 6.Message Signing & Verification

```dart
// Example 5: Sign a message and verify it
print('\nExample 5: Message signing and verification...');
const message = 'Hello Web3 Smartwatch!';
try {
    final signature = await wallet.signMessage(message);
    print('Message signed. Signature: $signature');

    final isValid = await wallet.verifyMessage(message: message, signature: signature);
    print('Signature verification: ${isValid ? 'Valid' : 'Invalid'}');
} catch (e) {
    print('Error during message signing/verification: $e');
}


```
