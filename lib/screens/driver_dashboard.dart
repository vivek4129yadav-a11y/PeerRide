import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ride_provider.dart';
import '../models/ride_model.dart';
import 'package:intl/intl.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  final _originController = TextEditingController();
  final _destController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final rideProvider = context.watch<RideProvider>();
    final myRides = rideProvider.rides.where((r) => r.driver.id == rideProvider.currentUser?.id).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Driver Dashboard')),
      body: rideProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Offer a New Ride', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _buildOfferForm(context),
                  const SizedBox(height: 32),
                  Text('My Offered Rides', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ...myRides.map((ride) => _MyRideCard(ride: ride)).toList(),
                  if (myRides.isEmpty)
                    const Center(
                      child: Padding(padding: EdgeInsets.all(32.0), child: Text('No rides offered yet.')),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildOfferForm(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _originController,
              decoration: const InputDecoration(
                labelText: 'Origin',
                prefixIcon: Icon(Icons.radio_button_checked),
              ),
            ),
            TextField(
              controller: _destController,
              decoration: const InputDecoration(
                labelText: 'Destination',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price (\$)',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    final origin = _originController.text;
                    final dest = _destController.text;
                    final price = double.tryParse(_priceController.text) ?? 0.0;
                    if (origin.isNotEmpty && dest.isNotEmpty && price > 0) {
                      context.read<RideProvider>().offerRide(origin, dest, price, 4);
                      _originController.clear();
                      _destController.clear();
                      _priceController.clear();
                    }
                  },
                  child: const Text('Offer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MyRideCard extends StatelessWidget {
  final Ride ride;

  const _MyRideCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
      child: ListTile(
        title: Text('${ride.origin} ➔ ${ride.destination}'),
        subtitle: Text(
          'Status: ${ride.status.name.toUpperCase()} | ${DateFormat('h:mm a').format(ride.departureTime)}',
          style: TextStyle(
            color: ride.status == RideStatus.booked
                ? Colors.orange
                : (ride.status == RideStatus.completed ? Colors.green : Colors.white70),
          ),
        ),
        trailing: Text('\$${ride.price}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
