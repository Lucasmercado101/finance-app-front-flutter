class ResponseIncomeDto {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double amount;
  final String currency;
  final String? category;
  final String? comment;

  ResponseIncomeDto({
    required this.id,
    required this.createdAt,
    required this.amount,
    required this.currency,
    required this.updatedAt,
    this.comment,
    this.category,
  });

  ResponseIncomeDto.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        createdAt = DateTime.parse(json['created_at']),
        updatedAt = DateTime.parse(json['updated_at']),
        amount = json['amount'] + .0,
        category = json['category'],
        comment = json['comment'],
        currency = json['currency'];
}
