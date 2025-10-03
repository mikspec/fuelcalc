class Expense {
  final int? id;
  final DateTime date;
  final String? information;
  final String statisticTitle;
  final double statisticCost;
  final int statisticType;
  final int statisticSubtype;
  final double statisticRating;

  Expense({
    this.id,
    required this.date,
    this.information,
    required this.statisticTitle,
    this.statisticCost = 0.0,
    this.statisticType = 0,
    this.statisticSubtype = 0,
    this.statisticRating = 5.0,
  });

  Map<String, dynamic> toMap() {
    return {
      '_statistics_row_id': id,
      'date': date.toIso8601String(),
      'information': information,
      'statistic_title': statisticTitle,
      'statistic_cost': statisticCost,
      'statistic_type': statisticType,
      'statistic_subtype': statisticSubtype,
      'statistic_rating': statisticRating,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['_statistics_row_id'],
      date: DateTime.parse(map['date']),
      information: map['information'],
      statisticTitle: map['statistic_title'] ?? '',
      statisticCost: (map['statistic_cost'] ?? 0.0).toDouble(),
      statisticType: map['statistic_type'] ?? 0,
      statisticSubtype: map['statistic_subtype'] ?? 0,
      statisticRating: (map['statistic_rating'] ?? 5.0).toDouble(),
    );
  }

  Expense copyWith({
    int? id,
    DateTime? date,
    String? information,
    String? statisticTitle,
    double? statisticCost,
    int? statisticType,
    int? statisticSubtype,
    double? statisticRating,
  }) {
    return Expense(
      id: id ?? this.id,
      date: date ?? this.date,
      information: information ?? this.information,
      statisticTitle: statisticTitle ?? this.statisticTitle,
      statisticCost: statisticCost ?? this.statisticCost,
      statisticType: statisticType ?? this.statisticType,
      statisticSubtype: statisticSubtype ?? this.statisticSubtype,
      statisticRating: statisticRating ?? this.statisticRating,
    );
  }

  // Expense categories - identifiers only
  static const Map<int, String> expenseTypes = {
    0: 'other',
    1: 'battery',
    2: 'repair',
    3: 'towing',
    4: 'insurance',
    5: 'inspection',
  };

  // Getter returning only type key (for use with localization)
  String get typeKey => expenseTypes[statisticType] ?? 'unknown';
}