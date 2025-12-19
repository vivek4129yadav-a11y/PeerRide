import 'dart:async';
import 'dart:math';

enum TransactionStatus { pending, confirmed, failed }

class BlockchainTransaction {
  final String txHash;
  final String from;
  final String to;
  final double amount;
  final TransactionStatus status;
  final DateTime timestamp;

  BlockchainTransaction({
    required this.txHash,
    required this.from,
    required this.to,
    required this.amount,
    required this.status,
    required this.timestamp,
  });
}

class MockBlockchainService {
  final _random = Random();

  Future<String> deploySmartContract(String riderId, String driverId, double amount) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    return "0x${_random.nextInt(1000000).toRadixString(16)}...${_random.nextInt(1000000).toRadixString(16)}";
  }

  Future<BlockchainTransaction> executePayment(String from, String to, double amount) async {
    await Future.delayed(const Duration(seconds: 3));
    return BlockchainTransaction(
      txHash: "0x${_random.nextInt(1000000).toRadixString(16)}",
      from: from,
      to: to,
      amount: amount,
      status: TransactionStatus.confirmed,
      timestamp: DateTime.now(),
    );
  }

  Future<bool> verifyRideStatus(String contractAddress) async {
    await Future.delayed(const Duration(seconds: 1));
    return true; // Always verified for demo
  }
}
