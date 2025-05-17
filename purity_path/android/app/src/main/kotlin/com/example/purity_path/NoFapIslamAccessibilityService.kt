package com.example.purity_path

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.util.Log

class NoFapIslamAccessibilityService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let {
            Log.d("AccessibilityService", "Event: ${it.packageName}, Type: ${it.eventType}")
            if (it.packageName == "com.android.chrome") {
                Log.d("AccessibilityService", "Restricted app detected: ${it.packageName}")
            }
        }
    }

    override fun onInterrupt() {
        Log.d("AccessibilityService", "Service interrupted")
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d("AccessibilityService", "Service connected")
    }
}