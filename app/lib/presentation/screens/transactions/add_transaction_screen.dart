import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/responsive/max_width_container.dart';

/// Screen for adding or editing a transaction
class AddTransactionScreen extends StatefulWidget {
  final TransactionEntity? transaction;

  const AddTransactionScreen({Key? key, this.transaction}) : super(key: key);

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
  void initState() {
    super.initState();
    // If editing, populate fields with existing transaction data
    if (widget.transaction != null) {
      _descriptionController.text = widget.transaction!.description;
      _amountController.text = widget.transaction!.amount.toString();
      _type = widget.transaction!.type;
      _category = widget.transaction!.category;
      _selectedDate = widget.transaction!.date;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.transaction == null ? 'Nova Transação' : 'Editar Transação',
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
        width: double.infinity,
        height: double.infinity,
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
          child: MaxWidthContainer(
            child: ListView(
              padding: EdgeInsets.all(
                ResponsiveUtils.valueByScreen(
                  context: context,
                  mobile: 16.0,
                  tablet: 20.0,
                  desktop: 24.0,
                ),
              ),
              children: [
                SizedBox(
                  height: ResponsiveUtils.valueByScreen(
                    context: context,
                    mobile: 8.0,
                    tablet: 12.0,
                    desktop: 16.0,
                  ),
                ),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Type selector card
                      _buildCardSection(
                        context,
                        title: 'Tipo de Transação',
                        icon: Icons.swap_vert_rounded,
                        children: [
                          _buildTypeSelector(),
                        ],
                      ),

                      SizedBox(
                        height: ResponsiveUtils.getSpacing(
                          context,
                          multiplier: 2.5,
                        ),
                      ),

                      // Transaction details card
                      _buildCardSection(
                        context,
                        title: 'Detalhes',
                        icon: Icons.description_rounded,
                        children: [
                          _buildTextField(
                            controller: _descriptionController,
                            label: 'Descrição',
                            hint: 'Ex: Supermercado, Salário...',
                            icon: Icons.title,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'A descrição é obrigatória';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: ResponsiveUtils.getSpacing(
                              context,
                              multiplier: 2,
                            ),
                          ),
                          _buildTextField(
                            controller: _amountController,
                            label: 'Valor',
                            hint: '0,00',
                            icon: Icons.attach_money,
                            prefix: 'R\$ ',
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
                          SizedBox(
                            height: ResponsiveUtils.getSpacing(
                              context,
                              multiplier: 2,
                            ),
                          ),
                          _buildCategoryDropdown(),
                          SizedBox(
                            height: ResponsiveUtils.getSpacing(
                              context,
                              multiplier: 2,
                            ),
                          ),
                          _buildDateField(),
                        ],
                      ),

                      SizedBox(
                        height: ResponsiveUtils.getSpacing(
                          context,
                          multiplier: 4,
                        ),
                      ),

                      // Save button
                      Consumer<TransactionProvider>(
                        builder: (context, provider, _) {
                          if (provider.status == TransactionStatus.creating ||
                              provider.status == TransactionStatus.updating) {
                            return const Center(child: LoadingIndicator());
                          }

                          return _buildSaveButton();
                        },
                      ),

                      SizedBox(
                        height: ResponsiveUtils.getSpacing(
                          context,
                          multiplier: 2.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final padding = ResponsiveUtils.getCardPadding(context);
    final borderRadius = ResponsiveUtils.getBorderRadius(context);
    final titleFontSize = ResponsiveUtils.responsiveFontSize(
      context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2d3561),
            Color(0xFF1f2544),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
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
              SizedBox(
                width: ResponsiveUtils.getSpacing(context, multiplier: 1.5),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
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

  Widget _buildTypeSelector() {
    return Builder(
      builder: (context) {
        final spacing = ResponsiveUtils.getSpacing(context, multiplier: 2);
        final iconSize = ResponsiveUtils.valueByScreen(
          context: context,
          mobile: 28.0,
          tablet: 32.0,
          desktop: 36.0,
        );
        final fontSize = ResponsiveUtils.responsiveFontSize(
          context,
          mobile: 14.0,
          tablet: 16.0,
          desktop: 18.0,
        );

        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _type = TransactionType.income;
                    _category = TransactionCategory.salary;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(spacing),
                  decoration: BoxDecoration(
                    gradient: _type == TransactionType.income
                        ? const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          )
                        : null,
                    color: _type != TransactionType.income
                        ? Colors.white.withOpacity(0.1)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _type == TransactionType.income
                          ? Colors.green
                          : Colors.white.withOpacity(0.2),
                      width: _type == TransactionType.income ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: _type == TransactionType.income
                            ? Colors.white
                            : Colors.green,
                        size: iconSize,
                      ),
                      SizedBox(height: spacing * 0.5),
                      Text(
                        'Receita',
                        style: TextStyle(
                          color: _type == TransactionType.income
                              ? Colors.white
                              : Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _type = TransactionType.expense;
                    _category = TransactionCategory.food;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(spacing),
                  decoration: BoxDecoration(
                    gradient: _type == TransactionType.expense
                        ? const LinearGradient(
                            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                          )
                        : null,
                    color: _type != TransactionType.expense
                        ? Colors.white.withOpacity(0.1)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _type == TransactionType.expense
                          ? Colors.red
                          : Colors.white.withOpacity(0.2),
                      width: _type == TransactionType.expense ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        color: _type == TransactionType.expense
                            ? Colors.white
                            : Colors.red,
                        size: iconSize,
                      ),
                      SizedBox(height: spacing * 0.5),
                      Text(
                        'Despesa',
                        style: TextStyle(
                          color: _type == TransactionType.expense
                              ? Colors.white
                              : Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? prefix,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
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
      ),
      style: const TextStyle(color: Colors.white),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<TransactionCategory>(
      value: _category,
      decoration: InputDecoration(
        labelText: 'Categoria',
        prefixIcon: Icon(Icons.category_outlined, color: Colors.white.withOpacity(0.7)),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
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
      ),
      dropdownColor: const Color(0xFF2d3561),
      style: const TextStyle(color: Colors.white),
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
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.7), size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/'
                  '${_selectedDate.month.toString().padLeft(2, '0')}/'
                  '${_selectedDate.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Builder(
      builder: (context) {
        final buttonHeight = ResponsiveUtils.valueByScreen(
          context: context,
          mobile: 52.0,
          tablet: 56.0,
          desktop: 60.0,
        );
        final borderRadius = ResponsiveUtils.valueByScreen(
          context: context,
          mobile: 14.0,
          tablet: 16.0,
          desktop: 18.0,
        );
        final fontSize = ResponsiveUtils.responsiveFontSize(
          context,
          mobile: 16.0,
          tablet: 18.0,
          desktop: 20.0,
        );
        final iconSize = ResponsiveUtils.valueByScreen(
          context: context,
          mobile: 22.0,
          tablet: 24.0,
          desktop: 26.0,
        );

        return Container(
          height: buttonHeight,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF10B981),
                Color(0xFF059669),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _saveTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_rounded, size: iconSize, color: Colors.white),
                SizedBox(width: ResponsiveUtils.getSpacing(context)),
                Text(
                  widget.transaction == null ? 'Salvar Transação' : 'Atualizar Transação',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
    bool success;

    if (widget.transaction == null) {
      // Creating new transaction
      success = await transactionProvider.createTransaction(
        userId: authProvider.user!.id,
        type: _type,
        amount: amount,
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        category: _category,
      );
    } else {
      // Updating existing transaction
      success = await transactionProvider.updateTransaction(
        transaction: widget.transaction!,
        type: _type,
        amount: amount,
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        category: _category,
      );
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              transactionProvider.errorMessage ??
                (widget.transaction == null ? 'Erro ao criar transação' : 'Erro ao atualizar transação'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
