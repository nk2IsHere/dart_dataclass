
import 'package:dataclass_beta/dataclass_beta.dart';

part 'test.g.dart';

@DataClass()
class Test with _$Test {

  final int a;
  final int? b;
  final List<int?> c;
  final List<int?>? d;

  Test({
    required this.a,
    this.b = 4,
    @Collection() this.c = const [],
    @Collection() this.d
  });
}
