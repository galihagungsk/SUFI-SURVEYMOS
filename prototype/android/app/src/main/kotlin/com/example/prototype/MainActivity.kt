package com.example.prototype

import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "file_provider_helper"
        ).setMethodCallHandler { call, result ->
            if (call.method == "getContentUri") {
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    val file = File(filePath)
                    val uri = FileProvider.getUriForFile(
                        this,
                        "${applicationContext.packageName}.fileprovider",
                        file
                    )
                    result.success(uri.toString())
                } else {
                    result.error("INVALID_PATH", "File path null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
