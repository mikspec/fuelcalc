import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/car.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/expense_type_helper.dart';

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
            content: Text(_isEditing ? AppLocalizations.of(context)!.expenseUpdated : AppLocalizations.of(context)!.expenseAdded),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.saveError(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editExpense : l10n.addExpense),
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
              child: Text(l10n.save),
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
                    Text(
                      l10n.basicData,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: '${l10n.title} *',
                        border: OutlineInputBorder(),
                        hintText: l10n.titleHint,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.titleRequired;
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
                            decoration: InputDecoration(
                              labelText: '${l10n.cost} *',
                              border: OutlineInputBorder(),
                              suffixText: 'zł',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.required;
                              }
                              final cost = double.tryParse(value);
                              if (cost == null || cost < 0) {
                                return l10n.invalidCost;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _expenseType,
                            decoration: InputDecoration(
                              labelText: l10n.category,
                              border: OutlineInputBorder(),
                            ),
                            items: ExpenseTypeHelper.getLocalizedExpenseTypes(l10n).entries.map((entry) {
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
                    Text(
                      l10n.dateAndDetails,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(l10n.date),
                            subtitle: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
                            leading: const Icon(Icons.calendar_today),
                            onTap: _selectDate,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(l10n.time),
                            subtitle: Text(DateFormat('HH:mm').format(_selectedDate)),
                            leading: const Icon(Icons.access_time),
                            onTap: _selectTime,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.serviceRating),
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
                      decoration: InputDecoration(
                        labelText: l10n.descriptionLabel,
                        border: OutlineInputBorder(),
                        hintText: l10n.descriptionHint,
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
                  _isEditing ? l10n.updateExpense : l10n.addExpense,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}