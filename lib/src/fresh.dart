/// The object that represents freshness of other objects.
class Fresh<T> {
  const Fresh._({this.entity, this.isFresh, this.isNextPageAvailable});

  /// Factory for [WhenFresh]
  factory Fresh.yes({
    required T entity,
    required bool isNextPageAvailable,
  }) = WhenFresh<T>._;

  /// Factory for [WhenNotFresh]
  factory Fresh.no({
    required T entity,
    required bool isNextPageAvailable,
  }) = WhenNotFresh<T>._;

  /// Entity whose freshness is to be checked.
  final T? entity;

  /// Determines if the entity is fresh or not.
  final bool? isFresh;

  /// Determines if the next page is available or not in pagination.
  final bool? isNextPageAvailable;
}

/// Represents that the entity is fresh.
class WhenFresh<T> extends Fresh<T> {
  const WhenFresh._({
    required T super.entity,
    required bool super.isNextPageAvailable,
  }) : super._(isFresh: true);

  @override
  String toString() {
    return 'WhenFresh{entity: $entity, isFresh: true, isNextPageAvailable: $isNextPageAvailable}';
  }
}

/// Represents that the entity is not fresh.
class WhenNotFresh<T> extends Fresh<T> {
  const WhenNotFresh._({
    required T super.entity,
    required bool super.isNextPageAvailable,
  }) : super._(isFresh: false);

  @override
  String toString() {
    return 'WhenNotFresh{entity: $entity, isFresh: false, isNextPageAvailable: $isNextPageAvailable}';
  }
}
