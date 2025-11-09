import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/goal_entity.dart';
import '../../../core/constants/goal_colors.dart';
import '../../../core/utils/responsive_utils.dart';
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

  DateTime _startDate = DateTime.now();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));
  int _selectedColorIndex = -1; // -1 = auto

  bool _isLoading = false;

  final _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();

    if (widget.goal != null) {
      _titleController.text = widget.goal!.title;
      _descriptionController.text = widget.goal!.description;
      _startDate = widget.goal!.startDate;
      _targetDate = widget.goal!.targetDate;
      _selectedColorIndex = widget.goal!.colorIndex;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _targetDate;
    final firstDate = isStartDate ? DateTime(2020) : _startDate;
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
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF5A67D8),
              onPrimary: Colors.white,
              surface: Color(0xFF2d3561),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF2d3561),
          ),
          child: child!,
        );
      },
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

      final goal = GoalEntity(
        id: widget.goal?.id ?? '', // Firestore will generate ID on create
        userId: authProvider.user!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        targetAmount: 0, // Não é mais usado
        currentAmount: widget.goal?.currentAmount ?? 0,
        startDate: _startDate,
        targetDate: _targetDate,
        status: widget.goal?.status ?? GoalStatus.active,
        associatedTransactionIds: widget.goal?.associatedTransactionIds ?? [],
        createdAt: widget.goal?.createdAt ?? DateTime.now(),
        updatedAt: widget.goal != null ? DateTime.now() : null,
        colorIndex: _selectedColorIndex,
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEditing ? 'Editar Meta' : 'Nova Meta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              mobile: 22,
              tablet: 24,
              desktop: 26,
            ),
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ResponsiveLayout(
              child: ListView(
                children: [
                  SizedBox(height: ResponsiveUtils.getSpacing(context)),

                  // Basic Info Card
                  _buildCardSection(
                    title: 'Informações Básicas',
                    icon: Icons.flag_rounded,
                    children: [
                    _buildTextField(
                      controller: _titleController,
                      label: 'Título da Meta',
                      hint: 'Ex: Ano Sabático 2026',
                      icon: Icons.title,
                      validator: _validateTitle,
                      maxLength: 100,
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Descrição',
                      hint: 'Descreva sua meta',
                      icon: Icons.description,
                      validator: _validateDescription,
                      maxLength: 500,
                      maxLines: 3,
                    ),
                  ],
                ),

                SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2.5)),

                // Dates Card
                _buildCardSection(
                  title: 'Período',
                  icon: Icons.calendar_month_rounded,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            label: 'Data de Início',
                            date: _startDate,
                            icon: Icons.calendar_today,
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getSpacing(context, multiplier: 2)),
                        Expanded(
                          child: _buildDateField(
                            label: 'Data Alvo',
                            date: _targetDate,
                            icon: Icons.event,
                            onTap: () => _selectDate(context, false),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 1.5)),
                    _buildDurationInfo(),
                  ],
                ),

                SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2.5)),

                // Color Picker Card
                _buildCardSection(
                  title: 'Cor da Meta',
                  icon: Icons.palette,
                  children: [
                    _buildColorPicker(),
                  ],
                ),

                SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 4)),

                // Save Button
                _buildSaveButton(isEditing),

                SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2.5)),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: ResponsiveUtils.getCardPadding(context),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2d3561),
            Color(0xFF1f2544),
          ],
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getBorderRadius(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5A67D8).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF5A67D8), size: 20),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context, multiplier: 1.5)),
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2.5)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int? maxLength,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5A67D8), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        counterStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
      ),
      style: const TextStyle(color: Colors.white),
      validator: validator,
      maxLength: maxLength,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white.withOpacity(0.7), size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _dateFormatter.format(date),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationInfo() {
    final days = _targetDate.difference(_startDate).inDays + 1;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF5A67D8).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF5A67D8).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timelapse,
            color: const Color(0xFF5A67D8),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Duração: $days ${days == 1 ? 'dia' : 'dias'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10B981),
            Color(0xFF059669),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveGoal,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isEditing ? Icons.save_rounded : Icons.add_circle_rounded,
                    size: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? 'Salvar Alterações' : 'Criar Meta',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Escolha uma cor para identificar sua meta',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            GoalColors.colorCount,
            (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColorIndex = index;
                });
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: GoalColors.getGradient(index),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectedColorIndex == index
                        ? Colors.white
                        : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: _selectedColorIndex == index
                      ? [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: _selectedColorIndex == index
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 28,
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedColorIndex >= 0)
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: GoalColors.getGradient(_selectedColorIndex),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                GoalColors.getColorName(_selectedColorIndex),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
        else
          const Text(
            'Cor automática (baseada na posição)',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}
