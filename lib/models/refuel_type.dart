enum RefuelType {
  partial(0),
  full(11);

  final int value;
  const RefuelType(this.value);

  static RefuelType fromValue(int value) {
    return RefuelType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => RefuelType.partial,
    );
  }
}
