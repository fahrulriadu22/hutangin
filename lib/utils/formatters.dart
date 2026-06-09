import 'package:intl/intl.dart';

class Formatters {
  static String formatRupiah(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
  
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
  
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }
  
  static int calculateDaysLeft(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inDays;
  }
  
  static int calculateTotalWithInterest(int amount, double rate, String type, int daysOverdue) {
    if (rate == 0) return amount;
    
    double interest = 0;
    if (type == 'daily') {
      interest = amount * (rate / 100) * daysOverdue;
    } else if (type == 'monthly') {
      interest = amount * (rate / 100) * (daysOverdue / 30);
    }
    
    return amount + interest.floor();
  }
}