import 'dart:convert';

class Item {
  final String id;
  final String name;
  final String type;
  final String area;
  final DateTime date;
  final bool isLost;
  final String description;
  final String? imagePath;
  final List<String> tags;
  final bool recovered;
  final DateTime? reminderDate;

  Item({
    required this.id,
    required this.name,
    required this.type,
    required this.area,
    required this.date,
    required this.isLost,
    required this.description,
    this.imagePath,
    this.tags = const [],
    this.recovered = false,
    this.reminderDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'area': area,
      'date': date.toIso8601String(),
      'isLost': isLost,
      'description': description,
      'imagePath': imagePath,
      'tags': tags,
      'recovered': recovered,
      'reminderDate': reminderDate?.toIso8601String(),
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      area: json['area'],
      date: DateTime.parse(json['date']),
      isLost: json['isLost'],
      description: json['description'],
      imagePath: json['imagePath'],
      tags: List<String>.from(json['tags'] ?? []),
      recovered: json['recovered'] ?? false,
      reminderDate: json['reminderDate'] != null 
          ? DateTime.parse(json['reminderDate'])
          : null,
    );
  }

  Item copyWith({
    String? id,
    String? name,
    String? type,
    String? area,
    DateTime? date,
    bool? isLost,
    String? description,
    String? imagePath,
    List<String>? tags,
    bool? recovered,
    DateTime? reminderDate,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      area: area ?? this.area,
      date: date ?? this.date,
      isLost: isLost ?? this.isLost,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      tags: tags ?? this.tags,
      recovered: recovered ?? this.recovered,
      reminderDate: reminderDate ?? this.reminderDate,
    );
  }
} 