import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:web3_smartwatch_sdk/src/web3_smartwatch_sdk.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<FlutterSecureStorage>(),
])
import 'web3_smartwatch_api_test.mocks.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late Web3SmartwatchSdk sdk;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    dio = Dio();
    dioAdapter = DioAdapter(dio: dio);
    mockStorage = MockFlutterSecureStorage();
    sdk = Web3SmartwatchSdk(
      dio: dio,
      secureStorage: mockStorage,
      rpcConfig: {
        '0x1': 'https://mainnet.infura.io/v3/YOUR_KEY',
        '0x5': 'https://goerli.infura.io/v3/YOUR_KEY',
      },
    );

    // Setup the current wallet for tests
    const testAddress = '0x742d35Cc6634C0532925a3b844Bc454e4438f44e';
    when(mockStorage.read(key: 'current_wallet_address'))
        .thenAnswer((_) async => testAddress);
  });

  group('Real API test with mock responses', () {
    const testAddress = '0x742d35Cc6634C0532925a3b844Bc454e4438f44e';

    test('getAddressBalanceByToken should return token balance', () async {
      // Mock the API response for token balance
      final mockResponse = {
        'address': testAddress,
        'tokens': [
          {
            'address': '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913',
            'balance': '5109420000',
            'balanceUsd': '5.1098800936437622513',
            'decimals': 6,
            'name': 'USD Coin',
            'symbol': 'USDC',
            'tokenPrice': '1.0000900481157865768',
            'type': 'ERC20'
          },
          {
            'address': '0xBe90D5238Ba6dcDC60fe8B845854128fd200f4A2',
            'balance': '100000000000000000000000',
            'balanceUsd': '7.147410934922441311141',
            'decimals': 18,
            'name': 'Berachain',
            'symbol': 'BERA',
            'tokenPrice': '0.000071474109349224413113',
            'type': 'ERC20'
          }
        ],
        'nextPageToken': null,
        'nextPageUrl': null,
      };

      // Setup mock response for the balance endpoint
      dioAdapter.onGet(
        '/api/user/$testAddress/balance',
        (request) => request.reply(200, mockResponse),
      );

      // Test getting balance for USDC
      final usdcAddress = '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913';
      final usdcBalance =
          await sdk.getAddressBalanceByToken(testAddress, usdcAddress);

      // Verify results
      expect(usdcBalance, isNotNull);
      expect(usdcBalance?.balance, equals('5109420000'));
      expect(usdcBalance?.decimals, equals('6'));

      // Test getting balance for BERA
      final beraAddress = '0xBe90D5238Ba6dcDC60fe8B845854128fd200f4A2';
      final beraBalance =
          await sdk.getAddressBalanceByToken(testAddress, beraAddress);

      // Verify results
      expect(beraBalance, isNotNull);
      expect(beraBalance?.balance, equals('100000000000000000000000'));
      expect(beraBalance?.decimals, equals('18'));
    });

    test('getAddressBalanceByToken should return null for non-existent token',
        () async {
      // Mock the API response for token balance
      final mockResponse = {
        'address': testAddress,
        'tokens': [
          {
            'address': '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913',
            'balance': '5109420000',
            'balanceUsd': '5.1098800936437622513',
            'decimals': 6,
            'name': 'USD Coin',
            'symbol': 'USDC',
            'tokenPrice': '1.0000900481157865768',
            'type': 'ERC20'
          }
        ],
        'nextPageToken': null,
        'nextPageUrl': null,
      };

      // Setup mock response
      dioAdapter.onGet(
        '/api/user/$testAddress/balance',
        (request) => request.reply(200, mockResponse),
      );

      // Test getting balance for non-existent token
      final nonExistentAddress = '0x0000000000000000000000000000000000000000';
      final balance =
          await sdk.getAddressBalanceByToken(testAddress, nonExistentAddress);

      // Verify results
      expect(balance, isNull);
    });

    test('getAddressBalanceByToken should handle API errors', () async {
      // Setup mock error response
      dioAdapter.onGet(
        '/api/user/$testAddress/balance',
        (request) => request.throws(
          500,
          DioException(
            requestOptions:
                RequestOptions(path: '/api/user/$testAddress/balance'),
            error: 'Internal Server Error',
            type: DioExceptionType.badResponse,
          ),
        ),
      );

      // Test error handling
      final contractAddress = '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913';

      // Expect the method to rethrow the error
      expect(
        () => sdk.getAddressBalanceByToken(testAddress, contractAddress),
        throwsA(isA<DioException>()),
      );
    });
  });
}
