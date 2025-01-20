package com.reconstrect.visionboard

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import es.antonborri.home_widget.HomeWidgetPlugin

class CalendarConfigureActivity : Activity() {
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.calendar_configure)

        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        setupThemeButtons()
    }

    private fun setupThemeButtons() {
        findViewById<Button>(R.id.animal_theme).setOnClickListener { 
            selectTheme("Animal theme 2025 Calendar") 
        }
        findViewById<Button>(R.id.summer_theme).setOnClickListener { 
            selectTheme("Summer theme 2025 Calendar") 
        }
        findViewById<Button>(R.id.spaniel_theme).setOnClickListener { 
            selectTheme("Spanish theme 2025 Calendar") 
        }
        findViewById<Button>(R.id.happy_couple_theme).setOnClickListener { 
            selectTheme("Happy Couple theme 2025 Calendar") 
        }
    }

    private fun selectTheme(theme: String) {
        val prefs = HomeWidgetPlugin.getData(this)
        prefs.edit()
            .putString("calendar_widget_theme_$appWidgetId", theme)
            .putString("current_theme_key", theme.toLowerCase().replace(" ", "_"))
            .apply()

        val appWidgetManager = AppWidgetManager.getInstance(this)
        CalendarThemeWidget.updateCalendarWidget(this, appWidgetManager, appWidgetId)

        val resultValue = Intent().apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        setResult(RESULT_OK, resultValue)
        finish()
    }
} 