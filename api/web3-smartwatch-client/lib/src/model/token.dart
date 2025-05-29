//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/token_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'token.g.dart';

/// Token
///
/// Properties:
/// * [address] - Token contract address
/// * [name] - Token name
/// * [symbol] - Token symbol
/// * [type]
/// * [decimals] - Token decimals
/// * [tokenPrice] - Token price
/// * [balance] - Token balance
/// * [balanceUsd] - Token balance in USD
@BuiltValue()
abstract class Token implements Built<Token, TokenBuilder> {
  /// Token contract address
  @BuiltValueField(wireName: r'address')
  String get address;

  /// Token name
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Token symbol
  @BuiltValueField(wireName: r'symbol')
  String get symbol;

  @BuiltValueField(wireName: r'type')
  TokenType? get type;
  // enum typeEnum {  ERC20,  NATIVE,  };

  /// Token decimals
  @BuiltValueField(wireName: r'decimals')
  int? get decimals;

  /// Token price
  @BuiltValueField(wireName: r'tokenPrice')
  String? get tokenPrice;

  /// Token balance
  @BuiltValueField(wireName: r'balance')
  String? get balance;

  /// Token balance in USD
  @BuiltValueField(wireName: r'balanceUsd')
  String? get balanceUsd;

  Token._();

  factory Token([void updates(TokenBuilder b)]) = _$Token;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TokenBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Token> get serializer => _$TokenSerializer();
}

class _$TokenSerializer implements PrimitiveSerializer<Token> {
  @override
  final Iterable<Type> types = const [Token, _$Token];

  @override
  final String wireName = r'Token';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Token object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'address';
    yield serializers.serialize(
      object.address,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'symbol';
    yield serializers.serialize(
      object.symbol,
      specifiedType: const FullType(String),
    );
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(TokenType),
      );
    }
    if (object.decimals != null) {
      yield r'decimals';
      yield serializers.serialize(
        object.decimals,
        specifiedType: const FullType(int),
      );
    }
    if (object.tokenPrice != null) {
      yield r'tokenPrice';
      yield serializers.serialize(
        object.tokenPrice,
        specifiedType: const FullType(String),
      );
    }
    if (object.balance != null) {
      yield r'balance';
      yield serializers.serialize(
        object.balance,
        specifiedType: const FullType(String),
      );
    }
    if (object.balanceUsd != null) {
      yield r'balanceUsd';
      yield serializers.serialize(
        object.balanceUsd,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Token object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TokenBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.address = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'symbol':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.symbol = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TokenType),
          ) as TokenType;
          result.type = valueDes;
          break;
        case r'decimals':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.decimals = valueDes;
          break;
        case r'tokenPrice':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tokenPrice = valueDes;
          break;
        case r'balance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.balance = valueDes;
          break;
        case r'balanceUsd':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.balanceUsd = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Token deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TokenBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
