import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/ofx_parser.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/loading_indicator.dart';

class ImportTransactionsScreen extends StatefulWidget {
  const ImportTransactionsScreen({Key? key}) : super(key: key);

  @override
  State<ImportTransactionsScreen> createState() =>
      _ImportTransactionsScreenState();
}

class _ImportTransactionsScreenState extends State<ImportTransactionsScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  List<ParsedOfxTransaction>? _parsedTransactions;
  Map<String, dynamic>? _statistics;
  bool _isImporting = false;
  String? _errorMessage;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();

        setState(() {
          _errorMessage = null;
          _parsedTransactions = OfxParser.parse(content);
          _statistics = OfxParser.getStatistics(_parsedTransactions!);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao ler arquivo: $e';
        _parsedTransactions = null;
        _statistics = null;
      });
    }
  }

  Future<void> _importTransactions() async {
    if (_parsedTransactions == null || _parsedTransactions!.isEmpty) return;

    final authProvider = context.read<AppAuthProvider>();
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário não autenticado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    final transactionProvider = context.read<TransactionProvider>();
    int successCount = 0;
    int errorCount = 0;

    for (var parsedTx in _parsedTransactions!) {
      final category = OfxParser.categorizeTransaction(parsedTx.description);
      final cleanDesc = OfxParser.cleanDescription(parsedTx.description);

      final success = await transactionProvider.createTransaction(
        userId: authProvider.user!.id,
        type: parsedTx.type,
        amount: parsedTx.amount,
        description: cleanDesc,
        date: parsedTx.date,
        category: category,
      );

      if (success) {
        successCount++;
      } else {
        errorCount++;
      }

      // Small delay to avoid overwhelming Firestore
      await Future.delayed(const Duration(milliseconds: 100));
    }

    setState(() {
      _isImporting = false;
    });

    if (mounted) {
      if (errorCount == 0) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount transações importadas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$successCount importadas, $errorCount com erro',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Importar Transações',
          style: TextStyle(
            fontWeight: FontWeight.bold,
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
          child: _isImporting
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingIndicator(
                        message: 'Importando transações...',
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Instructions Card
                      _buildInstructionsCard(),
                      const SizedBox(height: 16),

                      // Select File Button
                      _buildSelectFileButton(),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _buildErrorCard(),
                      ],

                      if (_parsedTransactions != null &&
                          _statistics != null) ...[
                        const SizedBox(height: 24),
                        _buildStatisticsCard(),
                        const SizedBox(height: 16),
                        _buildTransactionsList(),
                        const SizedBox(height: 16),
                        _buildImportButton(),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2d3561),
            Color(0xFF1f2544),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF5A67D8).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF5A67D8),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Como Importar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '1. No app do Nubank, vá em "Extrato"\n'
            '2. Toque no ícone de compartilhar\n'
            '3. Escolha "Exportar extrato"\n'
            '4. Selecione o período desejado\n'
            '5. Escolha o formato OFX\n'
            '6. Salve o arquivo e selecione aqui',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectFileButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5A67D8), Color(0xFF6B46C1)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A67D8).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _pickFile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.file_upload, size: 24, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Selecionar Arquivo OFX',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final stats = _statistics!;
    final dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2d3561),
            Color(0xFF1f2544),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo da Importação',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Período',
            '${dateFormat.format(stats['startDate'])} - ${dateFormat.format(stats['endDate'])}',
          ),
          _buildStatRow(
            'Total de Transações',
            '${stats['totalTransactions']}',
          ),
          _buildStatRow(
            'Receitas',
            '${stats['incomeCount']} (${_currencyFormat.format(stats['totalIncome'])})',
            color: const Color(0xFF48BB78),
          ),
          _buildStatRow(
            'Despesas',
            '${stats['expenseCount']} (${_currencyFormat.format(stats['totalExpenses'])})',
            color: const Color(0xFFE53E3E),
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildStatRow(
            'Saldo do Período',
            _currencyFormat.format(stats['balance']),
            color: stats['balance'] >= 0
                ? const Color(0xFF48BB78)
                : const Color(0xFFE53E3E),
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value,
      {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2d3561),
            Color(0xFF1f2544),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transações',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mostrando primeiras 10 de ${_parsedTransactions!.length}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            _parsedTransactions!.length > 10 ? 10 : _parsedTransactions!.length,
            (index) {
              final tx = _parsedTransactions![index];
              final cleanDesc = OfxParser.cleanDescription(tx.description);
              return _buildTransactionItem(tx, cleanDesc);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(ParsedOfxTransaction tx, String cleanDesc) {
    final dateFormat = DateFormat('dd/MM', 'pt_BR');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: tx.type == TransactionType.income
              ? const Color(0xFF48BB78).withOpacity(0.3)
              : const Color(0xFFE53E3E).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tx.type == TransactionType.income
                  ? const Color(0xFF48BB78).withOpacity(0.2)
                  : const Color(0xFFE53E3E).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              tx.type == TransactionType.income
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: tx.type == TransactionType.income
                  ? const Color(0xFF48BB78)
                  : const Color(0xFFE53E3E),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cleanDesc,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateFormat.format(tx.date),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _currencyFormat.format(tx.amount),
            style: TextStyle(
              color: tx.type == TransactionType.income
                  ? const Color(0xFF48BB78)
                  : const Color(0xFFE53E3E),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
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
        onPressed: _importTransactions,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_upload, size: 24, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Importar ${_parsedTransactions!.length} Transações',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
