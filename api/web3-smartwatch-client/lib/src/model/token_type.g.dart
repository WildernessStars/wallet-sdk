// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TokenType _$eRC20 = const TokenType._('eRC20');
const TokenType _$NATIVE = const TokenType._('NATIVE');

TokenType _$valueOf(String name) {
  switch (name) {
    case 'eRC20':
      return _$eRC20;
    case 'NATIVE':
      return _$NATIVE;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<TokenType> _$values = new BuiltSet<TokenType>(const <TokenType>[
  _$eRC20,
  _$NATIVE,
]);

class _$TokenTypeMeta {
  const _$TokenTypeMeta();
  TokenType get eRC20 => _$eRC20;
  TokenType get NATIVE => _$NATIVE;
  TokenType valueOf(String name) => _$valueOf(name);
  BuiltSet<TokenType> get values => _$values;
}

abstract class _$TokenTypeMixin {
  // ignore: non_constant_identifier_names
  _$TokenTypeMeta get TokenType => const _$TokenTypeMeta();
}

Serializer<TokenType> _$tokenTypeSerializer = new _$TokenTypeSerializer();

class _$TokenTypeSerializer implements PrimitiveSerializer<TokenType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'eRC20': 'ERC20',
    'NATIVE': 'NATIVE',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ERC20': 'eRC20',
    'NATIVE': 'NATIVE',
  };

  @override
  final Iterable<Type> types = const <Type>[TokenType];
  @override
  final String wireName = 'TokenType';

  @override
  Object serialize(Serializers serializers, TokenType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TokenType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TokenType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
