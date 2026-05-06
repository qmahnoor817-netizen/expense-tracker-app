import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Spending Analysis")),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Transaction>('transactions').listenable(),
        builder: (context, Box<Transaction> box, _) {
          final expenseTransactions = box.values
              .where((t) => t.isExpense)
              .toList();

          if (expenseTransactions.isEmpty) {
            return const Center(child: Text("No expenses to analyze"));
          }


          final categories = expenseTransactions
              .map((t) => t.category)
              .toSet()
              .toList();


          final maxSpent = expenseTransactions.fold<double>(0, (max, t) {
            final catTotal = expenseTransactions
                .where((e) => e.category == t.category)
                .fold<double>(0, (sum, e) => sum + e.amount);
            return catTotal > max ? catTotal : max;
          });

          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Breakdown by Category",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ...categories.map((cat) {
                // 3. Calculate total for this category
                final catTotal = expenseTransactions
                    .where((t) => t.category == cat)
                    .fold<double>(0, (sum, t) => sum + t.amount);

                // 4. Safe progress: avoid divide by zero
                final progress = maxSpent > 0 ? catTotal / maxSpent : 0.0;

                return ListTile(
                  title: Text(cat),
                  trailing: Text(
                    " ${catTotal.toStringAsFixed(0)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: LinearProgressIndicator(
                      value: progress,
                      color: Colors.teal,
                      backgroundColor: Colors.teal.withOpacity(0.2),
                      minHeight: 6,
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}