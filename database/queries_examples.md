```markdown
# Firestore Query Examples - Hutangin

## Setup Import

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;
String get currentUserId => _auth.currentUser!.uid;

1. USERS QUERIES
1.1 Get Current User Data
dart

Future<Map<String, dynamic>?> getCurrentUser() async {
  try {
    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .get();
    
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  } catch (e) {
    print('Error getting user: $e');
    return null;
  }
}

1.2 Update User Settings
dart

Future<void> updateUserSettings({
  required bool reminderEnabled,
  required bool pushEnabled,
  required bool waEnabled,
  required int reminderHour,
  required String currency,
}) async {
  await _firestore.collection('users').doc(currentUserId).update({
    'settings.reminderEnabled': reminderEnabled,
    'settings.pushEnabled': pushEnabled,
    'settings.waEnabled': waEnabled,
    'settings.reminderHour': reminderHour,
    'settings.currency': currency,
    'lastLogin': FieldValue.serverTimestamp(),
  });
}

1.3 Update Last Login
dart

Future<void> updateLastLogin() async {
  await _firestore.collection('users').doc(currentUserId).update({
    'lastLogin': FieldValue.serverTimestamp(),
  });
}

2. DEBTORS QUERIES
2.1 Get All Debtors for Current User
dart

Stream<QuerySnapshot> getAllDebtors() {
  return _firestore
      .collection('debtors')
      .where('userId', isEqualTo: currentUserId)
      .orderBy('name')
      .snapshots();
}

2.2 Search Debtor by Name
dart

Future<QuerySnapshot> searchDebtorByName(String searchText) async {
  // Firestore doesn't support full-text search natively
  // Use startAt/endAt for prefix search
  return await _firestore
      .collection('debtors')
      .where('userId', isEqualTo: currentUserId)
      .where('name', isGreaterThanOrEqualTo: searchText)
      .where('name', isLessThanOrEqualTo: searchText + '\uf8ff')
      .limit(20)
      .get();
}

2.3 Get Debtors Sorted by Rating
dart

Stream<QuerySnapshot> getDebtorsByRating() {
  return _firestore
      .collection('debtors')
      .where('userId', isEqualTo: currentUserId)
      .orderBy('ratingAvg', descending: true)
      .snapshots();
}

2.4 Get Top 5 Most Frequently Borrowed Debtors
dart

Future<QuerySnapshot> getTopDebtors() async {
  return await _firestore
      .collection('debtors')
      .where('userId', isEqualTo: currentUserId)
      .orderBy('totalTransactions', descending: true)
      .limit(5)
      .get();
}

2.5 Create New Debtor
dart

Future<String> createDebtor({
  required String name,
  String? phone,
  String? email,
}) async {
  DocumentReference docRef = await _firestore.collection('debtors').add({
    'userId': currentUserId,
    'name': name,
    'phone': phone ?? '',
    'email': email ?? '',
    'ratingAvg': 0.0,
    'totalTransactions': 0,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  
  return docRef.id;
}

2.6 Update Debtor
dart

Future<void> updateDebtor({
  required String debtorId,
  String? name,
  String? phone,
  String? email,
}) async {
  Map<String, dynamic> updates = {
    'updatedAt': FieldValue.serverTimestamp(),
  };
  
  if (name != null) updates['name'] = name;
  if (phone != null) updates['phone'] = phone;
  if (email != null) updates['email'] = email;
  
  await _firestore
      .collection('debtors')
      .doc(debtorId)
      .update(updates);
}

2.7 Delete Debtor (Only if no transactions)
dart

Future<bool> deleteDebtor(String debtorId) async {
  try {
    // Check if debtor has any transactions
    final activeTransactions = await _firestore
        .collection('transactions_active')
        .where('debtorId', isEqualTo: debtorId)
        .limit(1)
        .get();
    
    final archivedTransactions = await _firestore
        .collection('transactions_archived')
        .where('debtorId', isEqualTo: debtorId)
        .limit(1)
        .get();
    
    if (activeTransactions.docs.isEmpty && archivedTransactions.docs.isEmpty) {
      await _firestore.collection('debtors').doc(debtorId).delete();
      return true;
    }
    return false;
  } catch (e) {
    print('Error deleting debtor: $e');
    return false;
  }
}

3. TRANSACTIONS ACTIVE QUERIES
3.1 Get All Active Debts
dart

Stream<QuerySnapshot> getAllActiveDebts() {
  return _firestore
      .collection('transactions_active')
      .where('userId', isEqualTo: currentUserId)
      .orderBy('deadline')
      .snapshots();
}

3.2 Get Active Debts by Status
dart

Stream<QuerySnapshot> getActiveDebtsByStatus(String status) {
  return _firestore
      .collection('transactions_active')
      .where('userId', isEqualTo: currentUserId)
      .where('status', isEqualTo: status)
      .orderBy('deadline')
      .snapshots();
}

3.3 Get Overdue Debts
dart

Stream<QuerySnapshot> getOverdueDebts() {
  final now = Timestamp.now();
  return _firestore
      .collection('transactions_active')
      .where('userId', isEqualTo: currentUserId)
      .where('status', isEqualTo: 'pending')
      .where('deadline', isLessThan: now)
      .orderBy('deadline')
      .snapshots();
}

3.4 Get Debts by Debtor
dart

Stream<QuerySnapshot> getDebtsByDebtor(String debtorId) {
  return _firestore
      .collection('transactions_active')
      .where('userId', isEqualTo: currentUserId)
      .where('debtorId', isEqualTo: debtorId)
      .orderBy('deadline')
      .snapshots();
}

3.5 Create New Debt
dart

Future<String> createDebt({
  required String debtorId,
  required String debtorName,
  required int amount,
  required double interestRate,
  required String interestType,
  required DateTime deadline,
  String? notes,
}) async {
  DocumentReference docRef = await _firestore.collection('transactions_active').add({
    'userId': currentUserId,
    'debtorId': debtorId,
    'debtorName': debtorName,
    'amount': amount,
    'interestRate': interestRate,
    'interestType': interestType,
    'deadline': Timestamp.fromDate(deadline),
    'status': 'pending',
    'notes': notes ?? '',
    'reminderCount': 0,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  
  // Update debtor's total transaction count
  await _firestore.collection('debtors').doc(debtorId).update({
    'totalTransactions': FieldValue.increment(1),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  
  return docRef.id;
}

3.6 Mark Debt as Paid
dart

Future<void> markDebtAsPaid({
  required String transactionId,
  required int totalPaid,
  required int interestAccrued,
  required int rating,
  String? review,
}) async {
  // Get the active debt first
  final debtDoc = await _firestore
      .collection('transactions_active')
      .doc(transactionId)
      .get();
  
  if (!debtDoc.exists) return;
  
  final debtData = debtDoc.data()!;
  
  // Create archived document
  await _firestore.collection('transactions_archived').doc(transactionId).set({
    ...debtData,
    'status': 'paid',
    'paidAt': FieldValue.serverTimestamp(),
    'totalPaid': totalPaid,
    'interestAccrued': interestAccrued,
    'rating': rating,
    'review': review ?? '',
  });
  
  // Delete from active
  await _firestore
      .collection('transactions_active')
      .doc(transactionId)
      .delete();
  
  // Save rating
  await _firestore.collection('ratings').add({
    'transactionId': transactionId,
    'debtorId': debtData['debtorId'],
    'userId': currentUserId,
    'rating': rating,
    'review': review ?? '',
    'createdAt': FieldValue.serverTimestamp(),
  });
  
  // Update debtor's average rating
  await _updateDebtorRating(debtData['debtorId']);
}

3.7 Update Debtor Rating (Helper)
dart

Future<void> _updateDebtorRating(String debtorId) async {
  // Get all ratings for this debtor
  final ratingsSnapshot = await _firestore
      .collection('ratings')
      .where('debtorId', isEqualTo: debtorId)
      .get();
  
  if (ratingsSnapshot.docs.isEmpty) return;
  
  double totalRating = 0;
  for (var doc in ratingsSnapshot.docs) {
    totalRating += (doc.data()['rating'] as num).toDouble();
  }
  
  final avgRating = totalRating / ratingsSnapshot.docs.length;
  
  await _firestore.collection('debtors').doc(debtorId).update({
    'ratingAvg': avgRating,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

4. TRANSACTIONS ARCHIVED QUERIES
4.1 Get Archived Debts by Month
dart

Future<QuerySnapshot> getArchivedDebtsByMonth(DateTime month) async {
  final startOfMonth = DateTime(month.year, month.month, 1);
  final endOfMonth = DateTime(month.year, month.month + 1, 1);
  
  return await _firestore
      .collection('transactions_archived')
      .where('userId', isEqualTo: currentUserId)
      .where('paidAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
      .where('paidAt', isLessThan: Timestamp.fromDate(endOfMonth))
      .orderBy('paidAt', descending: true)
      .get();
}

4.2 Get Archived Debts Summary
dart

Future<Map<String, dynamic>> getArchivedSummary() async {
  final snapshot = await _firestore
      .collection('transactions_archived')
      .where('userId', isEqualTo: currentUserId)
      .get();
  
  int totalDebt = 0;
  int totalPaid = 0;
  int totalInterest = 0;
  double avgRating = 0;
  
  for (var doc in snapshot.docs) {
    final data = doc.data();
    totalDebt += data['amount'] as int;
    totalPaid += data['totalPaid'] as int;
    totalInterest += data['interestAccrued'] as int;
    avgRating += (data['rating'] as num).toDouble();
  }
  
  if (snapshot.docs.isNotEmpty) {
    avgRating = avgRating / snapshot.docs.length;
  }
  
  return {
    'totalTransactions': snapshot.docs.length,
    'totalDebt': totalDebt,
    'totalPaid': totalPaid,
    'totalInterest': totalInterest,
    'avgRating': avgRating,
  };
}

5. REMINDER LOGS QUERIES
5.1 Get Reminder Logs for a Transaction
dart

Stream<QuerySnapshot> getReminderLogs(String transactionId) {
  return _firestore
      .collection('reminder_logs')
      .where('transactionId', isEqualTo: transactionId)
      .orderBy('sentAt', descending: true)
      .snapshots();
}

5.2 Get Last Reminder for a Transaction
dart

Future<QueryDocumentSnapshot?> getLastReminder(String transactionId) async {
  final snapshot = await _firestore
      .collection('reminder_logs')
      .where('transactionId', isEqualTo: transactionId)
      .orderBy('sentAt', descending: true)
      .limit(1)
      .get();
  
  if (snapshot.docs.isNotEmpty) {
    return snapshot.docs.first;
  }
  return null;
}

6. BLOCKED DEBTORS QUERIES
6.1 Get All Blocked Debtors
dart

Stream<QuerySnapshot> getBlockedDebtors() {
  return _firestore
      .collection('blocked_debtors')
      .where('userId', isEqualTo: currentUserId)
      .snapshots();
}

6.2 Check if Debtor is Blocked
dart

Future<bool> isDebtorBlocked(String debtorId) async {
  final snapshot = await _firestore
      .collection('blocked_debtors')
      .where('userId', isEqualTo: currentUserId)
      .where('debtorId', isEqualTo: debtorId)
      .limit(1)
      .get();
  
  return snapshot.docs.isNotEmpty;
}

6.3 Block Debtor
dart

Future<void> blockDebtor(String debtorId, String reason) async {
  await _firestore.collection('blocked_debtors').add({
    'userId': currentUserId,
    'debtorId': debtorId,
    'reason': reason,
    'blockedAt': FieldValue.serverTimestamp(),
  });
}

6.4 Unblock Debtor
dart

Future<void> unblockDebtor(String blockId) async {
  await _firestore.collection('blocked_debtors').doc(blockId).delete();
}

7. REAL-TIME LISTENERS (Streams)
7.1 Dashboard Stream - All Active Debts
dart

Stream<List<Map<String, dynamic>>> getDashboardStream() {
  return _firestore
      .collection('transactions_active')
      .where('userId', isEqualTo: currentUserId)
      .orderBy('deadline')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data(),
          };
        }).toList();
      });
}

7.2 Combined Stream - Active Debts + Debtor Details
dart

Stream<List<Map<String, dynamic>>> getDashboardWithDebtorDetails() {
  return _firestore
      .collection('transactions_active')
      .where('userId', isEqualTo: currentUserId)
      .orderBy('deadline')
      .snapshots()
      .asyncMap((snapshot) async {
        List<Map<String, dynamic>> results = [];
        
        for (var doc in snapshot.docs) {
          final debtData = doc.data();
          final debtorDoc = await _firestore
              .collection('debtors')
              .doc(debtData['debtorId'])
              .get();
          
          results.add({
            'id': doc.id,
            ...debtData,
            'debtorDetails': debtorDoc.data(),
          });
        }
        
        return results;
      });
}

8. BATCH OPERATIONS
8.1 Batch Delete Old Reminder Logs
dart

Future<void> cleanupOldReminderLogs() async {
  final cutoffDate = Timestamp.fromDate(
    DateTime.now().subtract(Duration(days: 90))
  );
  
  final snapshot = await _firestore
      .collection('reminder_logs')
      .where('sentAt', isLessThan: cutoffDate)
      .limit(100)
      .get();
  
  final batch = _firestore.batch();
  for (var doc in snapshot.docs) {
    batch.delete(doc.reference);
  }
  
  await batch.commit();
}

8.2 Batch Update All Overdue Statuses
dart

Future<void> updateOverdueStatuses() async {
  final now = Timestamp.now();
  
  final snapshot = await _firestore
      .collection('transactions_active')
      .where('userId', isEqualTo: currentUserId)
      .where('status', isEqualTo: 'pending')
      .where('deadline', isLessThan: now)
      .get();
  
  final batch = _firestore.batch();
  for (var doc in snapshot.docs) {
    batch.update(doc.reference, {
      'status': 'overdue',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  await batch.commit();
}