import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:openapi/openapi.dart';
import 'package:web3_smartwatch_sdk/src/interface.dart';
import 'package:web3_smartwatch_sdk/src/web3_smartwatch_sdk.dart';
import 'package:web3dart/web3dart.dart' show EthPrivateKey;

@GenerateNiceMocks([
  MockSpec<FlutterSecureStorage>(),
  MockSpec<Openapi>(),
  MockSpec<UserApi>(),
  MockSpec<Web3SmartwatchSdk>(),
])
import 'web3_smartwatch_sdk_test.mocks.dart';

void main() {
  late MockFlutterSecureStorage mockStorage;
  late MockOpenapi mockOpenapi;
  late MockUserApi mockUserApi;
  late Web3SmartwatchSdk sdk;
  late MockWeb3SmartwatchSdk mockSdk;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    mockOpenapi = MockOpenapi();
    mockUserApi = MockUserApi();
    when(mockOpenapi.getUserApi()).thenReturn(mockUserApi);
    sdk = Web3SmartwatchSdk(secureStorage: mockStorage, rpcConfig: {
      '0x1': 'https://mainnet.infura.io/v3/YOUR_KEY',
      '0x5': 'https://goerli.infura.io/v3/YOUR_KEY',
    });
    mockSdk = MockWeb3SmartwatchSdk();
    when(mockSdk.getUserApi()).thenReturn(mockUserApi);
  });

  group('createWallet', () {
    test('should create a new wallet and store private key', () async {
      // Act
      final response = await sdk.createWallet();

      // Assert
      expect(response.address, isNotEmpty);
      expect(response.privateKey, isNotEmpty);
      expect(response.mnemonic, isNotEmpty);
      // Verify storage calls
      verify(mockStorage.write(
        key: 'private_key_${response.address}',
        value: response.privateKey,
      )).called(1);
      verify(mockStorage.write(
        key: 'current_wallet_address',
        value: response.address,
      )).called(1);
    });

    test('should create wallet with provided DID', () async {
      // Arrange
      const testDid = 'test:did:123';

      // Act
      final response = await sdk.createWallet(did: testDid);

      // Assert
      expect(response.did, equals(testDid));
    });
  });

  group('getWallet', () {
    test('should return null when no current wallet address exists', () async {
      // Arrange
      when(mockStorage.read(key: 'current_wallet_address'))
          .thenAnswer((_) async => null);

      // Act
      final wallet = await sdk.getWallet();

      // Assert
      expect(wallet, isNull);
    });

    test('should return null when private key not found', () async {
      // Arrange
      const testAddress = '0x123';
      when(mockStorage.read(key: 'current_wallet_address'))
          .thenAnswer((_) async => testAddress);
      when(mockStorage.read(key: 'private_key_$testAddress'))
          .thenAnswer((_) async => null);

      // Act
      final wallet = await sdk.getWallet();

      // Assert
      expect(wallet, isNull);
    });

    test('should return wallet when storage has valid data', () async {
      // Arrange
      // Using a known private key for consistent testing
      const privateKey =
          'bab8b70797cefb5ddab9c28aa467a7aaa48e3d39432d2fe058fd63e12e09e316';
      final ethPrivateKey = EthPrivateKey.fromHex(privateKey);
      final address = ethPrivateKey.address.hex;

      when(mockStorage.read(key: 'current_wallet_address'))
          .thenAnswer((_) async => address);
      when(mockStorage.read(key: 'private_key_$address'))
          .thenAnswer((_) async => privateKey);

      // Act
      final wallet = await sdk.getWallet();

      // Assert
      expect(wallet, isNotNull);
      expect(wallet!.address.toLowerCase(), equals(address.toLowerCase()));
      expect(wallet.privateKey, equals(privateKey));
    });
  });

  group('WalletImpl', () {
    late Wallet wallet;
    const testAddress = '0xf88a54f6cbb126891a997bf0a8255d17d53c8046';
    const testPrivateKey =
        'bab8b70797cefb5ddab9c28aa467a7aaa48e3d39432d2fe058fd63e12e09e316';

    setUp(() async {
      // Create a wallet with known values
      final ethPrivateKey = EthPrivateKey.fromHex(testPrivateKey);
      wallet = WalletImpl(
        address: testAddress,
        privateKey: testPrivateKey,
        did: '',
        mnemonic: '',
        ethPrivateKey: ethPrivateKey,
        getAddressBalance: mockSdk.getAddressBalance,
        getAddressBalanceByToken: mockSdk.getAddressBalanceByToken,
      );
    });

    test('getBalanceByContractAddress should return token balance', () async {
      // Arrange
      const contractAddress = '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913';
      const balance = '1000';
      const decimals = '18';

      // Mock the SDK method
      when(mockSdk.getAddressBalanceByToken(testAddress, contractAddress))
          .thenAnswer(
              (_) async => Balance(balance: balance, decimals: decimals));

      // Act
      final result = await wallet.getBalanceByContractAddress(contractAddress);

      // Assert
      expect(result?.balance, equals(balance));
      expect(result?.decimals, equals(decimals));
      verify(mockSdk.getAddressBalanceByToken(testAddress, contractAddress))
          .called(1);
    });

    test('signMessage and verifyMessage should work correctly', () async {
      // Arrange
      const message = 'Hello, World!';
      // Act
      final signature = await wallet.signMessage(message);
      final isValid =
          await wallet.verifyMessage(message: message, signature: signature);

      // Assert
      expect(signature, isNotEmpty);
      expect(isValid, isTrue);
    });

    test('verifyMessage should return false for invalid signature', () async {
      // Arrange
      const message = 'Hello, World!';
      const invalidSignature = '0x123456';

      // Act
      final isValid = await wallet.verifyMessage(
          message: message, signature: invalidSignature);

      // Assert
      expect(isValid, isFalse);
    });
  });

  group('WalletMethods', () {
    late Wallet wallet;
    const testAddress = '0x742d35Cc6634C0532925a3b844Bc454e4438f44e';
    const testPrivateKey =
        'bab8b70797cefb5ddab9c28aa467a7aaa48e3d39432d2fe058fd63e12e09e316';

    setUp(() async {
      // Create a wallet with known values
      final ethPrivateKey = EthPrivateKey.fromHex(testPrivateKey);
      wallet = WalletImpl(
        address: testAddress,
        privateKey: testPrivateKey,
        did: '',
        mnemonic: '',
        ethPrivateKey: ethPrivateKey,
        getAddressBalance: mockSdk.getAddressBalance,
        getAddressBalanceByToken: mockSdk.getAddressBalanceByToken,
      );
    });

    test('getBalanceByContractAddress should return token balance', () async {
      // Arrange
      const contractAddress = '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913';
      const balance = '1000';
      const decimals = '18';

      // Mock the SDK method
      when(mockSdk.getAddressBalanceByToken(testAddress, contractAddress))
          .thenAnswer(
              (_) async => Balance(balance: balance, decimals: decimals));

      // Act
      final result = await wallet.getBalanceByContractAddress(contractAddress);

      // Assert
      expect(result?.balance, equals(balance));
      expect(result?.decimals, equals(decimals));
      verify(mockSdk.getAddressBalanceByToken(testAddress, contractAddress))
          .called(1);
    });
  });
}
