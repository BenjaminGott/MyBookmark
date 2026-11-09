package com.libergot.mybookmark

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
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

        val videoChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VIDEO_CHANNEL)
        videoChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "encode" -> encodeYearReview(call, result, videoChannel)
                else -> result.notImplemented()
            }
        }
    }

    // La vidéo du bilan s'assemble en arrière-plan : quelques secondes de
    // travail qui ne doivent pas figer l'écran. L'avancement remonte à Dart.
    private fun encodeYearReview(call: MethodCall, result: MethodChannel.Result, channel: MethodChannel) {
        val frames = call.argument<List<String>>("frames")
        val output = call.argument<String>("output")
        val width = call.argument<Int>("width")
        val height = call.argument<Int>("height")
        val slideMillis = call.argument<Number>("slideMillis")?.toLong()
        if (frames.isNullOrEmpty() || output == null || width == null || height == null || slideMillis == null) {
            result.error("bad_args", "Paramètres manquants", null)
            return
        }
        val main = Handler(Looper.getMainLooper())
        Thread {
            try {
                YearReviewVideoEncoder(
                    framePaths = frames,
                    width = width,
                    height = height,
                    slideMillis = slideMillis,
                    audioPath = call.argument<String>("audio"),
                    outputPath = output,
                ).encode { progress ->
                    main.post { channel.invokeMethod("progress", progress) }
                }
                main.post { result.success(output) }
            } catch (error: Exception) {
                main.post { result.error("encode_failed", error.message, null) }
            }
        }.start()
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
        const val STORY_CHANNEL = "com.libergot.mybookmark/instagram_story"
        const val VIDEO_CHANNEL = "com.libergot.mybookmark/year_review_video"
        const val ADD_TO_STORY = "com.instagram.share.ADD_TO_STORY"
        const val INSTAGRAM = "com.instagram.android"

        // Identifiant de l'app Meta, exigé par Instagram pour accepter une
        // story venue d'une autre application. Ce n'est pas un secret.
        const val FACEBOOK_APP_ID = "2201363724596999"
    }
}
