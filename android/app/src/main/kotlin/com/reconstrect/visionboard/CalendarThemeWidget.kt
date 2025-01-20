package com.reconstrect.visionboard

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import android.app.PendingIntent
import android.graphics.Color
import android.util.Log
import java.util.Calendar

class CalendarThemeWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateCalendarWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE ||
            intent.action == "CALENDAR_DATA_UPDATED") {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, CalendarThemeWidget::class.java)
            )
            for (appWidgetId in appWidgetIds) {
                updateCalendarWidget(context, appWidgetManager, appWidgetId)
            }
        }
    }

    companion object {
        private val themeColors = mapOf(
            "animal_calendar_theme_2025" to arrayOf(
                Color.parseColor("#ff6f61"),
                Color.parseColor("#fddb3a"),
                Color.parseColor("#1b998b"),
                Color.parseColor("#8360c3")
            )
        )

        fun updateCalendarWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.calendar_theme_widget)
            val prefs = HomeWidgetPlugin.getData(context)
            
            // Get current month name
            val calendar = Calendar.getInstance()
            val monthName = when (calendar.get(Calendar.MONTH)) {
                0 -> "January"
                1 -> "February"
                2 -> "March"
                3 -> "April"
                4 -> "May"
                5 -> "June"
                6 -> "July"
                7 -> "August"
                8 -> "September"
                9 -> "October"
                10 -> "November"
                else -> "December"
            }
            
            // Set month name in widget
            views.setTextViewText(R.id.month_name, monthName)
            
            // Get saved data for current theme
            val savedData = prefs.getString("animal_calendar_theme_2025", "") ?: ""
            val selectedDates = mutableMapOf<Int, Int>()

            if (savedData.isNotEmpty()) {
                try {
                    val dataMap = savedData.trim('{', '}').split(", ")
                    for (item in dataMap) {
                        if (item.contains(monthName)) {
                            val dates = item.split("=")[1].split(",")
                            for (date in dates) {
                                val parts = date.split(":")
                                if (parts.size == 2) {
                                    selectedDates[parts[0].toInt()] = parts[1].toInt()
                                }
                            }
                            break
                        }
                    }
                } catch (e: Exception) {
                    Log.e("CalendarWidget", "Error parsing data: $e")
                }
            }

            updateCalendarGrid(context, views, calendar, selectedDates, "animal_calendar_theme_2025", calendar.get(Calendar.DAY_OF_MONTH))
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun updateCalendarGrid(
            context: Context,
            views: RemoteViews,
            calendar: Calendar,
            selectedDates: Map<Int, Int>,
            currentTheme: String,
            currentDay: Int
        ) {
            val firstDay = calendar.clone() as Calendar
            firstDay.set(Calendar.DAY_OF_MONTH, 1)
            val offset = firstDay.get(Calendar.DAY_OF_WEEK) - 1
            val daysInMonth = firstDay.getActualMaximum(Calendar.DAY_OF_MONTH)

            views.removeAllViews(R.id.calendar_grid)

            for (i in 0 until 42) {
                val dayIndex = i - offset
                if (dayIndex in 0 until daysInMonth) {
                    val day = dayIndex + 1
                    val colorIndex = selectedDates[day] ?: -1
                    val isToday = day == currentDay
                    
                    val backgroundColor = when {
                        isToday -> Color.parseColor("#E0E0E0")
                        colorIndex >= 0 -> themeColors[currentTheme]?.get(colorIndex) ?: Color.WHITE
                        else -> Color.WHITE
                    }

                    val textColor = if (colorIndex >= 0 || isToday) Color.WHITE else Color.BLACK

                    val dayView = RemoteViews(context.packageName, R.layout.calendar_day_item)
                    dayView.setTextViewText(R.id.day_text, day.toString())
                    dayView.setInt(R.id.day_container, "setBackgroundColor", backgroundColor)
                    dayView.setTextColor(R.id.day_text, textColor)
                    
                    views.addView(R.id.calendar_grid, dayView)
                }
            }
        }
    }
} 