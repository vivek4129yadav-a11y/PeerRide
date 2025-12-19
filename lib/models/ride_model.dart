class RideUser {
  final String id;
  final String name;
  final double rating;
  final String walletAddress;

  RideUser({required this.id, required this.name, required this.rating, required this.walletAddress});
}

enum RideStatus { available, booked, inProgress, completed }

class Ride {
  final String id;
  final RideUser driver;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final double price;
  final int availableSeats;
  RideStatus status;
  String? contractAddress;
  List<RideUser> riders;

  Ride({
    required this.id,
    required this.driver,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.price,
    required this.availableSeats,
    this.status = RideStatus.available,
    this.contractAddress,
    this.riders = const [],
  });

  Ride copyWith({RideStatus? status, String? contractAddress, List<RideUser>? riders}) {
    return Ride(
      id: id,
      driver: driver,
      origin: origin,
      destination: destination,
      departureTime: departureTime,
      price: price,
      availableSeats: availableSeats,
      status: status ?? this.status,
      contractAddress: contractAddress ?? this.contractAddress,
      riders: riders ?? this.riders,
    );
  }
}
