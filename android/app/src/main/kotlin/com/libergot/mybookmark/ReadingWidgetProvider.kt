package com.libergot.mybookmark

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Le widget d'écran d'accueil : le livre en cours et sa progression.
 *
 * Il ne calcule rien : l'application écrit les textes déjà traduits (voir
 * reading_widget_sync.dart) et ce fournisseur les affiche. Toucher le widget
 * ouvre l'application sur le livre.
 */
class ReadingWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.reading_widget)
            val bookId = widgetData.number("book_id")
            val hasBook = widgetData.getBoolean("has_book", false) && bookId != null

            if (hasBook) {
                views.setViewVisibility(R.id.widget_book, View.VISIBLE)
                views.setViewVisibility(R.id.widget_empty, View.GONE)
                views.setTextViewText(R.id.widget_kicker, widgetData.getString("kicker", ""))
                views.setTextViewText(R.id.widget_title, widgetData.getString("title", ""))
                val author = widgetData.getString("author", "").orEmpty()
                views.setTextViewText(R.id.widget_author, author)
                views.setViewVisibility(
                    R.id.widget_author,
                    if (author.isEmpty()) View.GONE else View.VISIBLE,
                )
                views.setTextViewText(R.id.widget_progress_text, widgetData.getString("progress", ""))

                val percent = widgetData.number("percent") ?: -1
                if (percent >= 0) {
                    views.setViewVisibility(R.id.widget_progress, View.VISIBLE)
                    views.setProgressBar(R.id.widget_progress, 100, percent, false)
                } else {
                    views.setViewVisibility(R.id.widget_progress, View.GONE)
                }

                val cover = widgetData.getString("cover", null)
                    ?.let { path -> runCatching { BitmapFactory.decodeFile(path) }.getOrNull() }
                if (cover != null) {
                    views.setImageViewBitmap(R.id.widget_cover, cover)
                } else {
                    views.setImageViewResource(R.id.widget_cover, R.drawable.widget_cover_placeholder)
                }
            } else {
                views.setViewVisibility(R.id.widget_book, View.GONE)
                views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
                widgetData.getString("empty_title", null)?.let {
                    views.setTextViewText(R.id.widget_empty_title, it)
                }
                widgetData.getString("empty_hint", null)?.let {
                    views.setTextViewText(R.id.widget_empty_hint, it)
                }
            }

            val uri = if (hasBook) Uri.parse("mybookmark://book/$bookId") else null
            views.setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, uri),
            )
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    // Les entiers venus de Dart arrivent en Int ou en Long selon leur taille.
    private fun SharedPreferences.number(key: String): Int? = (all[key] as? Number)?.toInt()
}
