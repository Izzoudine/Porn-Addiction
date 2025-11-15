package com.example.purity_path

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.util.Log
import android.view.WindowManager
import android.view.View
import android.graphics.Color
import android.graphics.PixelFormat
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.widget.TextView
import android.widget.Button
import android.widget.LinearLayout
import android.view.Gravity
import android.content.Intent
import android.app.ActivityManager
import java.util.regex.Pattern
import kotlinx.coroutines.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class NoFapIslamAccessibilityService : AccessibilityService() {
    
    companion object {
        private const val TAG = "NoFapAccessibilityService"
        private const val SCAN_DEBOUNCE_DELAY = 500L // Reduced to 500ms for faster response
        private const val MAX_SCAN_DEPTH = 5 // Reduced depth to prevent deep recursion
        private const val CHANNEL = "com.example.purity_path/session"
        private const val MIN_EVENT_INTERVAL = 1000L // Minimum 1 second between event processing
    }
    
    private var methodChannel: MethodChannel? = null
    private var isTrackingSession = false
    private var sessionStartTime: Long = 0
    private var timerDelayRunnable: Runnable? = null
    private val TIMER_DELAY_MS = 60000L // 1 minute delay before showing timer
    private var lastEventTime: Long = 0 // Track last event processing time
    private var isProcessingEvent = false // Prevent concurrent processing
    private var phaseTimeLimitMinutes: Int = 0 // Time limit from phase in minutes
    private var isBlocked24Hours = false // Track if currently in 24-hour block
    private var blockEndTime: Long = 0 // When the 24-hour block ends
    private var accumulatedTimeSeconds: Int = 0 // Total time spent watching (persisted across sessions)
    private var currentSessionPauseTime: Long = 0 // When current session was paused
    private var hasStartedJourney: Boolean = false // Track if user has started their recovery journey
    
    // Enhanced keyword detection with regex patterns
private val adultPatterns = listOf(
  Pattern.compile("\\b(porn|adult|sex|xxx|nude|nsfw)\\b", Pattern.CASE_INSENSITIVE),
  Pattern.compile("\\b(fuck|ass|boobs|pussy|dick|penis|vagina)\\b", Pattern.CASE_INSENSITIVE),
  Pattern.compile("\\b(milf|teen|mature|anal|oral)\\b", Pattern.CASE_INSENSITIVE),
  Pattern.compile("\\b(webcam|cam girl|escort|hookup)\\b", Pattern.CASE_INSENSITIVE),
  Pattern.compile("\\b(18\\+|over18|adultchat|nsfwchat)\\b", Pattern.CASE_INSENSITIVE),
  Pattern.compile("\\b(r/NSFW|r/adult|r/porn|r/sex)\\b", Pattern.CASE_INSENSITIVE),
  Pattern.compile("\\b(pornhub.com|xvideos.com|redtube.com|youporn.com|xnxx.com|chaturbate.com)\\b", Pattern.CASE_INSENSITIVE)
)
    
    // Whitelist for legitimate apps that might contain these words
    private val whitelistedPackages = setOf(
        "com.android.settings",
        "com.google.android.apps.docs",
        "com.example.purity_path" // Your own app
    )
    
    // Blocked app packages
  private val blockedPackages = setOf(
    "org.telegram.messenger", // Telegram
    "com.reddit.frontpage", // Reddit
    "com.twitter.android", // Twitter/X
    "org.thunderdog.challegram",
    "com.discord", // Discord
    "com.tumblr", // Tumblr
    "com.snapchat.android", // Snapchat
  "org.telegram.x",
    "com.pornhub",
    "com.xvideos"
)
    
    private var overlayView: View? = null
    private var isOverlayShown = false
    private val handler = Handler(Looper.getMainLooper())
    private var scanRunnable: Runnable? = null
    private val serviceScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private var timerTextView: TextView? = null
    private var timerUpdateRunnable: Runnable? = null
    
    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "Accessibility Service connected")
        
        // Load persisted state
        loadPersistedState()
        
        // Check if journey has started
        checkJourneyStatus()
        
        // Start the monitoring foreground service to keep this service alive
        try {
            val intent = Intent(this, AccessibilityMonitorService::class.java)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start monitoring service: ${e.message}")
        }
    }
    
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Throttle events to prevent overload
        val currentTime = System.currentTimeMillis()
        if (currentTime - lastEventTime < MIN_EVENT_INTERVAL) {
            return // Skip this event if too soon
        }
        
        // Prevent concurrent event processing
        if (isProcessingEvent) {
            return
        }
        
        event?.let { accessibilityEvent ->
            try {
                val packageName = accessibilityEvent.packageName?.toString() ?: return
                
            // Skip if package is whitelisted
            if (packageName in whitelistedPackages) {
                // Don't end session when returning to our own app
                // The timer should keep running
                return
            }
            
                // If user switched to a non-adult app, end session immediately
                if (isTrackingSession && packageName !in blockedPackages) {
                    // Cancel any pending scans
                    scanRunnable?.let { handler.removeCallbacks(it) }
                    
                    // Quick check: is this still adult content?
                    val isAdultContent = packageName in blockedPackages
                    if (!isAdultContent) {
                        // User left adult content - stop tracking immediately
                        endTrackingSession()
                        return
                    }
                }
                
                // Update last event time
                lastEventTime = currentTime
                
                // Check for blocked apps or adult content
                val isAdultContent = packageName in blockedPackages
                
                if (!isAdultContent) {
                    // Debounce content scanning to avoid excessive processing
                    scanRunnable?.let { handler.removeCallbacks(it) }
                    scanRunnable = Runnable {
                        isProcessingEvent = true
                        serviceScope.launch {
                            try {
                                withContext(Dispatchers.Default) {
                                    val detected = scanForAdultContent(rootInActiveWindow, 0)
                                    withContext(Dispatchers.Main) {
                                        if (detected) {
                                            handleAdultContentDetected()
                                        } else if (isTrackingSession) {
                                            // Adult content not detected anymore, stop tracking
                                            endTrackingSession()
                                        }
                                    }
                                }
                            } catch (e: Exception) {
                                Log.e(TAG, "Error during content scan: ${e.message}")
                            } finally {
                                isProcessingEvent = false
                            }
                        }
                    }
                    handler.postDelayed(scanRunnable!!, SCAN_DEBOUNCE_DELAY)
                } else {
                    handleAdultContentDetected()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error processing accessibility event: ${e.message}")
                isProcessingEvent = false
            }
        }
    }
    
    private fun handleAdultContentDetected() {
        // Check if we're in 24-hour block period
        if (isBlocked24Hours) {
            val remainingBlockTime = blockEndTime - System.currentTimeMillis()
            if (remainingBlockTime > 0) {
                val hoursRemaining = (remainingBlockTime / (1000 * 60 * 60)).toInt()
                val minutesRemaining = ((remainingBlockTime / (1000 * 60)) % 60).toInt()
                showBlockingOverlay(
                    "24-Hour Block Active", 
                    "Access blocked for $hoursRemaining hours and $minutesRemaining minutes. Come back tomorrow!"
                )
                return
            } else {
                // Block period ended
                isBlocked24Hours = false
                blockEndTime = 0
            }
        }
        
        if (!isTrackingSession) {
            // Start tracking session
            startTrackingSession()
        } else {
            // Check if limits exceeded
            checkAndEnforceLimits()
        }
    }
    
    private fun startTrackingSession() {
        isTrackingSession = true
        
        // If resuming (accumulated time exists), don't reset session start time
        if (accumulatedTimeSeconds == 0) {
            sessionStartTime = System.currentTimeMillis()
            Log.d(TAG, "Starting NEW tracking session - timer scheduled for 1 minute")
            
            // Schedule timer to show after 1 minute (grace period)
            timerDelayRunnable = Runnable {
                if (isTrackingSession) {
                    // Don't count the grace period toward accumulated time
                    // Reset session start to NOW so timer shows full allowed time
                    sessionStartTime = System.currentTimeMillis()
                    accumulatedTimeSeconds = 0
                    Log.d(TAG, "1 minute grace period passed - resetting timer to show FULL allowed time")
                    showTimerOverlay()
                } else {
                    Log.d(TAG, "1 minute passed but session already ended - not showing timer")
                }
            }
            handler.postDelayed(timerDelayRunnable!!, TIMER_DELAY_MS)
        } else {
            // Resuming from pause - adjust session start time based on accumulated time
            sessionStartTime = System.currentTimeMillis() - (accumulatedTimeSeconds * 1000L)
            Log.d(TAG, "RESUMING tracking session - accumulated time: ${accumulatedTimeSeconds}s")
            
            // Show timer IMMEDIATELY when resuming (no grace period)
            showTimerOverlay()
        }
        
        Log.d(TAG, "Tracking session active - accumulated: ${accumulatedTimeSeconds}s")
        
        // Get phase limit from Flutter
        handler.post {
            try {
                MainActivity.methodChannel?.invokeMethod("getPhaseTimeLimit", null,
                    object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            phaseTimeLimitMinutes = (result as? Int) ?: 5 // Default 5 minutes
                            Log.d(TAG, "Phase time limit received: $phaseTimeLimitMinutes minutes")
                        }
                        override fun error(p0: String, p1: String?, p2: Any?) {
                            phaseTimeLimitMinutes = 5 // Default fallback
                            Log.e(TAG, "Error getting phase limit: $p1")
                        }
                        override fun notImplemented() {
                            phaseTimeLimitMinutes = 5 // Default fallback
                            Log.e(TAG, "getPhaseTimeLimit not implemented")
                        }
                    })
            } catch (e: Exception) {
                Log.e(TAG, "Error getting phase limit: ${e.message}")
                phaseTimeLimitMinutes = 5 // Default fallback
            }
        }
        
        // Notify Flutter to start session tracking (for voice intervention)
        handler.post {
            try {
                MainActivity.methodChannel?.invokeMethod("startSession", null)
                Log.d(TAG, "Session tracking started")
            } catch (e: Exception) {
                Log.e(TAG, "Error starting session: ${e.message}")
            }
        }
    }
    
    private fun checkAndEnforceLimits() {
        val currentDuration = (System.currentTimeMillis() - sessionStartTime) / 1000 // seconds
        
        // Ask Flutter to check if limits are exceeded
        handler.post {
            try {
                MainActivity.methodChannel?.invokeMethod("checkLimits", 
                    mapOf("durationSeconds" to currentDuration.toInt()), 
                    object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            val shouldBlock = result as? Boolean ?: false
                            if (shouldBlock) {
                                showBlockingOverlay("Phase Limit Reached", 
                                    "You've reached your limit for this phase. Take a break!")
                                endTrackingSession()
                            }
                        }
                        
                        override fun error(p0: String, p1: String?, p2: Any?) {
                            Log.e(TAG, "Error checking limits: $p1")
                        }
                        
                        override fun notImplemented() {
                            Log.e(TAG, "checkLimits method not implemented in Flutter")
                        }
                    })
            } catch (e: Exception) {
                Log.e(TAG, "Error checking limits: ${e.message}")
            }
        }
    }
    
    private fun endTrackingSession() {
        if (!isTrackingSession) return
        
        Log.d(TAG, "Pausing tracking session (user left adult content)")
        
        // Calculate current accumulated time
        val elapsedThisSession = (System.currentTimeMillis() - sessionStartTime) / 1000
        accumulatedTimeSeconds = maxOf(0, elapsedThisSession.toInt())
        currentSessionPauseTime = System.currentTimeMillis()
        
        // Save state to persist across app restarts
        savePersistedState()
        
        Log.d(TAG, "Session paused - Total accumulated time: ${accumulatedTimeSeconds}s")
        
        isTrackingSession = false
        
        // Cancel pending timer display
        timerDelayRunnable?.let { 
            handler.removeCallbacks(it)
            Log.d(TAG, "Cancelled pending timer display")
        }
        timerDelayRunnable = null
        
        // Stop timer updates and REMOVE the overlay completely
        stopTimerOverlay()
        
        // Notify Flutter session paused (not ended)
        handler.post {
            try {
                MainActivity.methodChannel?.invokeMethod("endSession", null)
                Log.d(TAG, "Session paused notification sent")
            } catch (e: Exception) {
                Log.e(TAG, "Error notifying session pause: ${e.message}")
            }
        }
    }
    
    private suspend fun scanForAdultContent(node: AccessibilityNodeInfo?, depth: Int): Boolean {
        if (node == null || depth > MAX_SCAN_DEPTH) return false
        
        try {
            // Check text content
            val text = node.text?.toString()
            val contentDescription = node.contentDescription?.toString()
            
            if (containsAdultContent(text) || containsAdultContent(contentDescription)) {
                Log.d(TAG, "Adult content detected")
                return true
            }
            
            // Check URL if it's a web view
            if (node.className == "android.webkit.WebView") {
                val url = node.text?.toString() ?: node.contentDescription?.toString()
                if (url != null && containsAdultContent(url)) {
                    Log.d(TAG, "Adult URL detected")
                    return true
                }
            }
            
            // Limit number of children to scan to prevent excessive memory usage
            val childCount = minOf(node.childCount, 20) // Max 20 children per node
            
            // Recursively check children with depth limit
            for (i in 0 until childCount) {
                try {
                    val child = node.getChild(i)
                    if (child != null && scanForAdultContent(child, depth + 1)) {
                        child.recycle() // Recycle to free memory
                        return true
                    }
                    child?.recycle() // Always recycle to free memory
                } catch (e: Exception) {
                    // Continue with next child if one fails
                    Log.e(TAG, "Error scanning child node: ${e.message}")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error scanning node: ${e.message}")
        }
        
        return false
    }
    
    private fun containsAdultContent(text: String?): Boolean {
        if (text.isNullOrBlank()) return false
        
        return adultPatterns.any { pattern ->
            pattern.matcher(text).find()
        }
    }
    
    private fun showBlockingOverlay(title: String = "Content Blocked", detectedContent: String? = null) {
        if (isOverlayShown) return
        
        try {
            removeOverlay()
            
            val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
            
            // Create enhanced overlay layout
            overlayView = createBlockingLayout(title, detectedContent)
            
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
                PixelFormat.TRANSLUCENT
            )
            
            windowManager.addView(overlayView, params)
            isOverlayShown = true
            
            Log.d(TAG, "Blocking overlay shown - persistent (24-hour block)")
            
            // Don't auto-remove the overlay during 24-hour block
            // It will only be removed when user taps "Close" button
            
        } catch (e: Exception) {
            Log.e(TAG, "Error showing overlay: ${e.message}")
        }
    }
    
    private fun createBlockingLayout(title: String, detectedContent: String?): LinearLayout {
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#CC000000")) // Semi-transparent black
            gravity = Gravity.CENTER
            setPadding(40, 40, 40, 40)
        }
        
        // Title
        val titleView = TextView(this).apply {
            text = title
            setTextColor(Color.WHITE)
            textSize = 28f
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 20)
        }
        layout.addView(titleView)
        
        // Warning message
        val messageView = TextView(this).apply {
            text = "This content has been blocked to help maintain your digital wellness goals."
            setTextColor(Color.WHITE)
            textSize = 16f
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 30)
        }
        layout.addView(messageView)
        
        // Action buttons
        val buttonLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
        }
        
        val closeButton = Button(this).apply {
            text = "Close"
            setBackgroundColor(Color.parseColor("#FF4444"))
            setTextColor(Color.WHITE)
            setPadding(30, 15, 30, 15)
            setOnClickListener {
                removeOverlay()
                // Go to home screen
                val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_HOME)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                startActivity(homeIntent)
            }
        }
        
