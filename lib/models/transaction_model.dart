import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String userId;
  final String debtorId;
  final String debtorName;
  final int amount;
  final double interestRate;
  final String interestType;
  final DateTime deadline;
  final String status;
  final String notes;
  final int reminderCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastReminderAt;
  
  Transaction({
    required this.id,
    required this.userId,
    required this.debtorId,
    required this.debtorName,
    required this.amount,
    required this.interestRate,
    required this.interestType,
    required this.deadline,
    required this.status,
    required this.notes,
    required this.reminderCount,
    required this.createdAt,
    required this.updatedAt,
    this.lastReminderAt,
  });
  
  int get daysUntilDeadline {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inDays;
  }
  
  int get totalWithInterest {
    if (interestRate == 0) return amount;
    
    final daysOverdue = daysUntilDeadline < 0 ? -daysUntilDeadline : 0;
    
    double interest = 0;
    if (interestType == 'daily') {
      interest = amount * (interestRate / 100) * daysOverdue;
    } else if (interestType == 'monthly') {
      interest = amount * (interestRate / 100) * (daysOverdue / 30);
    }
    
    return amount + interest.floor();
  }
  
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      debtorId: data['debtorId'] ?? '',
      debtorName: data['debtorName'] ?? '',
      amount: (data['amount'] ?? 0).toInt(),
      interestRate: (data['interestRate'] ?? 0).toDouble(),
      interestType: data['interestType'] ?? 'none',
      deadline: (data['deadline'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      notes: data['notes'] ?? '',
      reminderCount: (data['reminderCount'] ?? 0).toInt(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastReminderAt: data['lastReminderAt'] != null 
          ? (data['lastReminderAt'] as Timestamp).toDate() 
          : null,
    );
  }
}