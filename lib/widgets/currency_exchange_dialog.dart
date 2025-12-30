import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/currency_service.dart';
import '../services/settings_service.dart';
import '../l10n/app_localizations.dart';

class CurrencyExchangeDialog extends StatefulWidget {
  final String baseCurrency;
  final double? initialAmount;

  const CurrencyExchangeDialog({
    super.key,
    required this.baseCurrency,
    this.initialAmount,
  });

  @override
  State<CurrencyExchangeDialog> createState() => _CurrencyExchangeDialogState();
}

class _CurrencyExchangeDialogState extends State<CurrencyExchangeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _exchangeRateController = TextEditingController();
  final _settingsService = SettingsService();

  String? _selectedCurrency;
  double _convertedAmount = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _exchangeRateController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final currencyService = Provider.of<CurrencyService>(
      context,
      listen: false,
    );

    // Get list of currencies excluding the base currency
    final availableCurrencies = currencyService.availableCurrencies
        .where((c) => c != widget.baseCurrency)
        .toList();

    if (availableCurrencies.isNotEmpty) {
      _selectedCurrency = availableCurrencies.first;

      // Try to load saved exchange rate
      final savedRate = await _settingsService.getExchangeRate(
        _selectedCurrency!,
        widget.baseCurrency,
      );

      if (savedRate != null) {
        _exchangeRateController.text = savedRate.toStringAsFixed(4);
      }
    }

    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!.toStringAsFixed(2);
      _calculateConversion();
    }

    setState(() => _isLoading = false);
  }

  void _calculateConversion() {
    final amount = double.tryParse(_amountController.text);
    final rate = double.tryParse(_exchangeRateController.text);

    if (amount != null && rate != null && rate > 0) {
      setState(() {
        _convertedAmount = amount * rate;
      });
    } else {
      setState(() {
        _convertedAmount = 0.0;
      });
    }
  }

  Future<void> _onCurrencyChanged(String? currency) async {
    if (currency == null) return;

    setState(() {
      _selectedCurrency = currency;
    });

    // Try to load saved exchange rate for new currency
    final savedRate = await _settingsService.getExchangeRate(
      currency,
      widget.baseCurrency,
    );

    if (savedRate != null) {
      _exchangeRateController.text = savedRate.toStringAsFixed(4);
      _calculateConversion();
    }
  }

  Future<void> _onAccept() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final rate = double.parse(_exchangeRateController.text);

    // Save the exchange rate for future use
    if (_selectedCurrency != null) {
      await _settingsService.setExchangeRate(
        _selectedCurrency!,
        widget.baseCurrency,
        rate,
      );
    }

    final convertedAmount = amount * rate;

    if (mounted) {
      Navigator.pop(context, convertedAmount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyService = Provider.of<CurrencyService>(context);

    if (_isLoading) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.loading),
            ],
          ),
        ),
      );
    }

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.currency_exchange,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.currencyExchange,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Foreign currency selector
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: InputDecoration(
                  labelText: l10n.foreignCurrency,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.monetization_on),
                ),
                items: currencyService.availableCurrencies
                    .where((c) => c != widget.baseCurrency)
                    .map((currency) {
                      final info =
                          currencyService.supportedCurrencies[currency]!;
                      return DropdownMenuItem(
                        value: currency,
                        child: Text('${info['code']} - ${info['name']}'),
                      );
                    })
                    .toList(),
                onChanged: _onCurrencyChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.required;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount in foreign currency
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: l10n.amountInForeignCurrency,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: _selectedCurrency != null
                      ? currencyService
                            .supportedCurrencies[_selectedCurrency]!['symbol']
                      : '',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => _calculateConversion(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.required;
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return l10n.invalidAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Exchange rate
              TextFormField(
                controller: _exchangeRateController,
                decoration: InputDecoration(
                  labelText: l10n.exchangeRate,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.swap_horiz),
                  helperText: _selectedCurrency != null
                      ? '1 $_selectedCurrency = X ${widget.baseCurrency}'
                      : null,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => _calculateConversion(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.required;
                  }
                  final rate = double.tryParse(value);
                  if (rate == null || rate <= 0) {
                    return l10n.invalidExchangeRate;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Converted amount display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.convertedAmount,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_convertedAmount.toStringAsFixed(2)} ${currencyService.supportedCurrencies[widget.baseCurrency]!['symbol']}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _onAccept,
                    child: Text(l10n.accept),
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
