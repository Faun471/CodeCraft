class ExpectedOutput {
  String value;
  String type;

  ExpectedOutput({
    required this.value,
    required this.type,
  });

  factory ExpectedOutput.fromJson(Map<String, dynamic> json) {
    return ExpectedOutput(
      value: json['value'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'type': type,
    };
  }
}
