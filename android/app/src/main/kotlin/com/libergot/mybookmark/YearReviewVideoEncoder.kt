package com.libergot.mybookmark

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMuxer
import java.nio.ByteBuffer

/**
 * Assemble la vidéo du bilan annuel : les pages du bilan, déjà dessinées par
 * Flutter en PNG, deviennent une vidéo H.264 avec la musique, en MP4.
 *
 * Chaque page avance d'un léger zoom, puis la suivante la pousse depuis la
 * droite, comme dans une story. Le dessin
 * se fait sur la surface d'entrée de l'encodeur matériel du téléphone : pas
 * de bibliothèque vidéo à embarquer.
 */
class YearReviewVideoEncoder(
    private val framePaths: List<String>,
    private val width: Int,
    private val height: Int,
    private val slideMillis: Long,
    private val audioPath: String?,
    private val outputPath: String,
) {
    companion object {
        private const val MIME = MediaFormat.MIMETYPE_VIDEO_AVC
        private const val FPS = 30
        private const val BIT_RATE = 6_000_000
        private const val TRANSITION_MILLIS = 450L
        private const val ZOOM = 0.05f
        private const val TIMEOUT_US = 10_000L
    }

    private val info = MediaCodec.BufferInfo()
    private lateinit var muxer: MediaMuxer
    private var videoTrack = -1
    private var audioTrack = -1
    private var muxerStarted = false
    private var writtenFrames = 0L
    private var audioExtractor: MediaExtractor? = null
    private var audioFormat: MediaFormat? = null

    /** Encode la vidéo. [onProgress] reçoit l'avancement, de 0 à 1. */
    fun encode(onProgress: (Double) -> Unit) {
        val slides = framePaths.map { loadSlide(it) }
        val durationMillis = slideMillis * slides.size
        val frameCount = (durationMillis * FPS / 1000).toInt()

        prepareAudio()
        val format = MediaFormat.createVideoFormat(MIME, width, height).apply {
            setInteger(
                MediaFormat.KEY_COLOR_FORMAT,
                MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface,
            )
            setInteger(MediaFormat.KEY_BIT_RATE, BIT_RATE)
            setInteger(MediaFormat.KEY_FRAME_RATE, FPS)
            setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 1)
        }
        val codec = MediaCodec.createEncoderByType(MIME)
        codec.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
        val surface = codec.createInputSurface()
        codec.start()
        muxer = MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)

        val paint = Paint(Paint.FILTER_BITMAP_FLAG or Paint.ANTI_ALIAS_FLAG)
        try {
            for (frame in 0 until frameCount) {
                val canvas = surface.lockHardwareCanvas()
                try {
                    drawFrame(canvas, slides, frame * 1000L / FPS, paint)
                } finally {
                    surface.unlockCanvasAndPost(canvas)
                }
                drain(codec, endOfStream = false)
                if (frame % 10 == 0) {
                    onProgress(frame.toDouble() / frameCount)
                }
            }
            drain(codec, endOfStream = true)
            writeAudio(durationMillis * 1000)
            onProgress(1.0)
        } finally {
            slides.forEach { it.recycle() }
            codec.stop()
            codec.release()
            surface.release()
            audioExtractor?.release()
            if (muxerStarted) {
                muxer.stop()
            }
            muxer.release()
        }
    }

    private fun loadSlide(path: String): Bitmap {
        val decoded = BitmapFactory.decodeFile(path)
            ?: throw IllegalArgumentException("Image illisible : $path")
        if (decoded.width == width && decoded.height == height) {
            return decoded
        }
        val scaled = Bitmap.createScaledBitmap(decoded, width, height, true)
        decoded.recycle()
        return scaled
    }

    /**
     * L'image à l'instant [timeMillis] : la page en cours, poussée vers la
     * gauche par la suivante pendant la transition.
     */
    private fun drawFrame(canvas: Canvas, slides: List<Bitmap>, timeMillis: Long, paint: Paint) {
        canvas.drawColor(Color.BLACK)
        val index = (timeMillis / slideMillis).toInt().coerceAtMost(slides.size - 1)
        val local = timeMillis - index * slideMillis
        val pushStart = slideMillis - TRANSITION_MILLIS
        // Départ vif, arrivée en douceur.
        val push = if (local > pushStart && index + 1 < slides.size) {
            val t = (local - pushStart).toFloat() / TRANSITION_MILLIS
            1f - (1f - t) * (1f - t) * (1f - t)
        } else {
            0f
        }
        drawSlide(canvas, slides[index], local.toFloat() / slideMillis, -push * width, paint)
        if (push > 0f) {
            drawSlide(canvas, slides[index + 1], 0f, (1f - push) * width, paint)
        }
    }

    /** Une page décalée de [shiftX], agrandie de [ZOOM] au fil de [progress] (de 0 à 1). */
    private fun drawSlide(canvas: Canvas, slide: Bitmap, progress: Float, shiftX: Float, paint: Paint) {
        val scale = 1f + ZOOM * progress.coerceIn(0f, 1f)
        val w = width * scale
        val h = height * scale
        val left = (width - w) / 2 + shiftX
        val top = (height - h) / 2
        canvas.save()
        canvas.clipRect(shiftX, 0f, shiftX + width, height.toFloat())
        canvas.drawBitmap(slide, null, RectF(left, top, left + w, top + h), paint)
        canvas.restore()
    }

    private fun prepareAudio() {
        val path = audioPath ?: return
        val extractor = MediaExtractor()
        extractor.setDataSource(path)
        for (track in 0 until extractor.trackCount) {
            val format = extractor.getTrackFormat(track)
            if (format.getString(MediaFormat.KEY_MIME)?.startsWith("audio/") == true) {
                extractor.selectTrack(track)
                audioExtractor = extractor
                audioFormat = format
                return
            }
        }
        extractor.release()
    }

    /**
     * Récupère ce que l'encodeur a produit et l'écrit dans le MP4.
     *
     * Les horodatages sont recalculés à partir du numéro d'image : la surface
     * daterait chaque image de l'instant où elle a été dessinée, bien plus
     * vite que le temps réel.
     */
    private fun drain(codec: MediaCodec, endOfStream: Boolean) {
        if (endOfStream) {
            codec.signalEndOfInputStream()
        }
        while (true) {
            val index = codec.dequeueOutputBuffer(info, TIMEOUT_US)
            when {
                index == MediaCodec.INFO_TRY_AGAIN_LATER -> if (!endOfStream) return
                index == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                    videoTrack = muxer.addTrack(codec.outputFormat)
                    audioFormat?.let { audioTrack = muxer.addTrack(it) }
                    muxer.start()
                    muxerStarted = true
                }
                index >= 0 -> {
                    val buffer = codec.getOutputBuffer(index)
                    if (info.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0) {
                        info.size = 0
                    }
                    if (buffer != null && info.size > 0 && muxerStarted) {
                        info.presentationTimeUs = writtenFrames * 1_000_000L / FPS
                        writtenFrames++
                        buffer.position(info.offset)
                        buffer.limit(info.offset + info.size)
                        muxer.writeSampleData(videoTrack, buffer, info)
                    }
                    codec.releaseOutputBuffer(index, false)
                    if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                        return
                    }
                }
            }
        }
    }

    /** Recopie la musique, déjà en AAC, jusqu'à la fin de la vidéo. */
    private fun writeAudio(durationUs: Long) {
        val extractor = audioExtractor ?: return
        if (audioTrack < 0 || !muxerStarted) {
            return
        }
        val buffer = ByteBuffer.allocate(256 * 1024)
        val sample = MediaCodec.BufferInfo()
        while (true) {
            val size = extractor.readSampleData(buffer, 0)
            if (size < 0 || extractor.sampleTime > durationUs) {
                break
            }
            val flags = if (extractor.sampleFlags and MediaExtractor.SAMPLE_FLAG_SYNC != 0) {
                MediaCodec.BUFFER_FLAG_KEY_FRAME
            } else {
                0
            }
            sample.set(0, size, extractor.sampleTime, flags)
            muxer.writeSampleData(audioTrack, buffer, sample)
            extractor.advance()
        }
    }
}
