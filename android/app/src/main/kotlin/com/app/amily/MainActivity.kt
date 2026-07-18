package com.app.amily

import android.content.ComponentName
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.app.amily/badge"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "setBadgeCount") {
                    val count = call.argument<Int>("count") ?: 0
                    try {
                        applyBadge(count)
                    } catch (e: Exception) {
                        Log.w("BadgeService", "Failed to set badge: ${e.message}")
                    }
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun applyBadge(count: Int) {
        val componentName = ComponentName(this, MainActivity::class.java)

        // Samsung
        try {
            val intent = Intent("android.intent.action.BADGE_COUNT_UPDATE")
            intent.putExtra("badge_count_package_name", packageName)
            intent.putExtra("badge_count_class_name", componentName.className)
            intent.putExtra("badge_count", count)
            sendBroadcast(intent)
        } catch (_: Exception) {}

        // Huawei
        try {
            val intent = Intent("com.huawei.launcher.action.BADGE_INCREMENT")
            intent.setComponent(
                ComponentName(
                    "com.huawei.android.launcher",
                    "com.huawei.android.launcher.LauncherProvider"
                )
            )
            intent.putExtra("package", packageName)
            intent.putExtra("class", componentName.className)
            intent.putExtra("badgenumber", count)
            sendBroadcast(intent)
        } catch (_: Exception) {}

        // OPPO / Realme
        try {
            val intent = Intent("com.coloros.socger.action.NOTIFICATION_NUMBER_CHANGED")
            intent.setClassName(
                "com.coloros.socger",
                "com.coloros.socger.receiver.NotificationReceiver"
            )
            intent.putExtra("packageName", packageName)
            intent.putExtra("className", componentName.className)
            intent.putExtra("notificationNum", count)
            intent.putExtra("isShowBadge", count > 0)
            sendBroadcast(intent)
        } catch (_: Exception) {}

        // Xiaomi (MIUI)
        try {
            val intent = Intent("android.intent.action.APPLICATION_MESSAGE_UPDATE")
            intent.putExtra("packageName", packageName)
            intent.putExtra("className", componentName.className)
            intent.putExtra("badge_count", count)
            sendBroadcast(intent)
        } catch (_: Exception) {}

        // Sony
        try {
            val intent = Intent("com.sonyericsson.home.action.UPDATE_BADGE")
            intent.putExtra(
                "com.sonyericsson.home.intent.extra.badge.PACKAGE_NAME",
                packageName
            )
            intent.putExtra(
                "com.sonyericsson.home.intent.extra.badge.ACTIVITY_NAME",
                componentName.className
            )
            intent.putExtra("com.sonyericsson.home.intent.extra.badge.SHOW", count > 0)
            intent.putExtra("com.sonyericsson.home.intent.extra.badge.COUNT", count)
            sendBroadcast(intent)
        } catch (_: Exception) {}

        // Nova, Apex, ADW, and other launchers that support ShortcutBadger-style intents
        try {
            val intent = Intent("com.teslacoilsw.launcher.permission.BADGE_COUNT_UPDATE")
            intent.putExtra("badge_count_package_name", packageName)
            intent.putExtra("badge_count_class_name", componentName.className)
            intent.putExtra("badge_count", count)
            sendBroadcast(intent)
        } catch (_: Exception) {}
    }
}
