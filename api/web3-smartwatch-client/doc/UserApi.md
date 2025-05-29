# openapi.api.UserApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiSearchAddressAddressGet**](UserApi.md#apisearchaddressaddressget) | **GET** /api/search/address/{address} | Get DID by wallet address
[**apiSearchDidDidGet**](UserApi.md#apisearchdiddidget) | **GET** /api/search/did/{did} | Get wallet address by DID
[**apiUserAddressBalanceGet**](UserApi.md#apiuseraddressbalanceget) | **GET** /api/user/{address}/balance | Get token balances
[**apiUserAddressGet**](UserApi.md#apiuseraddressget) | **GET** /api/user/{address} | Get user&#39;s token information
[**apiUserAddressNftsGet**](UserApi.md#apiuseraddressnftsget) | **GET** /api/user/{address}/nfts | Get user&#39;s NFT assets


# **apiSearchAddressAddressGet**
> ApiSearchAddressAddressGet200Response apiSearchAddressAddressGet(address)

Get DID by wallet address

Retrieves the associated DID for a given wallet address

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure API key authorization: ApiKeyAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('ApiKeyAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('ApiKeyAuth').apiKeyPrefix = 'Bearer';

final api = Openapi().getUserApi();
final String address = 0x742d35Cc6634C0532925a3b844Bc454e4438f44e; // String | Ethereum address of the user

try {
    final response = api.apiSearchAddressAddressGet(address);
    print(response);
} catch on DioException (e) {
    print('Exception when calling UserApi->apiSearchAddressAddressGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **address** | **String**| Ethereum address of the user | 

### Return type

[**ApiSearchAddressAddressGet200Response**](ApiSearchAddressAddressGet200Response.md)

### Authorization

[ApiKeyAuth](../README.md#ApiKeyAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiSearchDidDidGet**
> ApiSearchDidDidGet200Response apiSearchDidDidGet(did)

Get wallet address by DID

Retrieves the associated wallet address for a given DID

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure API key authorization: ApiKeyAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('ApiKeyAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('ApiKeyAuth').apiKeyPrefix = 'Bearer';

final api = Openapi().getUserApi();
final String did = did:example:123456789abcdefghi; // String | Decentralized Identifier (DID) of the user

try {
    final response = api.apiSearchDidDidGet(did);
    print(response);
} catch on DioException (e) {
    print('Exception when calling UserApi->apiSearchDidDidGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **did** | **String**| Decentralized Identifier (DID) of the user | 

### Return type

[**ApiSearchDidDidGet200Response**](ApiSearchDidDidGet200Response.md)

### Authorization

[ApiKeyAuth](../README.md#ApiKeyAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiUserAddressBalanceGet**
> ApiUserAddressBalanceGet200Response apiUserAddressBalanceGet(address, includeZeroBalance, pageToken)

Get token balances

Retrieves balances for all ERC20 tokens associated with the address. Balances are returned in the smallest unit of the token. Results are paginated with a default of 10 items per page. 

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure API key authorization: ApiKeyAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('ApiKeyAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('ApiKeyAuth').apiKeyPrefix = 'Bearer';

final api = Openapi().getUserApi();
final String address = 0x742d35Cc6634C0532925a3b844Bc454e4438f44e; // String | Ethereum address of the user
final bool includeZeroBalance = true; // bool | Include tokens with zero balance
final String pageToken = pageToken_example; // String | Token for pagination, obtained from nextPageToken in previous response

try {
    final response = api.apiUserAddressBalanceGet(address, includeZeroBalance, pageToken);
    print(response);
} catch on DioException (e) {
    print('Exception when calling UserApi->apiUserAddressBalanceGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **address** | **String**| Ethereum address of the user | 
 **includeZeroBalance** | **bool**| Include tokens with zero balance | [optional] [default to false]
 **pageToken** | **String**| Token for pagination, obtained from nextPageToken in previous response | [optional] 

### Return type

[**ApiUserAddressBalanceGet200Response**](ApiUserAddressBalanceGet200Response.md)

### Authorization

[ApiKeyAuth](../README.md#ApiKeyAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiUserAddressGet**
> ApiUserAddressGet200Response apiUserAddressGet(address, includeZeroBalance, pageToken)

Get user's token information

Retrieves all ERC20 tokens associated with a user's address, including  stablecoins like USDC and USDT. Returns token information without balances. Results are paginated with a default of 10 items per page. Use the GetBalance method from the token class to fetch actual balances. Note that balances are returned in the smallest unit (e.g., wei for ETH,  cents for USD-pegged tokens). 

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure API key authorization: ApiKeyAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('ApiKeyAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('ApiKeyAuth').apiKeyPrefix = 'Bearer';

final api = Openapi().getUserApi();
final String address = 0x742d35Cc6634C0532925a3b844Bc454e4438f44e; // String | Ethereum address of the user
final bool includeZeroBalance = true; // bool | Include tokens with zero balance
final String pageToken = pageToken_example; // String | Token for pagination, obtained from nextPageToken in previous response

try {
    final response = api.apiUserAddressGet(address, includeZeroBalance, pageToken);
    print(response);
} catch on DioException (e) {
    print('Exception when calling UserApi->apiUserAddressGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **address** | **String**| Ethereum address of the user | 
 **includeZeroBalance** | **bool**| Include tokens with zero balance | [optional] [default to false]
 **pageToken** | **String**| Token for pagination, obtained from nextPageToken in previous response | [optional] 

### Return type

[**ApiUserAddressGet200Response**](ApiUserAddressGet200Response.md)

### Authorization

[ApiKeyAuth](../README.md#ApiKeyAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiUserAddressNftsGet**
> ApiUserAddressNftsGet200Response apiUserAddressNftsGet(address, includeMetadata, pageToken)

Get user's NFT assets

Retrieves all NFT assets associated with a user's wallet address. Supports both ERC721 and ERC1155 tokens. Results are paginated and include a nextPageToken and nextPageUrl for fetching the next page. 

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure API key authorization: ApiKeyAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('ApiKeyAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('ApiKeyAuth').apiKeyPrefix = 'Bearer';

final api = Openapi().getUserApi();
final String address = 0x742d35Cc6634C0532925a3b844Bc454e4438f44e; // String | Ethereum address of the user
final bool includeMetadata = true; // bool | Whether to include metadata for NFTs
final String pageToken = pageToken_example; // String | Token for pagination, obtained from nextPageToken in previous response

try {
    final response = api.apiUserAddressNftsGet(address, includeMetadata, pageToken);
    print(response);
} catch on DioException (e) {
    print('Exception when calling UserApi->apiUserAddressNftsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **address** | **String**| Ethereum address of the user | 
 **includeMetadata** | **bool**| Whether to include metadata for NFTs | [optional] [default to true]
 **pageToken** | **String**| Token for pagination, obtained from nextPageToken in previous response | [optional] 

### Return type

[**ApiUserAddressNftsGet200Response**](ApiUserAddressNftsGet200Response.md)

### Authorization

[ApiKeyAuth](../README.md#ApiKeyAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

