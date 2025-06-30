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

class NoFapIslamAccessibilityService : AccessibilityService() {
    
    companion object {
        private const val TAG = "NoFapAccessibilityService"
        private const val SCAN_DEBOUNCE_DELAY = 500L // ms
        private const val MAX_SCAN_DEPTH = 10
    }
    
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
    
    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "Accessibility Service connected")
    }
    
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let { accessibilityEvent ->
            val packageName = accessibilityEvent.packageName?.toString()
            
            // Skip if already showing overlay or package is whitelisted
            if (isOverlayShown || packageName in whitelistedPackages) {
                return
            }
            
            // Immediately block known adult apps
            if (packageName in blockedPackages) {
                Log.d(TAG, "Blocked app detected: $packageName")
                showBlockingOverlay("Blocked Application", packageName)
                return
            }
            
            // Debounce content scanning to avoid excessive processing
            scanRunnable?.let { handler.removeCallbacks(it) }
            scanRunnable = Runnable {
                serviceScope.launch {
                    withContext(Dispatchers.Default) {
                        scanForAdultContent(rootInActiveWindow, 0)
                    }
                }
            }
            handler.postDelayed(scanRunnable!!, SCAN_DEBOUNCE_DELAY)
        }
    }
    
    private suspend fun scanForAdultContent(node: AccessibilityNodeInfo?, depth: Int) {
        if (node == null || depth > MAX_SCAN_DEPTH || isOverlayShown) return
        
        try {
            // Check text content
            val text = node.text?.toString()
            val contentDescription = node.contentDescription?.toString()
            
            if (containsAdultContent(text) || containsAdultContent(contentDescription)) {
                withContext(Dispatchers.Main) {
                    Log.d(TAG, "Adult content detected: ${text ?: contentDescription}")
                    showBlockingOverlay("Inappropriate Content Detected", text ?: contentDescription)
                }
                return
            }
            
            // Check URL if it's a web view
          if (node.className == "android.webkit.WebView") {
  val url = node.text?.toString() ?: node.contentDescription?.toString()
  if (url != null && containsAdultContent(url)) {
    withContext(Dispatchers.Main) {
      Log.d(TAG, "Adult URL detected: $url")
      showBlockingOverlay("Inappropriate Website Detected", url)
      performGlobalAction(GLOBAL_ACTION_BACK) // Navigate back
    }
    return
  }
}
            
            // Recursively check children with depth limit
            for (i in 0 until node.childCount) {
                if (isOverlayShown) break
                scanForAdultContent(node.getChild(i), depth + 1)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error scanning node: ${e.message}")
        }
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
            
            Log.d(TAG, "Blocking overlay shown")
            
            // Auto-remove overlay after 30 seconds
            handler.postDelayed({
                removeOverlay()
            }, 30000)
            
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
        removeOverlay()
        serviceScope.cancel()
        scanRunnable?.let { handler.removeCallbacks(it) }
    }
}