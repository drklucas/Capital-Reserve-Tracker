package com.example.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

/**
 * Widget de teste simples
 */
class SimpleTestWidget : AppWidgetProvider() {

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
        val views = RemoteViews(context.packageName, R.layout.simple_test_widget)

        try {
            views.setTextViewText(R.id.widget_title, "Widget Funcionando!")
            views.setTextViewText(R.id.widget_value, "R$ 1.234,56")
            views.setTextViewText(R.id.widget_message, "Widget teste OK")
        } catch (e: Exception) {
            e.printStackTrace()
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
