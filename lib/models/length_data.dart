class LengthData {
  final int length;
  final int quantity;

  const LengthData({
    required this.length,
    required this.quantity,
  });

  factory LengthData.fromJson(Map<String, dynamic> json) {
    return LengthData(
      length: json['length'] is int ? json['length'] : int.parse(json['length'].toString()),
      quantity: json['quantity'] is int ? json['quantity'] : int.parse(json['quantity'].toString()),
    );
  }

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'length': length,
      'quantity': quantity,
    };
  }
} 