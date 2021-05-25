library dataclass_beta_generator;

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:dataclass_beta/dataclass_beta.dart';
import 'package:dataclass_beta_generator/mixin_spec.dart';
import 'package:source_gen/source_gen.dart';

Builder dataClass(BuilderOptions options) =>
    SharedPartBuilder([DataClassGenerator()], 'dataclass_beta');

class DataClassGenerator extends GeneratorForAnnotation<DataClass> {
  final emitter = DartEmitter();
  final formatter = DartFormatter();

  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    void _isSourceValid(ClassElement element) {
      if (element.unnamedConstructor == null || !element.unnamedConstructor.isDefaultConstructor) {
        throw InvalidGenerationSourceError(
            'The ${element.name} @DataClass must have unnamed (default) constructor');
      }
      if (element.unnamedConstructor.parameters.isNotEmpty) {
        if (!element.unnamedConstructor.parameters
            .any((param) => param.isNamed)) {
          throw InvalidGenerationSourceError(
              'The ${element.name} @DataClass constructor should have named params only');
        }
      }

      if (element.fields.any((field) => !field.isFinal)) {
        throw InvalidGenerationSourceError(
            '@DataClass should have final fields only');
      }
    }

    if (element is ClassElement && !element.isAbstract) {
      _isSourceValid(element);

      final equalsMethod = _equalsMethod(element.displayName, element.unnamedConstructor.parameters);
      final copyWithMethod = _copyWithMethod(element, element.unnamedConstructor.parameters);
      final hashCodeMethod = _hashCodeMethod(element.unnamedConstructor.parameters);
      final toStringMethod =
          _toStringMethod(element.displayName, element.unnamedConstructor.parameters);

      final getters = element.unnamedConstructor.parameters
          .map((parameter) => MethodBuilder()
            ..name = parameter.displayName
            ..returns = refer(parameter.type.getDisplayString(withNullability: true))
            ..type = MethodType.getter)
          .map((mb) => mb.build());

      // final constConstructor = (ConstructorBuilder()..constant = true).build();

      final dataClass = MixinBuilder()
        ..name = '_\$${element.name}'
        // ..on = TypeReference((t) => t.symbol = element.name)
        // ..constructors.add(constConstructor)
        ..types.addAll(element.typeParameters
            .map((typeParam) => refer(typeParam.displayName)))
        ..methods.addAll(getters)
        ..methods.add(equalsMethod)
        ..methods.add(hashCodeMethod)
        ..methods.add(toStringMethod)
        ..methods.add(copyWithMethod);
        // ..abstract = true;

      return formatter.format(dataClass.build().accept(emitter).toString());
    } else {
      throw Exception(
        '@DataClass anontation cannot be used on abstract classes',
      );
    }
  }

  Method _equalsMethod(String className, List<ParameterElement> parameters) {
    MethodBuilder mb = MethodBuilder()
      ..name = 'operator=='
      ..requiredParameters.add((ParameterBuilder()..name = 'other').build())
      ..returns = refer('bool')
      ..body = Code(
        equalsBody(
          className,
          Map.fromIterable(parameters,
              key: (element) => element.displayName,
              value: (element) => _hasDeepCollectionEquality(element)),
        ),
      );

    parameters.map(
      (element) => element.metadata.map(
        (annotation) => annotation
            .computeConstantValue()
            .getField('deepEquality')
            .toBoolValue(),
      ),
    );

    return mb.build();
  }

  bool _hasDeepCollectionEquality(FieldElement fieldElement) {
    final collectionAnnotation =
        TypeChecker.fromRuntime(Collection).firstAnnotationOf(fieldElement);

    if (collectionAnnotation == null)
      return false;
    else {
      return collectionAnnotation.getField('deepEquality').toBoolValue();
    }
  }

  Method _hashCodeMethod(List<ParameterElement> parameters) {
    final props = parameters.map((field) => field.name);

    MethodBuilder mb = MethodBuilder()
      ..name = 'hashCode'
      ..type = MethodType.getter
      ..returns = refer('int')
      ..body = Code(
        '''
        return mapPropsToHashCode([${props.join(', ')}]);
        ''',
      );

    return mb.build();
  }

  Method _copyWithMethod(ClassElement clazz, List<ParameterElement> parameters) {
    final params = parameters
        .map((field) => ParameterBuilder()
          ..name = field.name
          ..type = refer("${field.type.getDisplayString(withNullability: false)}?")
          ..named = true)
        .map((paramBuilder) => paramBuilder.build());

    final mb = MethodBuilder()
      ..name = 'copyWith'
      ..optionalParameters.addAll(params)
      ..returns = refer(clazz.name)
      ..body = Code(
          copyToMethodBody(clazz, parameters.map((field) => field.displayName)));

    return mb.build();
  }

  Method _toStringMethod(String className, List<ParameterElement> parameters) {
    final mb = MethodBuilder()
      ..name = 'toString'
      ..returns = refer('String')
      ..body = Code(
          toStringBody(className, parameters.map((field) => field.displayName)));

    return mb.build();
  }
}

String equalsBody(String className, Map<String, bool> fields) {
  final fieldEquals = fields.entries.fold<String>('true', (value, element) {
    final hasDeepCollectionEquality = element.value;
    if (hasDeepCollectionEquality) {
      return '$value && DeepCollectionEquality().equals(this.${element.key},other.${element.key})';
    } else {
      return '$value && this.${element.key} == other.${element.key}';
    }
  });

  return '''
  if (identical(this, other)) return true;
  if (other is! $className) return false;

  return $fieldEquals;
''';
}

String copyToMethodBody(ClassElement clazz, Iterable<String> fields) {
  final paramsInput = fields.fold(
    "",
    (r, field) => "$r ${field}: ${field} ?? this.${field},",
  );

  final typeParameters = clazz.typeParameters.isEmpty
      ? ''
      : '<' + clazz.typeParameters.map((type) => type.name).join(',') + '>';

  return '''return ${clazz.name}$typeParameters($paramsInput);''';
}

String toStringBody(String className, Iterable<String> fields) {
  final fieldsToString = fields.fold('', (r, field) => r + '$field=\${this.$field},');
  return "return '$className($fieldsToString)';";
}
