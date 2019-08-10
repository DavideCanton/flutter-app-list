package com.mdcc.app_list_manager

import android.annotation.SuppressLint
import android.app.usage.StorageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.provider.Settings
import android.util.Base64
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.ByteArrayOutputStream

@SuppressLint("InlinedApi")
class MainActivity : FlutterActivity() {
    private lateinit var grantPermissionResult: MethodChannel.Result
    private val appsChannel = "com.mdcc.app_list_manager/apps"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        MethodChannel(flutterView, appsChannel).setMethodCallHandler { call, result ->
            when {
                call.method == "getApps" -> {
                    result.success(getApplications())
                }
                call.method == "getIcon" -> {
                    result.success(getIcon(call.argument("name")!!))
                }
                call.method == "getSize" -> {
                    getSpace(call.argument("name")!!) { result.success(it) }
                }
                call.method == "grantPermission" -> {
                    grantPermission(result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun grantPermission(result: MethodChannel.Result) {
        if (!hasPermission()) {
            this.grantPermissionResult = result
            startActivityForResult(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS), 1)
        } else
            result.success(true)
    }

    private fun hasPermission(): Boolean {
        return try {
            val storageStatsManager = getSystemService(Context.STORAGE_STATS_SERVICE) as StorageStatsManager
            val ai = packageManager.getApplicationInfo(packageName, 0)
            val app1 = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)[0]
            storageStatsManager.queryStatsForUid(ai.storageUuid, app1.uid)
            true
        } catch (ex: Exception) {
            false
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        this.grantPermissionResult.success(true)
    }

    private fun getName(name: String): String {
        val info = packageManager.getApplicationInfo(name, PackageManager.GET_META_DATA)
        return packageManager.getApplicationLabel(info).toString()
    }

    private fun getIcon(name: String): String {
        val icon = getIconDrawable(name)
        val bitmap = drawableToBitmap(icon)
        val byteArrayOutputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
        val byteArray = byteArrayOutputStream.toByteArray()
        val encoded = Base64.encodeToString(byteArray, Base64.DEFAULT)
        return "data:image/png;base64,$encoded"
    }

    private fun getIconDrawable(name: String): Drawable {
        return packageManager.getApplicationIcon(name)
    }

    private fun getApplications(): List<Map<String, Any>> {
        return packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
                .filterNotNull()
                .map {
                    mapOf<String, Any>(
                            "className" to it.className,
                            "dataDir" to it.dataDir,
                            "name" to it.name,
                            "packageName" to it.packageName,
                            "displayName" to getName(it.packageName)
                    )
                }
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        if (drawable is BitmapDrawable && drawable.bitmap != null)
            return drawable.bitmap

        val bitmap = if (drawable.intrinsicWidth <= 0 || drawable.intrinsicHeight <= 0)
            Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888)
        else
            Bitmap.createBitmap(drawable.intrinsicWidth, drawable.intrinsicHeight, Bitmap.Config.ARGB_8888)

        val canvas = Canvas(bitmap!!)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }

    private fun getSpace(name: String, function: (Map<String, Long>) -> Unit) {
        val applicationInfo = packageManager.getApplicationInfo(name, PackageManager.GET_META_DATA)
        val storageStatsManager = getSystemService(Context.STORAGE_STATS_SERVICE) as StorageStatsManager
        val ai = packageManager.getApplicationInfo(packageName, 0)
        val storageStats = storageStatsManager.queryStatsForUid(ai.storageUuid, applicationInfo.uid)
        function(mapOf(
                "cache" to storageStats.cacheBytes,
                "data" to storageStats.dataBytes,
                "apkSize" to storageStats.appBytes
        ))
    }
}
