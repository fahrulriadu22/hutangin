import 'package:flutter/material.dart';
import '../utils/formatters.dart';
import '../models/transaction_model.dart';

class DebtCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;
  final VoidCallback onRemind;
  final VoidCallback onMarkPaid;
  
  const DebtCard({
    super.key,
    required this.transaction,
    required this.onTap,
    required this.onRemind,
    required this.onMarkPaid,
  });
  
  @override
  Widget build(BuildContext context) {
    final daysLeft = transaction.daysUntilDeadline;
    final isOverdue = daysLeft < 0;
    final statusColor = isOverdue ? Colors.red : Colors.orange;
    final statusText = isOverdue 
        ? 'Telat ${-daysLeft} hari' 
        : 'Sisa $daysLeft hari';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      transaction.debtorName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    Formatters.formatRupiah(transaction.amount),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isOverdue && transaction.interestRate > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        Formatters.formatRupiah(transaction.totalWithInterest),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.formatDate(transaction.deadline),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  if (transaction.interestRate > 0)
                    Row(
                      children: [
                        const Icon(Icons.trending_up, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${transaction.interestRate}% ${transaction.interestType == 'daily' ? '/hari' : '/bulan'}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onRemind,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('💬 Remind'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onMarkPaid,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('✅ Lunas'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}