# Firestore Database Structure - Hutangin

## Collections Overview

| Collection | Purpose | Document ID |
|------------|---------|-------------|
| `users` | Data pengguna | `userId` (auto) |
| `debtors` | Data orang yang berhutang | `debtorId` (auto) |
| `transactions_active` | Hutang yang belum lunas | `transactionId` (auto) |
| `transactions_archived` | Hutang yang sudah lunas | `transactionId` (auto) |
| `reminder_logs` | Log pengiriman reminder | `logId` (auto) |
| `ratings` | Rating debitur | `ratingId` (auto) |
| `blocked_debtors` | Debitur yang diblokir | `blockId` (auto) |

---

## 1. Users Collection

**Path:** `users/{userId}`

```json
{
  "email": "user@example.com",
  "name": "Budi Santoso",
  "photoUrl": "https://...",
  "createdAt": Timestamp,
  "lastLogin": Timestamp,
  "settings": {
    "reminderEnabled": true,
    "pushEnabled": true,
    "waEnabled": true,
    "reminderHour": 8,
    "currency": "IDR"
  }
}
```
### Security Rules:

    Hanya user yang login bisa baca/tulis dokumen mereka sendiri

    userId harus match dengan request.auth.uid

## 2. Debtors Collection

**Path:** `debtors/{debtorId}`

```json
{
  "userId": "userId_foreign_key",
  "name": "Ani Wijaya",
  "phone": "+6281234567890",
  "email": "ani@example.com",
  "ratingAvg": 4.2,
  "totalTransactions": 5,
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```
### Indexes:

    userId + name (untuk search)

    userId + ratingAvg (untuk sorting)

## 3. Transactions Active Collection

**Path:** `transactions_active/{transactionId}`

```json
{
  "userId": "userId_foreign_key",
  "debtorId": "debtorId_foreign_key",
  "debtorName": "Ani Wijaya",
  "amount": 500000,
  "interestRate": 1,
  "interestType": "daily",
  "deadline": Timestamp,
  "status": "pending",
  "notes": "Buat beli HP",
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "reminderCount": 3,
  "lastReminderAt": Timestamp
}
```
### Interest Type Values:

    none = tanpa bunga

    daily = bunga per hari

    monthly = bunga per bulan

### Status Values:

    pending = masih dalam masa tenggat

    overdue = melewati deadline

    paid = sudah lunas (langsung pindah ke archived)

### Indexes:

    userId + status + deadline (untuk cron job reminder)

    userId + status + createdAt

## 4. Transactions Archived Collection

**Path:** `transactions_archived/{transactionId}`

```json
{
  "userId": "userId_foreign_key",
  "debtorId": "debtorId_foreign_key",
  "debtorName": "Ani Wijaya",
  "amount": 500000,
  "interestRate": 1,
  "interestType": "daily",
  "deadline": Timestamp,
  "status": "paid",
  "notes": "Buat beli HP",
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "paidAt": Timestamp,
  "totalPaid": 510000,
  "interestAccrued": 10000,
  "rating": 5,
  "review": "Bayar tepat waktu"
}
```
### Indexes:

    userId + paidAt (untuk filter arsip per bulan)

    userId + rating (untuk laporan)

## 5. Reminder Logs Collection

**Path:** `reminder_logs/{logId}`

```json
{
  "transactionId": "foreign_key",
  "userId": "foreign_key",
  "debtorId": "foreign_key",
  "sentAt": Timestamp,
  "type": "wa",
  "status": "sent",
  "errorMessage": null,
  "daysBeforeDeadline": -3
}
```
### Type Values:

    push = Push notification

    wa = WhatsApp

    sms = SMS

    robocall = Panggilan suara otomatis

    email = Email

### Status Values:

    sent = Berhasil terkirim

    failed = Gagal

    pending = Dalam antrian

## 6. Ratings Collection

**Path:** `ratings/{ratingId}`

```json
{
  "transactionId": "foreign_key",
  "debtorId": "foreign_key",
  "rating": 4,
  "review": "Lumayan telat 2 hari tapi bayar",
  "createdAt": Timestamp
}
```

## 7. Blocked Debtors Collection

**Path:** `blocked_debtors/{blockId}`

```json
{
  "userId": "foreign_key",
  "debtorId": "foreign_key",
  "reason": "Tidak merespon setelah 5x reminder",
  "blockedAt": Timestamp
}
```