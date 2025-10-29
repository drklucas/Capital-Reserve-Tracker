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
import kotlin.math.abs

/**
 * Widget de Evolução da Reserva - Versão Simplificada
 */
class ReserveEvolutionWidgetV2 : AppWidgetProvider() {

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
        val views = RemoteViews(context.packageName, R.layout.reserve_evolution_widget_v2)
        val currencyFormat = NumberFormat.getCurrencyInstance(Locale("pt", "BR"))

        try {
            val reserveJson = widgetData.getString("reserve", "[]")
            val monthsJson = widgetData.getString("months", "[]")
            val currentReserve = widgetData.getFloat("current_reserve", 0.0f).toDouble()
            val lastUpdate = widgetData.getString("last_update", "")

            val reserve = JSONArray(reserveJson)
            val months = JSONArray(monthsJson)

            // Valor atual
            views.setTextViewText(
                R.id.current_reserve_value,
                currencyFormat.format(currentReserve)
            )

            // Calcular estatísticas
            if (reserve.length() >= 2) {
                val firstValue = reserve.getDouble(0)
                val lastValue = reserve.getDouble(reserve.length() - 1)

                // Crescimento
                val growth = if (firstValue != 0.0) {
                    ((lastValue - firstValue) / abs(firstValue)) * 100
                } else if (lastValue > 0) {
                    100.0
                } else {
                    0.0
                }

                val growthText = String.format(
                    Locale.getDefault(),
                    "%s%.1f%%",
                    if (growth >= 0) "+" else "",
                    growth
                )
                views.setTextViewText(R.id.growth_percentage, growthText)

                // Média mensal
                var totalChange = 0.0
                for (i in 1 until reserve.length()) {
                    totalChange += reserve.getDouble(i) - reserve.getDouble(i - 1)
                }
                val monthlyAverage = if (reserve.length() > 1) {
                    totalChange / (reserve.length() - 1)
                } else {
                    0.0
                }

                views.setTextViewText(
                    R.id.monthly_average,
                    currencyFormat.format(monthlyAverage)
                )
            } else {
                views.setTextViewText(R.id.growth_percentage, "+0%")
                views.setTextViewText(R.id.monthly_average, currencyFormat.format(0.0))
            }

        } catch (e: Exception) {
            e.printStackTrace()
            views.setTextViewText(R.id.current_reserve_value, currencyFormat.format(0.0))
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
