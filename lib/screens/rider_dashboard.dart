import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ride_provider.dart';
import '../models/ride_model.dart';
import 'package:intl/intl.dart';

class RiderDashboard extends StatelessWidget {
  const RiderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final rideProvider = context.watch<RideProvider>();
    final rides = rideProvider.rides;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Ride'),
        actions: [IconButton(icon: const Icon(Icons.account_balance_wallet_outlined), onPressed: () {})],
      ),
      body: rideProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rides.length,
              itemBuilder: (context, index) {
                final ride = rides[index];
                return _RideCard(ride: ride);
              },
            ),
    );
  }
}

class _RideCard extends StatelessWidget {
  final Ride ride;

  const _RideCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    final isBooked = ride.status == RideStatus.booked;
    final isCompleted = ride.status == RideStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      child: Text(ride.driver.name[0]),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ride.driver.name, style: Theme.of(context).textTheme.titleMedium),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            Text(' ${ride.driver.rating}', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '\$${ride.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                const Column(
                  children: [
                    Icon(Icons.radio_button_checked, size: 18, color: Colors.blue),
                    SizedBox(height: 4, child: VerticalDivider(width: 1)),
                    Icon(Icons.location_on, size: 18, color: Colors.red),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.origin, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      Text(ride.destination, style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM d, h:mm a').format(ride.departureTime),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text('${ride.availableSeats} seats left', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Price Transparency',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: Colors.white10),
                  _buildTransparencyRow(
                    context,
                    'Actual Driving Cost (Fuel/Maint)',
                    '\$${(ride.price * 0.4).toStringAsFixed(2)}',
                    Icons.local_gas_station,
                  ),
                  _buildTransparencyRow(
                    context,
                    'Driver Earnings (100% P2P)',
                    '\$${ride.price.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                    isHighlight: true,
                  ),
                  _buildTransparencyRow(
                    context,
                    'Your Savings (No Platform Fee)',
                    '\$${(ride.price * 0.25).toStringAsFixed(2)}',
                    Icons.savings,
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            if (ride.contractAddress != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user, size: 14, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Smart Contract: ${ride.contractAddress}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCompleted
                    ? null
                    : () {
                        if (isBooked) {
                          context.read<RideProvider>().completeRide(ride.id);
                        } else {
                          context.read<RideProvider>().bookRide(ride.id);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBooked ? Colors.orange : (isCompleted ? Colors.grey : null),
                ),
                child: Text(
                  isBooked ? 'Complete Ride & Release Funds' : (isCompleted ? 'Ride Completed' : 'Book Ride'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransparencyRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: isHighlight ? Theme.of(context).colorScheme.secondary : Colors.white60),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, color: isHighlight ? Colors.white : Colors.white60)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Theme.of(context).colorScheme.secondary : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
