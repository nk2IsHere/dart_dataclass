// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$Test {
  int get a;
  int? get b;
  List<int?> get c;
  List<int?>? get d;
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! Test) return false;

    return true &&
        this.a == other.a &&
        this.b == other.b &&
        collectionEquals(this.c, other.c) &&
        collectionEquals(this.d, other.d);
  }

  int get hashCode {
    return mapPropsToHashCode([a, b, c, d]);
  }

  String toString() {
    return 'Test(a=${this.a},b=${this.b},c=${this.c},d=${this.d})';
  }

  Test copyWith({int? a, int? b, List<int>? c, List<int>? d}) {
    return Test(
      a: a ?? this.a,
      b: b ?? this.b,
      c: c ?? this.c,
      d: d ?? this.d,
    );
  }
}
