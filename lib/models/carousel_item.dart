class CarouselItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final int? order;
  final DateTime? createdAt;

  CarouselItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.order,
    this.createdAt,
  });

  factory CarouselItem.fromJson(Map<String, dynamic> json) {
    return CarouselItem(
      id: json['id']?.toString() ?? '',
      title: json['headerText']?.toString() ?? '',
      subtitle: json['description']?.toString() ?? '',
      imageUrl: json['imageURL']?.toString() ?? '',
      order: json['order'] as int?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'headerText': title,
      'description': subtitle,
      'imageURL': imageUrl,
      'order': order,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Sample data for development
  static List<CarouselItem> getSampleItems() {
    return [
      CarouselItem(
        id: '1',
        title: 'Dagligvarer',
        subtitle: 'Leveret til din dør på ingen tid',
        imageUrl: 'https://pixabay.com/get/gff6cf4f3cae2ed272b5261536190fb67fb564ebe9c6d374234ae0a3b4baf324789e715ee4d0a7f8288260f081d3705fbfbef9e7bd42f1bea43d30effb93add98_1280.jpg',
      ),
      CarouselItem(
        id: '2',
        title: 'Fresh Ingredients',
        subtitle: 'Directly from local farms',
        imageUrl: 'https://pixabay.com/get/ge90328ebd3683870dfbe5b434563bf6b209852dc35d581a2ab35544e1fbeca6e371d03d2e0365728caf42bff36ba6016d33471371914b88f34d28615d90bfe49_1280.jpg',
      ),
      CarouselItem(
        id: '3',
        title: 'Chef Specials',
        subtitle: 'Curated meals by top chefs',
        imageUrl: 'https://pixabay.com/get/g510a9bdbe8b70aa8e5c93b122a531fa4e511dd3ec243df43d91c72bd40a1cd8ab6b769814f1a5acbc46d793e1ee59bb1569fe99c56f6af8af33507b08bd5912d_1280.jpg',
      ),
    ];
  }
}