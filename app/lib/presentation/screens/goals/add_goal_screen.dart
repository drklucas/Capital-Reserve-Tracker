import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/goal_entity.dart';
import '../../providers/goal_provider.dart';
import '../../providers/auth_provider.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  final GoalEntity? goal;

  const AddGoalScreen({
    super.key,
    this.goal,
  });

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
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
        : _startDate.add(const Duration(days: 1));
    final lastDate = DateTime(2100);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          if (_targetDate.isBefore(_startDate)) {
            _targetDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _targetDate = pickedDate;
        }
      });
    }
  }

  int _parseAmountToCents(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^\d,]'), '');
    final numericValue = double.parse(cleanValue.replaceAll(',', '.'));
    return (numericValue * 100).round();
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = ref.read(appAuthProvider);
      final userId = authState.whenData((user) => user?.uid).value;

      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final targetAmountInCents = _parseAmountToCents(
        _targetAmountController.text,
      );

      if (widget.goal != null) {
        // Edit existing goal
        final updatedGoal = GoalEntity(
          id: widget.goal!.id,
          userId: userId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          targetAmount: targetAmountInCents,
          currentAmount: widget.goal!.currentAmount,
          startDate: _startDate,
          targetDate: _targetDate,
          status: widget.goal!.status,
          associatedTransactionIds: widget.goal!.associatedTransactionIds,
          createdAt: widget.goal!.createdAt,
          updatedAt: DateTime.now(),
        );

        await ref.read(goalProvider.notifier).updateGoal(updatedGoal);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meta atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Create new goal
        final newGoal = GoalEntity(
          id: const Uuid().v4(),
          userId: userId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          targetAmount: targetAmountInCents,
          currentAmount: 0,
          startDate: _startDate,
          targetDate: _targetDate,
          status: GoalStatus.active,
          associatedTransactionIds: [],
          createdAt: DateTime.now(),
        );

        await ref.read(goalProvider.notifier).addGoal(newGoal);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meta criada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar meta: ${e.toString()}'),
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
    final theme = Theme.of(context);
    final isEditing = widget.goal != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Meta' : 'Nova Meta'),
        elevation: 0,
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
                      'Informações Básicas',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título *',
                        hintText: 'Ex: Reserva de Emergência',
                        prefixIcon: Icon(Icons.flag),
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 100,
                      textCapitalization: TextCapitalization.sentences,
                      validator: _validateTitle,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Descreva sua meta (opcional)',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLength: 500,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      validator: _validateDescription,
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
                      'Valor e Prazos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _targetAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Valor Alvo *',
                        hintText: '0,00',
                        prefixIcon: Icon(Icons.attach_money),
                        prefixText: 'R\$ ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+[,]?\d{0,2}'),
                        ),
                      ],
                      validator: _validateTargetAmount,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            borderRadius: BorderRadius.circular(4),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Data de Início',
                                prefixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _dateFormatter.format(_startDate),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false),
                            borderRadius: BorderRadius.circular(4),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Data Alvo',
                                prefixIcon: Icon(Icons.event),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _dateFormatter.format(_targetDate),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
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
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Resumo da Meta',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      'Período:',
                      '${_dateFormatter.format(_startDate)} a ${_dateFormatter.format(_targetDate)}',
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Duração:',
                      '${_targetDate.difference(_startDate).inDays} dias',
                    ),
                    if (_targetAmountController.text.isNotEmpty &&
                        _validateTargetAmount(_targetAmountController.text) == null) ...[
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        'Economia diária necessária:',
                        _currencyFormatter.format(
                          _parseAmountToCents(_targetAmountController.text) /
                              100 /
                              _targetDate.difference(_startDate).inDays,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isLoading ? null : _saveGoal,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(isEditing ? Icons.save : Icons.add),
              label: Text(
                _isLoading
                    ? 'Salvando...'
                    : isEditing
                        ? 'Salvar Alterações'
                        : 'Criar Meta',
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}