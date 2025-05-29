//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'token_type.g.dart';

class TokenType extends EnumClass {
  /// Type of the token
  @BuiltValueEnumConst(wireName: r'ERC20')
  static const TokenType eRC20 = _$eRC20;

  /// Type of the token
  @BuiltValueEnumConst(wireName: r'NATIVE')
  static const TokenType NATIVE = _$NATIVE;

  static Serializer<TokenType> get serializer => _$tokenTypeSerializer;

  const TokenType._(String name) : super(name);

  static BuiltSet<TokenType> get values => _$values;
  static TokenType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class TokenTypeMixin = Object with _$TokenTypeMixin;
