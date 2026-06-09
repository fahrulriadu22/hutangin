```markdown
# Firestore Composite Indexes - Hutangin

## Required Indexes

### 1. Transactions Active - Dashboard Query
Digunakan untuk mengambil semua hutang aktif user di dashboard, diurutkan berdasarkan deadline.

```json
{
  "collectionId": "transactions_active",
  "description": "Get all active debts for a user ordered by deadline",
  "fields": [
    { "fieldPath": "userId", "mode": "ASCENDING" },
    { "fieldPath": "status", "mode": "ASCENDING" },
    { "fieldPath": "deadline", "mode": "ASCENDING" }
  ]
}
```
Used in queries:
dart

_firestore
  .collection('transactions_active')
  .where('userId', isEqualTo: currentUserId)
  .where('status', isEqualTo: 'pending')
  .orderBy('deadline')
  .get()

2. Transactions Active - Overdue Filter

Digunakan untuk mengambil hutang yang sudah melewati deadline.
json

{
  "collectionId": "transactions_active",
  "description": "Get overdue debts for a user",
  "fields": [
    { "fieldPath": "userId", "mode": "ASCENDING" },
    { "fieldPath": "status", "mode": "ASCENDING" },
    { "fieldPath": "deadline", "mode": "ASCENDING" }
  ]
}

Note: Sama dengan index #1, cukup satu index untuk kedua query.
3. Transactions Active - By Debtor

Digunakan untuk mengambil semua hutang aktif dari satu debitur tertentu.
json

{
  "collectionId": "transactions_active",
  "description": "Get all active debts for a specific debtor",
  "fields": [
    { "fieldPath": "userId", "mode": "ASCENDING" },
    { "fieldPath": "debtorId", "mode": "ASCENDING" },
    { "fieldPath": "deadline", "mode": "ASCENDING" }
  ]
}

Used in queries:
dart

_firestore
  .collection('transactions_active')
  .where('userId', isEqualTo: currentUserId)
  .where('debtorId', isEqualTo: debtorId)
  .orderBy('deadline')
  .get()

4. Transactions Archived - By Paid Date

Digunakan untuk mengambil arsip hutang berdasarkan bulan/tahun.
json

{
  "collectionId": "transactions_archived",
  "description": "Get archived debts by paid date (for monthly reports)",
  "fields": [
    { "fieldPath": "userId", "mode": "ASCENDING" },
    { "fieldPath": "paidAt", "mode": "DESCENDING" }
  ]
}

Used in queries:
dart

_firestore
  .collection('transactions_archived')
  .where('userId', isEqualTo: currentUserId)
  .where('paidAt', isGreaterThanOrEqualTo: startOfMonth)
  .where('paidAt', isLessThan: endOfMonth)
  .orderBy('paidAt', descending: true)
  .get()

5. Transactions Archived - By Rating

Digunakan untuk laporan rating debitur.
json

{
  "collectionId": "transactions_archived",
  "description": "Get archived debts sorted by rating (for analytics)",
  "fields": [
    { "fieldPath": "userId", "mode": "ASCENDING" },
    { "fieldPath": "rating", "mode": "DESCENDING" }
  ]
}

Used in queries:
dart

_firestore
  .collection('transactions_archived')
  .where('userId', isEqualTo: currentUserId)
  .orderBy('rating', descending: true)
  .limit(10)
  .get()

6. Debtors - By Rating

Digunakan untuk menampilkan debitur dengan rating tertinggi.
json

{
  "collectionId": "debtors",
  "description": "Get debtors sorted by rating (best payers first)",
  "fields": [
    { "fieldPath": "userId", "mode": "ASCENDING" },
    { "fieldPath": "ratingAvg", "mode": "DESCENDING" }
  ]
}

Used in queries:
dart

_firestore
  .collection('debtors')
  .where('userId', isEqualTo: currentUserId)
  .orderBy('ratingAvg', descending: true)
  .get()

7. Debtors - By Total Transactions

Digunakan untuk menampilkan debitur yang paling sering meminjam.
json

{
  "collectionId": "debtors",
  "description": "Get debtors by frequency of borrowing",
  "fields": [
    { "fieldPath": "userId", "mode": "ASCENDING" },
    { "fieldPath": "totalTransactions", "mode": "DESCENDING" }
  ]
}

Used in queries:
dart

_firestore
  .collection('debtors')
  .where('userId', isEqualTo: currentUserId)
  .orderBy('totalTransactions', descending: true)
  .limit(5)
  .get()

8. Reminder Logs - By Transaction

Digunakan untuk melihat history reminder suatu hutang.
json

{
  "collectionId": "reminder_logs",
  "description": "Get all reminder logs for a specific transaction",
  "fields": [
    { "fieldPath": "transactionId", "mode": "ASCENDING" },
    { "fieldPath": "sentAt", "mode": "DESCENDING" }
  ]
}

Used in queries:
dart

_firestore
  .collection('reminder_logs')
  .where('transactionId', isEqualTo: transactionId)
  .orderBy('sentAt', descending: true)
  .get()

9. Reminder Logs - Cleanup Old Logs

Digunakan untuk menghapus reminder log yang lebih dari 90 hari.
json

{
  "collectionId": "reminder_logs",
  "description": "Get old reminder logs for cleanup (older than 90 days)",
  "fields": [
    { "fieldPath": "sentAt", "mode": "ASCENDING" }
  ]
}

Used in queries:
dart

_firestore
  .collection('reminder_logs')
  .where('sentAt', isLessThan: cutoffDate)
  .limit(100)
  .get()

10. Ratings - By Debtor

Digunakan untuk menghitung rata-rata rating debitur.
json

{
  "collectionId": "ratings",
  "description": "Get all ratings for a specific debtor",
  "fields": [
    { "fieldPath": "debtorId", "mode": "ASCENDING" },
    { "fieldPath": "createdAt", "mode": "ASCENDING" }
  ]
}

Used in queries:
dart

_firestore
  .collection('ratings')
  .where('debtorId', isEqualTo: debtorId)
  .get()