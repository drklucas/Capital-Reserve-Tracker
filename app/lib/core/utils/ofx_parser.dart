import 'package:intl/intl.dart';
import '../../domain/entities/transaction_entity.dart';

/// Parsed OFX transaction data
class ParsedOfxTransaction {
  final DateTime date;
  final double amount;
  final String description;
  final TransactionType type;
  final String fitId;

  const ParsedOfxTransaction({
    required this.date,
    required this.amount,
    required this.description,
    required this.type,
    required this.fitId,
  });
}

/// OFX Parser for Nubank exports
class OfxParser {
  /// Parse OFX file content and extract transactions
  static List<ParsedOfxTransaction> parse(String ofxContent) {
    final transactions = <ParsedOfxTransaction>[];
    final lines = ofxContent.split('\n');

    String? currentTrnType;
    DateTime? currentDate;
    double? currentAmount;
    String? currentMemo;
    String? currentFitId;

    for (var line in lines) {
      final trimmed = line.trim();

      // Extract transaction type
      if (trimmed.startsWith('<TRNTYPE>')) {
        currentTrnType = _extractValue(trimmed);
      }
      // Extract date
      else if (trimmed.startsWith('<DTPOSTED>')) {
        final dateStr = _extractValue(trimmed);
        currentDate = _parseOfxDate(dateStr);
      }
      // Extract amount
      else if (trimmed.startsWith('<TRNAMT>')) {
        final amountStr = _extractValue(trimmed);
        currentAmount = double.tryParse(amountStr);
      }
      // Extract FITID (unique transaction ID)
      else if (trimmed.startsWith('<FITID>')) {
        currentFitId = _extractValue(trimmed);
      }
      // Extract memo/description
      else if (trimmed.startsWith('<MEMO>')) {
        currentMemo = _extractValue(trimmed);
      }
      // End of transaction - create object
      else if (trimmed.startsWith('</STMTTRN>')) {
        if (currentDate != null &&
            currentAmount != null &&
            currentMemo != null &&
            currentTrnType != null &&
            currentFitId != null) {
          // Determine type based on TRNTYPE and amount
          final type = currentTrnType == 'CREDIT'
              ? TransactionType.income
              : TransactionType.expense;

          // Convert amount to positive if it's negative (Nubank uses negative for debits)
          final absAmount = currentAmount.abs();

          transactions.add(ParsedOfxTransaction(
            date: currentDate,
            amount: absAmount,
            description: currentMemo,
            type: type,
            fitId: currentFitId,
          ));
        }

        // Reset for next transaction
        currentTrnType = null;
        currentDate = null;
        currentAmount = null;
        currentMemo = null;
        currentFitId = null;
      }
    }

    return transactions;
  }

  /// Extract value from OFX tag
  static String _extractValue(String line) {
    final startTag = line.indexOf('>');
    final endTag = line.indexOf('</');

    if (startTag != -1 && endTag != -1) {
      return line.substring(startTag + 1, endTag);
    } else if (startTag != -1) {
      // No closing tag on same line
      return line.substring(startTag + 1);
    }

    return '';
  }

  /// Parse OFX date format: YYYYMMDDHHMMSS[TIMEZONE]
  static DateTime? _parseOfxDate(String dateStr) {
    try {
      // Remove timezone info
      final cleanDate = dateStr.split('[')[0];

      if (cleanDate.length >= 8) {
        final year = int.parse(cleanDate.substring(0, 4));
        final month = int.parse(cleanDate.substring(4, 6));
        final day = int.parse(cleanDate.substring(6, 8));

        return DateTime(year, month, day);
      }
    } catch (e) {
      // Return null if parsing fails
    }

    return null;
  }

  /// Categorize transaction based on description
  static TransactionCategory categorizeTransaction(String description) {
    final lowerDesc = description.toLowerCase();

    // Food categories
    if (lowerDesc.contains('supermercado') ||
        lowerDesc.contains('macromix') ||
        lowerDesc.contains('conveniencia') ||
        lowerDesc.contains('ifood') ||
        lowerDesc.contains('pizza') ||
        lowerDesc.contains('restaurante')) {
      return TransactionCategory.food;
    }

    // Transport
    if (lowerDesc.contains('posto') ||
        lowerDesc.contains('combustivel') ||
        lowerDesc.contains('abastecedora')) {
      return TransactionCategory.transport;
    }

    // Shopping
    if (lowerDesc.contains('compra no débito') ||
        lowerDesc.contains('compra no crédito')) {
      // Try to detect specific types
      if (lowerDesc.contains('farmacia') || lowerDesc.contains('drogaria')) {
        return TransactionCategory.healthcare;
      }
      if (lowerDesc.contains('pet')) {
        return TransactionCategory.shopping;
      }
      return TransactionCategory.shopping;
    }

    // Utilities
    if (lowerDesc.contains('pagamento de boleto') ||
        lowerDesc.contains('fatura')) {
      return TransactionCategory.utilities;
    }

    // Investment/Savings
    if (lowerDesc.contains('aplicação') ||
        lowerDesc.contains('rdb') ||
        lowerDesc.contains('investimento')) {
      return TransactionCategory.savings;
    }

    // Income - Transfers received
    if (lowerDesc.contains('transferência recebida') ||
        lowerDesc.contains('salário') ||
        lowerDesc.contains('salary')) {
      return TransactionCategory.salary;
    }

    // Default
    return TransactionCategory.other;
  }

  /// Clean description to remove excessive details
  static String cleanDescription(String description) {
    // Remove long Pix transfer details, keep only essential info
    if (description.contains('Transferência enviada pelo Pix')) {
      // Extract recipient name (first part after "Pix - ")
      final parts = description.split(' - ');
      if (parts.length >= 2) {
        return 'Pix: ${parts[1]}';
      }
      return 'Transferência Pix';
    }

    if (description.contains('Transferência recebida pelo Pix')) {
      final parts = description.split(' - ');
      if (parts.length >= 2) {
        return 'Recebido: ${parts[1]}';
      }
      return 'Pix Recebido';
    }

    if (description.contains('Compra no débito') ||
        description.contains('Compra no crédito')) {
      final parts = description.split(' - ');
      if (parts.length >= 2) {
        return parts[1];
      }
    }

    if (description.contains('Pagamento de boleto efetuado')) {
      final parts = description.split(' - ');
      if (parts.length >= 2) {
        return 'Boleto: ${parts[1]}';
      }
      return 'Pagamento de Boleto';
    }

    if (description.contains('Pagamento de fatura')) {
      return 'Pagamento de Fatura';
    }

    if (description.contains('Aplicação RDB')) {
      return 'Investimento RDB';
    }

    return description;
  }

  /// Get statistics from parsed transactions
  static Map<String, dynamic> getStatistics(
    List<ParsedOfxTransaction> transactions,
  ) {
    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final balance = income - expenses;

    // Find date range
    DateTime? startDate;
    DateTime? endDate;

    for (var transaction in transactions) {
      if (startDate == null || transaction.date.isBefore(startDate)) {
        startDate = transaction.date;
      }
      if (endDate == null || transaction.date.isAfter(endDate)) {
        endDate = transaction.date;
      }
    }

    return {
      'totalTransactions': transactions.length,
      'totalIncome': income,
      'totalExpenses': expenses,
      'balance': balance,
      'incomeCount':
          transactions.where((t) => t.type == TransactionType.income).length,
      'expenseCount':
          transactions.where((t) => t.type == TransactionType.expense).length,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}
