
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:meta/meta.dart';
import 'package:code_builder/src/base.dart';
import 'package:code_builder/src/mixins/annotations.dart';
import 'package:code_builder/src/mixins/dartdoc.dart';
import 'package:code_builder/src/mixins/generics.dart';
import 'package:code_builder/src/visitors.dart';
import 'package:code_builder/src/specs/expression.dart';
import 'package:code_builder/src/specs/method.dart';
import 'package:code_builder/src/specs/reference.dart';
import 'package:dataclass_beta_generator/visitor_extensions.dart';

part 'mixin_spec.generated.dart';

// Adapted from: https://github.com/dart-lang/code_builder/pull/263
@immutable
abstract class Mixin extends Object
    with HasAnnotations, HasDartDocs, HasGenerics
    implements Built<Mixin, MixinBuilder>, Spec {
  factory Mixin([void Function(MixinBuilder) updates]) = _$Mixin;

  Mixin._();

  @override
  BuiltList<Expression> get annotations;

  @override
  BuiltList<String> get docs;

  Reference? get on;

  BuiltList<Reference> get implements;

  @override
  BuiltList<Reference> get types;

  BuiltList<Method> get methods;

  /// Name of the mixin.
  String get name;

  @override
  R accept<R>(
      SpecVisitor<R> visitor, [
        R? context,
      ]) {
    assert(R is StringSink);
    return (visitor as SpecVisitor<StringSink>)
      .visitMixin(
        this,
        (context ?? StringBuffer()) as StringSink
      ) as R;
  }
}

abstract class MixinBuilder extends Object
    with HasAnnotationsBuilder, HasDartDocsBuilder, HasGenericsBuilder
    implements Builder<Mixin, MixinBuilder> {
  factory MixinBuilder() = _$MixinBuilder;

  MixinBuilder._();

  @override
  ListBuilder<Expression> annotations = ListBuilder<Expression>();

  @override
  ListBuilder<String> docs = ListBuilder<String>();

  Reference? on;

  ListBuilder<Reference> implements = ListBuilder<Reference>();

  @override
  ListBuilder<Reference> types = ListBuilder<Reference>();

  ListBuilder<Method> methods = ListBuilder<Method>();

  /// Name of the mixin.
  late String name;
}
