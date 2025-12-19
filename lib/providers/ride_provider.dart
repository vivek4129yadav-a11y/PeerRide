import 'package:flutter/material.dart';
import '../models/ride_model.dart';
import '../core/mock_blockchain_service.dart';

class RideProvider with ChangeNotifier {
  final MockBlockchainService _blockchainService = MockBlockchainService();

  List<Ride> _rides = [];
  RideUser? _currentUser;
  bool _isLoading = false;

  List<Ride> get rides => _rides;
  RideUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  RideProvider() {
    // Initialize with some mock data
    _currentUser = RideUser(
      id: "user_1",
      name: "John Doe",
      rating: 4.8,
      walletAddress: "0x71C7656EC7ab88b098defB751B7401B5f6d8976F",
    );

    _rides = [
      Ride(
        id: "ride_1",
        driver: RideUser(id: "driver_1", name: "Alice", rating: 4.9, walletAddress: "0x123..."),
        origin: "Downtown",
        destination: "Airport",
        departureTime: DateTime.now().add(const Duration(hours: 2)),
        price: 15.0,
        availableSeats: 3,
      ),
      Ride(
        id: "ride_2",
        driver: RideUser(id: "driver_2", name: "Bob", rating: 4.7, walletAddress: "0x456..."),
        origin: "Suburb A",
        destination: "Tech Park",
        departureTime: DateTime.now().add(const Duration(hours: 1)),
        price: 10.0,
        availableSeats: 2,
      ),
    ];
  }

  void setRole(String name, bool isDriver) {
    _currentUser = RideUser(
      id: isDriver ? "driver_me" : "rider_me",
      name: name,
      rating: 5.0,
      walletAddress: "0xMY_WALLET_ADDRESS",
    );
    notifyListeners();
  }

  Future<void> offerRide(String origin, String destination, double price, int seats) async {
    _isLoading = true;
    notifyListeners();

    final newRide = Ride(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      driver: _currentUser!,
      origin: origin,
      destination: destination,
      departureTime: DateTime.now().add(const Duration(hours: 4)),
      price: price,
      availableSeats: seats,
    );

    _rides.insert(0, newRide);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> bookRide(String rideId) async {
    _isLoading = true;
    notifyListeners();

    final rideIndex = _rides.indexWhere((r) => r.id == rideId);
    if (rideIndex != -1) {
      final ride = _rides[rideIndex];

      // Simulate Smart Contract Deployment
      final contractAddress = await _blockchainService.deploySmartContract(
        _currentUser!.id,
        ride.driver.id,
        ride.price,
      );

      _rides[rideIndex] = ride.copyWith(
        status: RideStatus.booked,
        contractAddress: contractAddress,
        riders: [...ride.riders, _currentUser!],
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeRide(String rideId) async {
    _isLoading = true;
    notifyListeners();

    final rideIndex = _rides.indexWhere((r) => r.id == rideId);
    if (rideIndex != -1) {
      final ride = _rides[rideIndex];

      // Simulate Payment Execution via Smart Contract
      await _blockchainService.executePayment(
        _currentUser!.walletAddress,
        ride.driver.walletAddress,
        ride.price,
      );

      _rides[rideIndex] = ride.copyWith(status: RideStatus.completed);
    }

    _isLoading = false;
    notifyListeners();
  }
}
