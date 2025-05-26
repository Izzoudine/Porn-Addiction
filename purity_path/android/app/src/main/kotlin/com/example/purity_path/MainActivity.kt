package com.example.purity_path

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.purity_path/accessibility"
    private val NOTIFICATION_PERMISSION_CODE = 100

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestAccessibilityPermission" -> {
                    try {
                        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ACCESSIBILITY_ERROR", e.message, null)
                    }
                }
                "isAccessibilityServiceEnabled" -> {
                    val isEnabled = isAccessibilityServiceEnabled()
                    result.success(isEnabled)
                }
                "requestIgnoreBatteryOptimizations" -> {
                    try {
                        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                        intent.data = android.net.Uri.parse("package:$packageName")
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("BATTERY_OPTIMIZATION_ERROR", e.message, null)
                    }
                }
                "isIgnoringBatteryOptimizations" -> {
                    val isIgnoring = isIgnoringBatteryOptimizations()
                    result.success(isIgnoring)
                }
                "requestNotificationPermission" -> {
                    requestNotificationPermission()
                    result.success(null)
                }
                "isNotificationPermissionGranted" -> {
                    val isGranted = isNotificationPermissionGranted()
                    result.success(isGranted)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val expectedService = "com.example.purity_path.NoFapIslamAccessibilityService"

        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        )
        return enabledServices?.contains(expectedService) == true
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
        return powerManager.isIgnoringBatteryOptimizations(packageName)
    }

    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.POST_NOTIFICATIONS)
                != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                    NOTIFICATION_PERMISSION_CODE
                )
            }
        }
    }

    private fun isNotificationPermissionGranted(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(this, android.Manifest.permission.POST_NOTIFICATIONS) ==
                PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == NOTIFICATION_PERMISSION_CODE) {
            // Handle permission result if needed
        }
    }
}