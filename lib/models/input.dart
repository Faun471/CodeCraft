class Input {
  String value;
  String type;

  Input({required this.value, required this.type});

  factory Input.fromJson(Map<String, dynamic> json) {
    return Input(
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
