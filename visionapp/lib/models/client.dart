class Client {
  final String id;
  final String name;
  final String? phone;
  final DateTime? created_at;
  final bool is_active;

  Client({
    String? id,
    required this.name,
    this.phone,
    this.created_at,
    this.is_active = true,
  }) : id = id ?? generateClientId(name);

  static String generateClientId(String name) {
    // Create a client ID based on name + timestamp + random number
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp % 10000;
    final cleanName = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    final namePrefix = cleanName.length > 3 ? cleanName.substring(0, 3) : cleanName;
    return '${namePrefix}${timestamp.toString().substring(timestamp.toString().length - 4)}$random';
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      created_at: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      is_active: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'name': name,
      'phone': phone,
      'is_active': is_active,
    };

    if (id.isNotEmpty) {
      map['id'] = id;
    }

    return map;
  }

  Client copyWith({
    String? id,
    String? name,
    String? phone,
    DateTime? created_at,
    bool? is_active,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      created_at: created_at ?? this.created_at,
      is_active: is_active ?? this.is_active,
    );
  }

  @override
  String toString() => 'Client(id: $id, name: $name)';
}