import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/goal_entity.dart';
import '../../providers/goal_provider.dart';
import '../../providers/auth_provider.dart';

class AddGoalScreen extends StatefulWidget {
  final GoalEntity? goal;

  const AddGoalScreen({
    Key? key,
    this.goal,
  }) : super(key: key);

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));

  bool _isLoading = false;

  final _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  final _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();

    if (widget.goal != null) {
      _titleController.text = widget.goal!.title;
      _descriptionController.text = widget.goal!.description;
      _targetAmountController.text = _currencyFormatter.format(
        widget.goal!.targetAmount / 100,
      ).replaceAll('R\$', '').trim();
      _startDate = widget.goal!.startDate;
      _targetDate = widget.goal!.targetDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O título é obrigatório';
    }
    if (value.length > 100) {
      return 'O título deve ter no máximo 100 caracteres';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value != null && value.length > 500) {
      return 'A descrição deve ter no máximo 500 caracteres';
    }
    return null;
  }

  String? _validateTargetAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O valor alvo é obrigatório';
    }

    final cleanValue = value.replaceAll(RegExp(r'[^\d,]'), '');
    final numericValue = double.tryParse(cleanValue.replaceAll(',', '.'));

    if (numericValue == null || numericValue <= 0) {
      return 'Insira um valor válido maior que zero';
    }

    return null;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _targetDate;
    final firstDate = isStartDate
        ? DateTime(2020)
        : _startDate;
    final lastDate = DateTime(2100);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('pt', 'BR'),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          if (_targetDate.isBefore(_startDate)) {
            _targetDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _targetDate = pickedDate;
        }
      });
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_targetDate.isBefore(_startDate)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A data alvo deve ser posterior à data de início'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AppAuthProvider>();
      final goalProvider = context.read<GoalProvider>();

      final cleanValue = _targetAmountController.text.replaceAll(RegExp(r'[^\d,]'), '');
      final targetAmountInCents = (double.parse(cleanValue.replaceAll(',', '.')) * 100).toInt();

      final goal = GoalEntity(
        id: widget.goal?.id ?? '', // Firestore will generate ID on create
        userId: authProvider.user!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        targetAmount: targetAmountInCents,
        currentAmount: widget.goal?.currentAmount ?? 0,
        startDate: _startDate,
        targetDate: _targetDate,
        status: widget.goal?.status ?? GoalStatus.active,
        associatedTransactionIds: widget.goal?.associatedTransactionIds ?? [],
        createdAt: widget.goal?.createdAt ?? DateTime.now(),
        updatedAt: widget.goal != null ? DateTime.now() : null,
      );

      final success = widget.goal == null
          ? await goalProvider.createGoal(goal)
          : await goalProvider.updateGoal(goal);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.goal == null
                    ? 'Meta criada com sucesso!'
                    : 'Meta atualizada com sucesso!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(goalProvider.errorMessage ?? 'Erro ao salvar meta'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goal != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Meta' : 'Nova Meta'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título da Meta *',
                hintText: 'Ex: Ano Sabático 2026',
                prefixIcon: Icon(Icons.flag),
              ),
              validator: _validateTitle,
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Descreva sua meta',
                prefixIcon: Icon(Icons.description),
              ),
              validator: _validateDescription,
              maxLength: 500,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Target Amount Field
            TextFormField(
              controller: _targetAmountController,
              decoration: const InputDecoration(
                labelText: 'Valor Alvo *',
                hintText: '0,00',
                prefixIcon: Icon(Icons.attach_money),
                prefixText: 'R\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,]')),
              ],
              validator: _validateTargetAmount,
            ),
            const SizedBox(height: 24),

            // Date Fields
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data de Início',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(_dateFormatter.format(_startDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data Alvo',
                        prefixIcon: Icon(Icons.event),
                      ),
                      child: Text(_dateFormatter.format(_targetDate)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow(
                      'Período',
                      '${_targetDate.difference(_startDate).inDays} dias',
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Economia diária necessária',
                      _targetAmountController.text.isNotEmpty
                          ? _calculateDailySavings()
                          : 'R\$ 0,00',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveGoal,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Salvar Alterações' : 'Criar Meta'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _calculateDailySavings() {
    final cleanValue = _targetAmountController.text.replaceAll(RegExp(r'[^\d,]'), '');
    final targetAmount = double.tryParse(cleanValue.replaceAll(',', '.')) ?? 0;
    final days = _targetDate.difference(_startDate).inDays;

    if (days <= 0) return 'R\$ 0,00';

    final dailySavings = targetAmount / days;
    return _currencyFormatter.format(dailySavings);
  }
}
