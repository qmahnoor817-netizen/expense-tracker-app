import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class AddScreen extends StatefulWidget {
  final Transaction? transaction;
  const AddScreen({super.key, this.transaction});

  @override State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _customCategoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();


  List<String> _categories = ['Food', 'Travel', 'Bills', 'Shopping', 'Salary', 'Gifts','+ Add New'];
  late String _selectedCategory;
  late bool _isExpense;
  late DateTime _selectedDate;

  bool get isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final tx = widget.transaction!;
      _titleController.text = tx.title;
      _amountController.text = tx.amount.toString();
      _selectedCategory = tx.category;
      _isExpense = tx.isExpense;
      _selectedDate = tx.date;
      if (!_categories.contains(_selectedCategory)) {
        _categories.insert(_categories.length - 1, _selectedCategory);
      }
    } else {
      _selectedCategory = 'Food';
      _isExpense = true;
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _presentDatePicker() {
    FocusScope.of(context).unfocus();
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() => _selectedDate = pickedDate);
    });
  }
  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("New Category"),
        content: TextField(
          controller: _customCategoryController,
          decoration: const InputDecoration(hintText: "Category name"),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
         ElevatedButton(
            onPressed: () {
              final newCat = _customCategoryController.text.trim();
              if (newCat.isEmpty) return;
              if (_categories.contains(newCat)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category already exists')),
                );
                return;
              }
              setState(() {
                _categories.insert(_categories.length - 1, newCat);
                _selectedCategory = newCat;
              });
              _customCategoryController.clear();
              Navigator.pop(ctx);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final amount = double.parse(_amountController.text);

    if (isEditMode) {
      widget.transaction!.delete();
      final newTx = Transaction(
        id: widget.transaction!.id,
        title: title,
        amount: amount,
        date: _selectedDate,
        isExpense: _isExpense,
        category: _selectedCategory,
      );
      Hive.box<Transaction>('transactions').add(newTx);
    } else {
      final newTx = Transaction(
        id: DateTime.now().toString(),
        title: title,
        amount: amount,
        date: _selectedDate,
        isExpense: _isExpense,
        category: _selectedCategory,
      );
      Hive.box<Transaction>('transactions').add(newTx);
    }
    Navigator.pop(context);
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Transaction?"),
        content: Text('Are you sure you want to delete "${widget.transaction!.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              widget.transaction!.delete();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Transaction" : "New Transaction"),
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _delete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter description' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: "Amount", border: OutlineInputBorder()),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please enter amount';
                    if (double.tryParse(val) == null || double.parse(val) <= 0) return 'Enter valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Date: ${DateFormat.yMMMd().format(_selectedDate)}", style: const TextStyle(fontSize: 16)),
                      TextButton.icon(
                        onPressed: _presentDatePicker,
                        icon: const Icon(Icons.calendar_today, color: Colors.teal),
                        label: const Text("Choose Date", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    FocusScope.of(context).unfocus();
                    val == '+ Add New' ? _showAddCategoryDialog() : setState(() => _selectedCategory = val!); // CHANGE THIS LINE
                  },
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Transaction Type:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Switch(
                        value: _isExpense,
                        activeColor: Colors.red,
                        inactiveTrackColor: Colors.green.shade200,
                        inactiveThumbColor: Colors.green,
                        onChanged: (v) => setState(() => _isExpense = v)
                    ),
                    Text(_isExpense ? "Expense" : "Income", style: TextStyle(color: _isExpense ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                        child: Text(isEditMode ? "UPDATE TRANSACTION" : "SAVE TRANSACTION",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}