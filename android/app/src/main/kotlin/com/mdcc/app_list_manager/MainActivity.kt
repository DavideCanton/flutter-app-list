package com.mdcc.app_list_manager

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.content.pm.PackageManager
import android.graphics.drawable.Drawable
import android.graphics.Bitmap
import android.annotation.SuppressLint
import android.util.Base64
import java.io.ByteArrayOutputStream
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable


class MainActivity : FlutterActivity() {
    private val appsChannel = "com.mdcc.app_list_manager/apps"

    @SuppressLint("InlinedApi")
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
                else -> result.notImplemented()
            }
        }
    }

    private fun getName(name: String): String {
        return packageManager.getApplicationLabel(packageManager.getApplicationInfo(name, PackageManager.GET_META_DATA)).toString()
    }

    @SuppressLint("InlinedApi")
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
        val pm = packageManager
        return pm.getInstalledApplications(PackageManager.GET_META_DATA)
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
}
