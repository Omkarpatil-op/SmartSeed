package com.example.smartseed

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "screen_pinning"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Set up the method channel
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "enableScreenPinning") {
                enableScreenPinning()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun enableScreenPinning() {
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val packageName = applicationContext.packageName

        // Check if Lock Task Mode is permitted
        if (dpm.isLockTaskPermitted(packageName)) {
            startLockTask() // Enable Kiosk Mode
        } else {
            // Request permission
            dpm.setLockTaskPackages(ComponentName(this, MainActivity::class.java), arrayOf(packageName))
            if (dpm.isLockTaskPermitted(packageName)) {
                startLockTask()
            }
        }
    }
}
