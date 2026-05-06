import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import 'add_screen.dart';
import 'chart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  List<Transaction> _getMonthTransactions(Box<Transaction> box) {
    return box.values.where((tx) {
      return tx.date.year == _selectedMonth.year &&
          tx.date.month == _selectedMonth.month;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Map<String, double> _getMonthTotals(Box<Transaction> box) {
    double income = 0;
    double expense = 0;

    final currentMonthTxs = _getMonthTransactions(box);
    for (var tx in currentMonthTxs) {
      if (tx.isExpense) {
        expense += tx.amount;
      } else {
        income += tx.amount;
      }
    }

    final prevMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    final prevMonthTxs = box.values.where((tx) {
      return tx.date.year == prevMonth.year && tx.date.month == prevMonth.month;
    });

    double prevBalance = 0;
    for (var tx in prevMonthTxs) {
      prevBalance += tx.isExpense ? -tx.amount : tx.amount;
    }

    if (prevBalance < 0) prevBalance = 0;

    final currentBalance = income - expense;
    final totalBalance = currentBalance + prevBalance;

    return {
      'income': income,
      'expense': expense,
      'balance': totalBalance,
      'prevBalance': prevBalance
    };
  }

  void _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() => _selectedMonth = DateTime(picked.year, picked.month));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
            ),
            child: InkWell(
              onTap: _pickMonth,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month, color: Colors.teal, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat.yMMM().format(_selectedMonth),
                    style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChartScreen(selectedMonth: _selectedMonth),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Transaction>('transactions').listenable(),
        builder: (context, Box<Transaction> box, _) {
          final monthTxs = _getMonthTransactions(box);
          final totals = _getMonthTotals(box);

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.teal.shade800,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [
                      const Text("Income", style: TextStyle(color: Colors.white70)),
                      Text(" ${totals['income']!.toStringAsFixed(0)}",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ]),
                    Column(children: [
                      const Text("Expense", style: TextStyle(color: Colors.white70)),
                      Text(" ${totals['expense']!.toStringAsFixed(0)}",
                          style: const TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
                    ]),
                    Column(children: [
                      const Text("Balance", style: TextStyle(color: Colors.white70)),
                      Text(" ${totals['balance']!.toStringAsFixed(0)}",
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                      if (totals['prevBalance']! > 0)
                        Text("+${totals['prevBalance']!.toStringAsFixed(0)} prev",
                            style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ]),
                  ],
                ),
              ),

              Expanded(
                child: monthTxs.isEmpty
                    ? Center(child: Text("No transactions in ${DateFormat.yMMM().format(_selectedMonth)}"))
                    : ListView.builder(
                  itemCount: monthTxs.length,
                  itemBuilder: (ctx, i) {
                    final t = monthTxs[i];
                    return ListTile(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => AddScreen(transaction: t))),
                      leading: CircleAvatar(
                        backgroundColor: t.isExpense ? Colors.red.shade50 : Colors.green.shade50,
                        child: Icon(t.isExpense ? Icons.shopping_bag : Icons.attach_money,
                            color: t.isExpense ? Colors.red : Colors.green),
                      ),
                      title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${t.category} • ${DateFormat.yMMMd().format(t.date)}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${t.isExpense ? '-' : '+'}  ${t.amount.toStringAsFixed(0)}",
                            style: TextStyle(
                                color: t.isExpense ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.edit, size: 18, color: Colors.grey),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}