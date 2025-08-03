enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

class Booking {
  final String id;
  final String chefId;
  final String chefName;
  final String userId;
  final DateTime dateTime;
  final int guestCount;
  final String address;
  final double basePrice;
  final double serviceFee;
  final double tax;
  final double totalPrice;
  final BookingStatus status;
  final String? notes;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.chefId,
    required this.chefName,
    required this.userId,
    required this.dateTime,
    required this.guestCount,
    required this.address,
    required this.basePrice,
    required this.serviceFee,
    required this.tax,
    required this.totalPrice,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  String get statusText {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  static List<Booking> getSampleBookings() {
    return [
      Booking(
        id: '1',
        chefId: '1',
        chefName: 'Lars Nielsen',
        userId: 'user1',
        dateTime: DateTime.now().add(const Duration(days: 3)),
        guestCount: 4,
        address: 'Nørrebrogade 123, 2200 København N',
        basePrice: 1800.0,
        serviceFee: 180.0,
        tax: 495.0,
        totalPrice: 2475.0,
        status: BookingStatus.confirmed,
        notes: 'Please prepare vegetarian options for 2 guests',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Booking(
        id: '2',
        chefId: '3',
        chefName: 'Hiroshi Tanaka',
        userId: 'user1',
        dateTime: DateTime.now().add(const Duration(days: 7)),
        guestCount: 2,
        address: 'Vesterbrogade 45, 1620 København V',
        basePrice: 960.0,
        serviceFee: 96.0,
        tax: 264.0,
        totalPrice: 1320.0,
        status: BookingStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Booking(
        id: '3',
        chefId: '2',
        chefName: 'Sofia Rossi',
        userId: 'user1',
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        guestCount: 6,
        address: 'Strøget 78, 1160 København K',
        basePrice: 2400.0,
        serviceFee: 240.0,
        tax: 660.0,
        totalPrice: 3300.0,
        status: BookingStatus.completed,
        notes: 'Amazing Italian dinner for anniversary celebration',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}