package com.benjamin.biblivre

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, STORY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isAvailable" -> result.success(storyIntent().resolveActivity(packageManager) != null)
                    "share" -> shareToStory(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    // L'intent de story de Meta, visant Instagram seul.
    private fun storyIntent(): Intent =
        Intent(ADD_TO_STORY).apply {
            setPackage(INSTAGRAM)
            type = "image/png"
        }

    // Ouvre l'éditeur de story d'Instagram.
    //
    // En sticker, l'image est posée sur le dégradé décrit par les deux
    // couleurs et garde sa transparence ; sinon elle devient le fond.
    private fun shareToStory(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path")
        if (path == null) {
            result.error("bad_args", "Chemin manquant", null)
            return
        }

        val uri: Uri = FileProvider.getUriForFile(this, "$packageName.story_provider", File(path))
        val intent = storyIntent().apply {
            putExtra("source_application", FACEBOOK_APP_ID)
            if (call.argument<Boolean>("asSticker") == true) {
                putExtra("interactive_asset_uri", uri)
                putExtra("top_background_color", call.argument<String>("topColor"))
                putExtra("bottom_background_color", call.argument<String>("bottomColor"))
            } else {
                setDataAndType(uri, "image/png")
            }
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        grantUriPermission(INSTAGRAM, uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)

        try {
            startActivity(intent)
            result.success(null)
        } catch (error: ActivityNotFoundException) {
            result.error("unavailable", "Instagram n'est pas installé", null)
        }
    }

    private companion object {
        const val STORY_CHANNEL = "com.benjamin.biblivre/instagram_story"
        const val ADD_TO_STORY = "com.instagram.share.ADD_TO_STORY"
        const val INSTAGRAM = "com.instagram.android"

        // Identifiant de l'app Meta, exigé par Instagram pour accepter une
        // story venue d'une autre application. Ce n'est pas un secret.
        const val FACEBOOK_APP_ID = "2201363724596999"
    }
}
