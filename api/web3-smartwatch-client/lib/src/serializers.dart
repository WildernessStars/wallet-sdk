//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:openapi/src/date_serializer.dart';
import 'package:openapi/src/model/date.dart';

import 'package:openapi/src/model/api_search_address_address_get200_response.dart';
import 'package:openapi/src/model/api_search_did_did_get200_response.dart';
import 'package:openapi/src/model/api_user_address_balance_get200_response.dart';
import 'package:openapi/src/model/api_user_address_get200_response.dart';
import 'package:openapi/src/model/api_user_address_nfts_get200_response.dart';
import 'package:openapi/src/model/error.dart';
import 'package:openapi/src/model/health_get200_response.dart';
import 'package:openapi/src/model/nft.dart';
import 'package:openapi/src/model/nft_asset.dart';
import 'package:openapi/src/model/nft_trait.dart';
import 'package:openapi/src/model/paginated_nft_result.dart';
import 'package:openapi/src/model/pagination.dart';
import 'package:openapi/src/model/token.dart';
import 'package:openapi/src/model/token_balance.dart';
import 'package:openapi/src/model/token_type.dart';

part 'serializers.g.dart';

@SerializersFor([
  ApiSearchAddressAddressGet200Response,
  ApiSearchDidDidGet200Response,
  ApiUserAddressBalanceGet200Response,
  ApiUserAddressGet200Response,
  ApiUserAddressNftsGet200Response,
  Error,
  HealthGet200Response,
  NFT,
  NFTAsset,
  NFTTrait,
  PaginatedNFTResult,
  Pagination,
  Token,
  TokenBalance,
  TokenType,
])
Serializers serializers = (_$serializers.toBuilder()
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
