package com.example.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import java.text.NumberFormat
import java.text.SimpleDateFormat
import java.util.*

/**
 * Widget de Receitas e Despesas - Versão Simplificada
 */
class IncomeExpenseWidgetV2 : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val views = RemoteViews(context.packageName, R.layout.income_expense_widget_v2)
        val currencyFormat = NumberFormat.getCurrencyInstance(Locale("pt", "BR"))

        try {
            val incomeJson = widgetData.getString("income", "[]")
            val expenseJson = widgetData.getString("expense", "[]")
            val monthsJson = widgetData.getString("months", "[]")
            val lastUpdate = widgetData.getString("last_update", "")

            val income = JSONArray(incomeJson)
            val expense = JSONArray(expenseJson)
            val months = JSONArray(monthsJson)

            // Calcular totais
            var totalIncome = 0.0
            var totalExpense = 0.0

            for (i in 0 until income.length()) {
                totalIncome += income.getDouble(i)
            }

            for (i in 0 until expense.length()) {
                totalExpense += expense.getDouble(i)
            }

            val balance = totalIncome - totalExpense

            // Atualizar valores
            views.setTextViewText(R.id.total_income, currencyFormat.format(totalIncome))
            views.setTextViewText(R.id.total_expense, currencyFormat.format(totalExpense))
            views.setTextViewText(R.id.balance, currencyFormat.format(balance))

            // Mostrar meses
            if (months.length() > 0) {
                val monthsList = mutableListOf<String>()
                for (i in 0 until months.length()) {
                    monthsList.add(months.getString(i))
                }
                views.setTextViewText(
                    R.id.months_display,
                    "Últimos 6 meses: ${monthsList.joinToString(", ")}"
                )
            }

            // Última atualização
            if (!lastUpdate.isNullOrEmpty()) {
                try {
                    val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                    val displayFormat = SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.getDefault())
                    val date = isoFormat.parse(lastUpdate.substring(0, 19))
                    val formattedDate = if (date != null) displayFormat.format(date) else "--"
                    views.setTextViewText(R.id.last_update, "Atualizado em: $formattedDate")
                } catch (e: Exception) {
                    views.setTextViewText(R.id.last_update, "Atualizado em: --")
                }
            }

        } catch (e: Exception) {
            e.printStackTrace()
            views.setTextViewText(R.id.total_income, currencyFormat.format(0.0))
            views.setTextViewText(R.id.total_expense, currencyFormat.format(0.0))
            views.setTextViewText(R.id.balance, currencyFormat.format(0.0))
            views.setTextViewText(R.id.last_update, "Erro ao carregar dados")
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
