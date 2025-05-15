// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (new Serializers().toBuilder()
      ..add(ApiSearchAddressAddressGet200Response.serializer)
      ..add(ApiSearchDidDidGet200Response.serializer)
      ..add(ApiUserAddressBalanceGet200Response.serializer)
      ..add(ApiUserAddressGet200Response.serializer)
      ..add(ApiUserAddressNftsGet200Response.serializer)
      ..add(Error.serializer)
      ..add(HealthGet200Response.serializer)
      ..add(NFT.serializer)
      ..add(NFTAsset.serializer)
      ..add(NFTTrait.serializer)
      ..add(NFTTypeEnum.serializer)
      ..add(PaginatedNFTResult.serializer)
      ..add(Pagination.serializer)
      ..add(Token.serializer)
      ..add(TokenBalance.serializer)
      ..add(TokenType.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(NFT)]),
          () => new ListBuilder<NFT>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(NFTAsset)]),
          () => new ListBuilder<NFTAsset>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(NFTTrait)]),
          () => new ListBuilder<NFTTrait>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Token)]),
          () => new ListBuilder<Token>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Token)]),
          () => new ListBuilder<Token>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => new MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => new MapBuilder<String, JsonObject?>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
