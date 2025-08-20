import 'package:equatable/equatable.dart';

class Dish extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> dietaryInfo;
  final List<String> allergens;
  final int preparationTime;
  final String? imageUrl;
  final String? chefId;
  final String? chefName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int? orderCount;
  final int? favoriteCount;
  final bool isFavorited;

  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.dietaryInfo,
    required this.allergens,
    required this.preparationTime,
    this.imageUrl,
    this.chefId,
    this.chefName,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.orderCount,
    this.favoriteCount,
    this.isFavorited = false,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] ?? '',
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients'] as List)
          : [],
      dietaryInfo: json['dietary_info'] != null
          ? List<String>.from(json['dietary_info'] as List)
          : [],
      allergens: json['allergens'] != null
          ? List<String>.from(json['allergens'] as List)
          : [],
      preparationTime: json['preparation_time'] ?? 0,
      imageUrl: json['image_url'] as String?,
      chefId: json['chef_id'] as String?,
      chefName: json['chef_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] ?? true,
      orderCount: json['order_count'] as int?,
      favoriteCount: json['favorite_count'] as int?,
      isFavorited: json['is_favorited'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'dietary_info': dietaryInfo,
      'allergens': allergens,
      'preparation_time': preparationTime,
      'image_url': imageUrl,
      'chef_id': chefId,
      'chef_name': chefName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'order_count': orderCount,
      'favorite_count': favoriteCount,
      'is_favorited': isFavorited,
    };
  }

  Dish copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? ingredients,
    List<String>? dietaryInfo,
    List<String>? allergens,
    int? preparationTime,
    String? imageUrl,
    String? chefId,
    String? chefName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? orderCount,
    int? favoriteCount,
    bool? isFavorited,
  }) {
    return Dish(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      dietaryInfo: dietaryInfo ?? this.dietaryInfo,
      allergens: allergens ?? this.allergens,
      preparationTime: preparationTime ?? this.preparationTime,
      imageUrl: imageUrl ?? this.imageUrl,
      chefId: chefId ?? this.chefId,
      chefName: chefName ?? this.chefName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      orderCount: orderCount ?? this.orderCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        ingredients,
        dietaryInfo,
        allergens,
        preparationTime,
        imageUrl,
        chefId,
        chefName,
        createdAt,
        updatedAt,
        isActive,
        orderCount,
        favoriteCount,
        isFavorited,
      ];
}