package com.snackbar

import android.text.Layout
import android.view.Gravity
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.coordinatorlayout.widget.CoordinatorLayout
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.UiThreadUtil
import com.facebook.react.module.annotations.ReactModule
import com.google.android.material.snackbar.Snackbar

@ReactModule(name = SnackBarModule.NAME)
class SnackBarModule(private val reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {
  private data class Presentation(
    val message: String,
    val durationMs: Int,
    val backgroundColor: Int?,
    val textColor: Int?
  )

  private var snackbar: Snackbar? = null
  private var pendingPresentation: Presentation? = null
  private var replacementInProgress = false

  override fun getName(): String = NAME

  @ReactMethod
  fun show(message: String, options: ReadableMap) {
    val presentation = presentationFrom(message, options)
    UiThreadUtil.runOnUiThread {
      pendingPresentation = presentation
      if (snackbar == null) {
        presentPending()
      } else if (!replacementInProgress) {
        replacementInProgress = true
        snackbar?.dismiss()
      }
    }
  }

  @ReactMethod
  fun dismiss() {
    UiThreadUtil.runOnUiThread {
      pendingPresentation = null
      replacementInProgress = false
      val activeSnackbar = snackbar
      snackbar = null
      activeSnackbar?.dismiss()
    }
  }

  private fun presentationFrom(message: String, options: ReadableMap): Presentation {
    return Presentation(
      message.trim(),
      options.intOrDefault("duration", 3500).coerceAtLeast(0),
      options.optionalColor("color"),
      options.optionalColor("textColor")
    )
  }

  private fun presentPending() {
    val activity = reactContext.currentActivity ?: return
    val presentation = pendingPresentation ?: return
    if (presentation.message.isBlank()) {
      return
    }

    pendingPresentation = null
    val anchor = activity.findViewById<ViewGroup>(android.R.id.content)
    val createdSnack = Snackbar.make(anchor, presentation.message, Snackbar.LENGTH_SHORT)
    snackbar = createdSnack
    createdSnack.addCallback(object : Snackbar.Callback() {
      override fun onDismissed(transientBottomBar: Snackbar?, event: Int) {
        if (snackbar !== createdSnack) {
          return
        }

        snackbar = null
        if (replacementInProgress) {
          replacementInProgress = false
          presentPending()
        }
      }
    })

    createdSnack.duration =
      if (presentation.durationMs == 0) Snackbar.LENGTH_INDEFINITE else presentation.durationMs
    presentation.backgroundColor?.let { createdSnack.setBackgroundTint(it) }

    val textView =
      createdSnack.view.findViewById<TextView>(com.google.android.material.R.id.snackbar_text)
    textView?.maxLines = Int.MAX_VALUE
    textView?.setSingleLine(false)
    textView?.ellipsize = null
    textView?.setHorizontallyScrolling(false)
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
      textView?.breakStrategy = Layout.BREAK_STRATEGY_HIGH_QUALITY
      textView?.hyphenationFrequency = Layout.HYPHENATION_FREQUENCY_NORMAL
    }
    presentation.textColor?.let { color ->
      createdSnack.setTextColor(color)
      textView?.setTextColor(color)
    }

    applyLayout(createdSnack, presentation)
    createdSnack.show()
  }

  private fun applyLayout(snack: Snackbar, presentation: Presentation) {
    val layoutParams = snack.view.layoutParams
    val gravity = Gravity.CENTER_HORIZONTAL or Gravity.BOTTOM
    val edgeMargin = dpToPx(12)
    val verticalMargin = dpToPx(8)

    when (layoutParams) {
      is FrameLayout.LayoutParams -> {
        layoutParams.gravity = gravity
        layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT
        layoutParams.setMargins(edgeMargin, verticalMargin, edgeMargin, verticalMargin)
        snack.view.layoutParams = layoutParams
      }

      is CoordinatorLayout.LayoutParams -> {
        layoutParams.gravity = gravity
        layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT
        layoutParams.setMargins(edgeMargin, verticalMargin, edgeMargin, verticalMargin)
        snack.view.layoutParams = layoutParams
      }
    }
  }

  private fun dpToPx(dp: Int): Int = (dp * reactContext.resources.displayMetrics.density).toInt()

  private fun ReadableMap.intOrDefault(key: String, defaultValue: Int): Int =
    if (hasKey(key) && !isNull(key)) getDouble(key).toInt() else defaultValue

  private fun ReadableMap.optionalColor(key: String): Int? =
    if (hasKey(key) && !isNull(key)) getDouble(key).toLong().toInt() else null

  companion object {
    const val NAME = "SnackBar"
  }
}
