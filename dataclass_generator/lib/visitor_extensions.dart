
import 'package:dataclass_beta_generator/mixin_spec.dart';
import 'package:code_builder/src/visitors.dart';
import 'package:code_builder/src/specs/method.dart';
import 'package:code_builder/src/specs/code.dart';
import 'package:code_builder/src/specs/expression.dart';

extension VisitorExtensions<R extends StringSink> on SpecVisitor<R> {

  static bool _isLambdaBody(Code? code) =>
      code is ToCodeExpression && !code.isStatement;

  static bool _isLambdaMethod(Method method) =>
      method.lambda ?? _isLambdaBody(method.body);

  R visitMixin(Mixin spec, [R? output]) {
    output ??= StringBuffer() as R;

    spec.docs.forEach(output.writeln);
    spec.annotations.forEach((a) => visitAnnotation(a, output));
    output.write('mixin ${spec.name}');
    visitTypeParameters(spec.types.map((r) => r.type), output);
    if (spec.on != null) {
      output.write(' on ');
      spec.on!.type.accept(this, output);
    }
    if (spec.implements.isNotEmpty) {
      output
        ..write(' implements ')
        ..writeAll(
            spec.implements.map<StringSink>((m) => m.type.accept(this)), ',');
    }
    output.write(' {');
    spec.methods.forEach((m) {
      visitMethod(m, output);
      if (_isLambdaMethod(m)) {
        output!.write(';');
      }
      output!.writeln();
    });
    output.writeln(' }');
    return output;
  }
}
