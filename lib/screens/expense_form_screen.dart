import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/car.dart';
import '../models/expense.dart';
import '../services/database_service.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Car car;
  final Expense? expense;

  const ExpenseFormScreen({super.key, required this.car, this.expense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  
  late TextEditingController _titleController;
  late TextEditingController _costController;
  late TextEditingController _informationController;
  
  DateTime _selectedDate = DateTime.now();
  int _expenseType = 0;
  int _expenseSubtype = 0;
  double _rating = 5.0;
  bool _isLoading = false;
  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _titleController = TextEditingController(text: expense?.statisticTitle ?? '');
    _costController = TextEditingController(text: expense?.statisticCost.toString() ?? '');
    _informationController = TextEditingController(text: expense?.information ?? '');
    
    if (expense != null) {
      _selectedDate = expense.date;
      _expenseType = expense.statisticType;
      _expenseSubtype = expense.statisticSubtype;
      _rating = expense.statisticRating;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    _informationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final expense = Expense(
        id: widget.expense?.id,
        date: _selectedDate,
        information: _informationController.text.trim().isNotEmpty 
            ? _informationController.text.trim() 
            : null,
        statisticTitle: _titleController.text.trim(),
        statisticCost: double.parse(_costController.text),
        statisticType: _expenseType,
        statisticSubtype: _expenseSubtype,
        statisticRating: _rating,
      );

      if (_isEditing) {
        await _databaseService.updateExpense(widget.car.carStatisticsTable, expense);
      } else {
        await _databaseService.insertExpense(widget.car.carStatisticsTable, expense);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Wydatek zaktualizowany' : 'Wydatek dodany'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd zapisu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edytuj wydatek' : 'Dodaj wydatek'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveExpense,
              child: const Text('Zapisz'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Podstawowe dane',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tytuł wydatku *',
                        border: OutlineInputBorder(),
                        hintText: 'np. Wymiana oleju',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Tytuł jest wymagany';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _costController,
                            decoration: const InputDecoration(
                              labelText: 'Koszt *',
                              border: OutlineInputBorder(),
                              suffixText: 'zł',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Wymagane';
                              }
                              final cost = double.tryParse(value);
                              if (cost == null || cost < 0) {
                                return 'Nieprawidłowy koszt';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _expenseType,
                            decoration: const InputDecoration(
                              labelText: 'Kategoria',
                              border: OutlineInputBorder(),
                            ),
                            items: Expense.expenseTypes.entries.map((entry) {
                              return DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _expenseType = value ?? 0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data i szczegóły',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Data'),
                            subtitle: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
                            leading: const Icon(Icons.calendar_today),
                            onTap: _selectDate,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('Godzina'),
                            subtitle: Text(DateFormat('HH:mm').format(_selectedDate)),
                            leading: const Icon(Icons.access_time),
                            onTap: _selectTime,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Ocena usługi'),
                    Slider(
                      value: _rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _rating.toString(),
                      onChanged: (value) => setState(() => _rating = value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _informationController,
                      decoration: const InputDecoration(
                        labelText: 'Opis/Notatki',
                        border: OutlineInputBorder(),
                        hintText: 'Dodatkowe informacje o wydatku...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!_isLoading)
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isEditing ? 'Zaktualizuj wydatek' : 'Dodaj wydatek',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}