package com.example.purity_path

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import androidx.core.app.NotificationCompat

class AccessibilityMonitorService : Service() {
    
    companion object {
        private const val TAG = "AccessibilityMonitor"
        private const val CHANNEL_ID = "accessibility_monitor_channel"
        private const val NOTIFICATION_ID = 1001
        private const val CHECK_INTERVAL = 10000L // Check every 10 seconds
    }
    
    private val handler = Handler(Looper.getMainLooper())
    private var checkRunnable: Runnable? = null
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "AccessibilityMonitorService created")
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
        startMonitoring()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "AccessibilityMonitorService started")
        return START_STICKY // Restart service if killed by system
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Protection Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps your protection active"
                setShowBadge(false)
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun createNotification(serviceActive: Boolean = true): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )
        
        val title = if (serviceActive) {
            "Protection Active"
        } else {
            "⚠️ Protection Disabled"
        }
        
        val message = if (serviceActive) {
            "Your digital protection is running"
        } else {
            "Tap to re-enable accessibility service"
        }
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(message)
            .setSmallIcon(android.R.drawable.ic_lock_idle_lock)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
    
    private fun startMonitoring() {
        checkRunnable = object : Runnable {
            override fun run() {
                checkAccessibilityService()
                handler.postDelayed(this, CHECK_INTERVAL)
            }
        }
        handler.post(checkRunnable!!)
    }
    
    private fun checkAccessibilityService() {
        val isEnabled = isAccessibilityServiceEnabled()
        
        if (!isEnabled) {
            Log.w(TAG, "Accessibility service is disabled!")
            updateNotification(false)
            // Optionally: Show a notification to user to re-enable
        } else {
            Log.d(TAG, "Accessibility service is active")
            updateNotification(true)
        }
    }
    
    private fun isAccessibilityServiceEnabled(): Boolean {
        val serviceName = "${packageName}/${NoFapIslamAccessibilityService::class.java.canonicalName}"
        
        return try {
            val enabledServices = Settings.Secure.getString(
                contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            )
            
            enabledServices?.contains(serviceName) == true
        } catch (e: Exception) {
            Log.e(TAG, "Error checking accessibility service: ${e.message}")
            false
        }
    }
    
    private fun updateNotification(serviceActive: Boolean) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, createNotification(serviceActive))
    }
    
    override fun onDestroy() {
        super.onDestroy()
        checkRunnable?.let { handler.removeCallbacks(it) }
        Log.d(TAG, "AccessibilityMonitorService destroyed")
    }
}
