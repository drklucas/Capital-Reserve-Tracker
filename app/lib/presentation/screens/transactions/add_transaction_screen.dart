import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';

/// Screen for adding a new transaction
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  TransactionCategory _category = TransactionCategory.food;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Transação'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Type selector
                Text(
                  'Tipo de Transação',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Receita'),
                      icon: Icon(Icons.arrow_upward),
                    ),
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Despesa'),
                      icon: Icon(Icons.arrow_downward),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (Set<TransactionType> newSelection) {
                    setState(() {
                      _type = newSelection.first;
                      // Reset category to appropriate default
                      _category = _type == TransactionType.income
                          ? TransactionCategory.salary
                          : TransactionCategory.food;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Ex: Supermercado, Salário...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'A descrição é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Amount field
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    hintText: '0,00',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O valor é obrigatório';
                    }
                    final amount = double.tryParse(value.replaceAll(',', '.'));
                    if (amount == null || amount <= 0) {
                      return 'Digite um valor válido maior que zero';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category selector
                DropdownButtonFormField<TransactionCategory>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _getAvailableCategories()
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.displayName),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _category = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Date picker
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/'
                      '${_selectedDate.month.toString().padLeft(2, '0')}/'
                      '${_selectedDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save button
                Consumer<TransactionProvider>(
                  builder: (context, provider, _) {
                    if (provider.status == TransactionStatus.creating) {
                      return const LoadingIndicator();
                    }

                    return CustomButton(
                      onPressed: _saveTransaction,
                      text: 'Salvar Transação',
                      isFullWidth: true,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<TransactionCategory> _getAvailableCategories() {
    if (_type == TransactionType.income) {
      return [
        TransactionCategory.salary,
        TransactionCategory.bonus,
        TransactionCategory.investment,
        TransactionCategory.freelance,
        TransactionCategory.gift,
        TransactionCategory.other,
      ];
    } else {
      return [
        TransactionCategory.food,
        TransactionCategory.transport,
        TransactionCategory.housing,
        TransactionCategory.utilities,
        TransactionCategory.entertainment,
        TransactionCategory.healthcare,
        TransactionCategory.education,
        TransactionCategory.shopping,
        TransactionCategory.savings,
      ];
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AppAuthProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    if (authProvider.user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário não autenticado'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final amount = double.parse(_amountController.text.replaceAll(',', '.'));

    final success = await transactionProvider.createTransaction(
      userId: authProvider.user!.id,
      type: _type,
      amount: amount,
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      category: _category,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              transactionProvider.errorMessage ?? 'Erro ao criar transação',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