val reportButton = Button(this).apply {
    text = "Report False Positive"
    setBackgroundColor(Color.parseColor("#FF4444"))
    setTextColor(Color.WHITE)
    setPadding(30, 15, 30, 15)
    setOnClickListener {
        Log.d(TAG, "False positive reported: $detectedContent")
        // Optionally send to server or local storage
        removeOverlay()
        performGlobalAction(GLOBAL_ACTION_BACK)
    }
}
        
        buttonLayout.addView(closeButton)
        buttonLayout.addView(View(this).apply { 
            layoutParams = LinearLayout.LayoutParams(30, 0)
        }) // Spacer
        buttonLayout.addView(reportButton)
        
        layout.addView(buttonLayout)
        
        return layout
    }
    
    private fun removeOverlay() {
        overlayView?.let { view ->
            try {
                val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
                windowManager.removeView(view)
                overlayView = null
                isOverlayShown = false
                Log.d(TAG, "Overlay removed")
            } catch (e: Exception) {
                Log.e(TAG, "Error removing overlay: ${e.message}")
            }
        }
    }
    
    private fun showTimerOverlay() {
        if (timerTextView != null) return // Timer already shown
        
        try {
            val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
            
            // Create timer text view
            timerTextView = TextView(this).apply {
                setTextColor(Color.WHITE)
                textSize = 20f
                gravity = Gravity.CENTER
                setBackgroundColor(Color.parseColor("#CC000000"))
                setPadding(30, 20, 30, 20)
                text = "00:00"
            }
            
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.TRANSLUCENT
            ).apply {
                gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
                y = 100 // Position from top
            }
            
            windowManager.addView(timerTextView, params)
            
            // Start updating timer
            startTimerUpdate()
            
            Log.d(TAG, "Timer overlay shown")
        } catch (e: Exception) {
            Log.e(TAG, "Error showing timer overlay: ${e.message}")
        }
    }
    
    private fun startTimerUpdate() {
        timerUpdateRunnable = object : Runnable {
            override fun run() {
                if (isTrackingSession && timerTextView != null) {
                    // Calculate total elapsed time including accumulated time from previous sessions
                    val elapsedThisSession = (System.currentTimeMillis() - sessionStartTime) / 1000
                    val totalElapsedSeconds = maxOf(0, elapsedThisSession.toInt())
                    
                    // Calculate remaining time from FULL phase limit
                    val totalAllowedSeconds = phaseTimeLimitMinutes * 60
                    val remainingSeconds = totalAllowedSeconds - totalElapsedSeconds
                    
                    Log.d(TAG, "Timer update - Phase limit: ${phaseTimeLimitMinutes}min, Total elapsed: ${totalElapsedSeconds}s, Remaining: ${remainingSeconds}s")
                    
                    if (remainingSeconds <= 0) {
                        // Time's up! Activate 24-hour block
                        timerTextView?.text = "⏱️ 00:00 - BLOCKED"
                        timerTextView?.setTextColor(Color.RED)
                        
                        // Activate 24-hour block
                        isBlocked24Hours = true
                        blockEndTime = System.currentTimeMillis() + (24 * 60 * 60 * 1000) // 24 hours from now
                        
                        // Reset accumulated time since we're starting fresh 24-hour block
                        accumulatedTimeSeconds = 0
                        savePersistedState()
                        
                        // End current session and show block message
                        handler.postDelayed({
                            isTrackingSession = false
                            stopTimerOverlay()
                            showBlockingOverlay(
                                "Time Limit Reached - 24 Hour Block", 
                                "You've used all your allowed time. Adult content is now blocked for 24 hours. Use this time for recovery and reflection."
                            )
                        }, 2000) // Show "BLOCKED" for 2 seconds before showing overlay
                        
                        // Don't schedule next update - session will end
                        return
                    } else {
                        val remainingMinutes = remainingSeconds / 60
                        val remainingSecs = remainingSeconds % 60
                        val timeString = String.format("%02d:%02d", remainingMinutes, remainingSecs)
                        
                        // Change color based on remaining time
                        val textColor = when {
                            remainingMinutes < 1 -> Color.RED
                            remainingMinutes < 2 -> Color.parseColor("#FFA500") // Orange
                            else -> Color.WHITE
                        }
                        
                        timerTextView?.setTextColor(textColor)
                        timerTextView?.text = "⏱️ $timeString"
                    }
                    
                    // Schedule next update
                    handler.postDelayed(this, 1000) // Update every second
                }
            }
        }
        handler.post(timerUpdateRunnable!!)
    }
    
    private fun stopTimerOverlay() {
        timerUpdateRunnable?.let { handler.removeCallbacks(it) }
        timerUpdateRunnable = null
        
        timerTextView?.let { view ->
            try {
                val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
                windowManager.removeView(view)
                timerTextView = null
                Log.d(TAG, "Timer overlay removed")
            } catch (e: Exception) {
                Log.e(TAG, "Error removing timer overlay: ${e.message}")
            }
        }
    }
    
    // Force close current app (use with caution)
    private fun forceCloseCurrentApp() {
        try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val runningTasks = activityManager.getRunningTasks(1)
            if (runningTasks.isNotEmpty()) {
                val currentApp = runningTasks[0].topActivity?.packageName
                if (currentApp != packageName) { // Don't close our own app
                    activityManager.killBackgroundProcesses(currentApp)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error closing app: ${e.message}")
        }
    }
    
    override fun onInterrupt() {
        Log.d(TAG, "Service interrupted")
        removeOverlay()
    }
    
    override fun onDestroy() {
        super.onDestroy()
        try {
            // Save current state before destroying
            if (isTrackingSession) {
                val elapsedThisSession = (System.currentTimeMillis() - sessionStartTime) / 1000
                accumulatedTimeSeconds = maxOf(0, elapsedThisSession.toInt())
                savePersistedState()
            }
            
            // Clean up all resources
            removeOverlay()
            stopTimerOverlay()
            timerDelayRunnable?.let { handler.removeCallbacks(it) }
            scanRunnable?.let { handler.removeCallbacks(it) }
            timerUpdateRunnable?.let { handler.removeCallbacks(it) }
            
            // Cancel all coroutines
            serviceScope.cancel()
            
            // Reset state
            isTrackingSession = false
            isProcessingEvent = false
            
            Log.d(TAG, "Service destroyed and cleaned up")
        } catch (e: Exception) {
            Log.e(TAG, "Error during cleanup: ${e.message}")
        }
    }
    
    private fun savePersistedState() {
        try {
            val prefs = getSharedPreferences("accessibility_timer_state", Context.MODE_PRIVATE)
            prefs.edit().apply {
                putInt("accumulated_time_seconds", accumulatedTimeSeconds)
                putLong("block_end_time", blockEndTime)
                putBoolean("is_blocked_24_hours", isBlocked24Hours)
                putLong("last_save_time", System.currentTimeMillis())
                apply()
            }
            Log.d(TAG, "State saved: accumulated=${accumulatedTimeSeconds}s, blocked=$isBlocked24Hours")
        } catch (e: Exception) {
            Log.e(TAG, "Error saving state: ${e.message}")
        }
    }
    
    private fun loadPersistedState() {
        try {
            val prefs = getSharedPreferences("accessibility_timer_state", Context.MODE_PRIVATE)
            accumulatedTimeSeconds = prefs.getInt("accumulated_time_seconds", 0)
            blockEndTime = prefs.getLong("block_end_time", 0)
            isBlocked24Hours = prefs.getBoolean("is_blocked_24_hours", false)
            val lastSaveTime = prefs.getLong("last_save_time", 0)
            
            // Check if 24-hour block has expired
            if (isBlocked24Hours && blockEndTime > 0) {
                val remainingBlockTime = blockEndTime - System.currentTimeMillis()
                if (remainingBlockTime <= 0) {
                    // Block expired, reset everything
                    isBlocked24Hours = false
                    blockEndTime = 0
                    accumulatedTimeSeconds = 0
                    savePersistedState()
                    Log.d(TAG, "24-hour block expired - state reset")
                } else {
                    Log.d(TAG, "24-hour block still active - ${remainingBlockTime / 1000 / 60 / 60} hours remaining")
                }
            }
            
            Log.d(TAG, "State loaded: accumulated=${accumulatedTimeSeconds}s, blocked=$isBlocked24Hours")
        } catch (e: Exception) {
            Log.e(TAG, "Error loading state: ${e.message}")
        }
    }
    
    private fun checkJourneyStatus() {
        try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            
            // Log all keys to debug
            val allKeys = prefs.all.keys
            Log.d(TAG, "All SharedPreferences keys: $allKeys")
            
            hasStartedJourney = prefs.getBoolean("flutter.hasStartedJourney", false)
            Log.d(TAG, "Journey status check: key='flutter.hasStartedJourney', value=$hasStartedJourney")
            
            if (hasStartedJourney) {
                Log.d(TAG, "✅ Journey has been STARTED")
            } else {
                Log.w(TAG, "⚠️ Journey NOT started - functionality disabled")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking journey status: ${e.message}")
            hasStartedJourney = false
        }
    }
}