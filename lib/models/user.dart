class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String? phone;
  final List<String> addresses;
  final List<String> favoriteChefIds;
  final List<String> dietaryPreferences;
  final String preferredLanguage;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.phone,
    required this.addresses,
    required this.favoriteChefIds,
    required this.dietaryPreferences,
    required this.preferredLanguage,
  });

  static User getSampleUser() {
    return const User(
      id: 'user1',
      name: 'Anna Madsen',
      email: 'anna.madsen@email.com',
      profileImage: null,
      phone: '+45 12 34 56 78',
      addresses: [
        'Nørrebrogade 123, 2200 København N',
        'Vesterbrogade 45, 1620 København V',
      ],
      favoriteChefIds: ['1', '3'],
      dietaryPreferences: ['Vegetarian'],
      preferredLanguage: 'da',
    );
  }
}