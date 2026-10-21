/// A simple, robust Either type for Functional Clean Architecture error handling.
sealed class Either<L, R> {
  const Either();

  T fold<T>(T Function(L left) fnL, T Function(R right) fnR);

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  L? get leftOrNull => switch (this) {
        Left(:final value) => value,
        Right() => null,
      };

  R? get rightOrNull => switch (this) {
        Right(:final value) => value,
        Left() => null,
      };
}

final class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  T fold<T>(T Function(L left) fnL, T Function(R right) fnR) => fnL(value);
}

final class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  T fold<T>(T Function(L left) fnL, T Function(R right) fnR) => fnR(value);
}
