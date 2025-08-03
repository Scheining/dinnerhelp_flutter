class Chef {
  final String id;
  final String name;
  final String profileImage;
  final String headerImage;
  final double rating;
  final int reviewCount;
  final List<String> cuisineTypes;
  final double hourlyRate;
  final String location;
  final String bio;
  final int experienceYears;
  final List<String> languages;
  final List<String> dietarySpecialties;
  final bool isVerified;
  final bool isAvailable;
  final double distanceKm;

  const Chef({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.headerImage,
    required this.rating,
    required this.reviewCount,
    required this.cuisineTypes,
    required this.hourlyRate,
    required this.location,
    required this.bio,
    required this.experienceYears,
    required this.languages,
    required this.dietarySpecialties,
    required this.isVerified,
    required this.isAvailable,
    required this.distanceKm,
  });

  static List<Chef> getSampleChefs() {
    return [
      const Chef(
        id: '1',
        name: 'Lars Nielsen',
        profileImage: 'https://pixabay.com/get/g24a62bc118f3af91b1e93be58966f8e74118b4d1f413f7c2959623342bff7e50a316adc41c3ff570aad063e55e463a5cc6ffa293d5df12b97a4d093a0a5b20a4_1280.jpg',
        headerImage: 'https://pixabay.com/get/g1332f394d63c54fad0fc11ba0a7ad588e5a38bda0e002c9d2fd1dafb2166e66be52bb32617eb346cefbc42306e7e2aa5949e0f916752b1fb5886c5a847a809a9_1280.jpg',
        rating: 4.9,
        reviewCount: 127,
        cuisineTypes: ['Nordic', 'Danish'],
        hourlyRate: 450.0,
        location: 'København',
        bio: 'Passionate about New Nordic cuisine with 10+ years of experience in Michelin-starred restaurants. I specialize in seasonal, locally-sourced ingredients.',
        experienceYears: 12,
        languages: ['Danish', 'English'],
        dietarySpecialties: ['Vegetarian', 'Gluten-Free'],
        isVerified: true,
        isAvailable: true,
        distanceKm: 2.1,
      ),
      const Chef(
        id: '2',
        name: 'Sofia Rossi',
        profileImage: 'https://pixabay.com/get/gce5ca18fe326e96f1281a742ea0addceff525d242705b4fac9367ac6db93fdbb947ca628bee909f9697e83eaab442039c253ae01f397df124edb8d22d0571f13_1280.jpg',
        headerImage: 'https://pixabay.com/get/g0bb5e0e4e007cc3f246dfc88005280a438f408831c65caf570329e3627b6237886b060b9054ce76e962a06e126ecc5f4f2a1338426819de53d44b95b8641c30b_1280.jpg',
        rating: 4.8,
        reviewCount: 98,
        cuisineTypes: ['Italian', 'Mediterranean'],
        hourlyRate: 400.0,
        location: 'Aarhus',
        bio: 'Authentic Italian cuisine from the heart of Tuscany. I bring traditional family recipes and modern techniques to your home.',
        experienceYears: 8,
        languages: ['Italian', 'Danish', 'English'],
        dietarySpecialties: ['Vegetarian', 'Vegan'],
        isVerified: true,
        isAvailable: false,
        distanceKm: 3.5,
      ),
      const Chef(
        id: '3',
        name: 'Hiroshi Tanaka',
        profileImage: 'https://pixabay.com/get/g4ae9d08f517456e145051a27a85e3f32dead358dd08125bf035b5516db999960571e19e3c4f062f968dc9de14bd10b48c625a1d3c05a5315f9280e50a7d9f435_1280.jpg',
        headerImage: 'https://pixabay.com/get/ga46ba698d04eb81048625a26fec4ec3a677f30620b3a1162ef7e6f536b01486a86ec74125861bec0ce9ee760f5cfbefa19a84623d1dfbdde0ab2f5454c13bf0a_1280.jpg',
        rating: 4.9,
        reviewCount: 156,
        cuisineTypes: ['Japanese', 'Asian'],
        hourlyRate: 480.0,
        location: 'København',
        bio: 'Master sushi chef with training in Tokyo. Specializing in authentic Japanese cuisine, sushi, and modern Asian fusion.',
        experienceYears: 15,
        languages: ['Japanese', 'English', 'Danish'],
        dietarySpecialties: ['Pescatarian', 'Gluten-Free'],
        isVerified: true,
        isAvailable: true,
        distanceKm: 1.8,
      ),
      const Chef(
        id: '4',
        name: 'Marie Dupont',
        profileImage: 'https://pixabay.com/get/g70a879fc084eb7f003e0b8e2c7cffc931c388cb2cf5789a06aee3a32938af8e4ee65fc3f924914cbfe67adf36ecbc20fc3d7e5a4009d70cc4a28fbf7a4e5a534_1280.jpg',
        headerImage: 'https://pixabay.com/get/g5dbec083c6a097c3ed24468048a13533aa641af0b4eeb3c670c4bd00fa68f0b4b30389348b22cdf7601bbd2c72e77c3b55906f4f172dea042f8a120f8cb08ef4_1280.jpg',
        rating: 4.7,
        reviewCount: 89,
        cuisineTypes: ['French', 'European'],
        hourlyRate: 420.0,
        location: 'Odense',
        bio: 'Classically trained French chef bringing elegant European cuisine to your table. Expert in pastries and fine dining.',
        experienceYears: 10,
        languages: ['French', 'Danish', 'English'],
        dietarySpecialties: ['Vegetarian'],
        isVerified: true,
        isAvailable: true,
        distanceKm: 4.2,
      ),
      const Chef(
        id: '5',
        name: 'Erik Andersen',
        profileImage: 'https://pixabay.com/get/g24a62bc118f3af91b1e93be58966f8e74118b4d1f413f7c2959623342bff7e50a316adc41c3ff570aad063e55e463a5cc6ffa293d5df12b97a4d093a0a5b20a4_1280.jpg',
        headerImage: 'https://pixabay.com/get/g37f043ca0e8f4d1b3ed0d2f81563795be1b99b7b95fe5c7fa77a07a95ec7d92bca53df3080c9da964c00851d80cf66a78a7ac4b4c809abf3208f287661979b0a_1280.jpg',
        rating: 4.6,
        reviewCount: 72,
        cuisineTypes: ['Nordic', 'Seafood'],
        hourlyRate: 380.0,
        location: 'Aalborg',
        bio: 'Seafood specialist with a passion for Nordic coastal cuisine. Using fresh, local ingredients from Danish waters.',
        experienceYears: 9,
        languages: ['Danish', 'English'],
        dietarySpecialties: ['Pescatarian'],
        isVerified: false,
        isAvailable: true,
        distanceKm: 5.7,
      ),
    ];
  }
}