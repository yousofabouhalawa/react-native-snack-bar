package com.snackbar

import android.content.Context
import android.text.Layout
import android.util.AttributeSet
import android.view.Gravity
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.coordinatorlayout.widget.CoordinatorLayout
import com.facebook.react.uimanager.PointerEvents
import com.facebook.react.uimanager.ReactPointerEventsView
import com.google.android.material.snackbar.Snackbar

class SnackBarView : FrameLayout, ReactPointerEventsView {
  private data class Presentation(
    val message: String,
    val durationMs: Int,
    val horizontalAlignment: Int,
    val verticalAlignment: Int,
    val backgroundColor: Int?,
    val textColor: Int?
  )

  private var snackbar: Snackbar? = null
  private var displayedPresentation: Presentation? = null
  private var replacementInProgress: Boolean = false
  private var renderScheduled: Boolean = false
  private var message: String = ""
  private var visible: Boolean = false
  private var durationMs: Int = 3500
  private var horizontalAlignment: Int = ALIGNMENT_CENTER
  private var verticalAlignment: Int = ALIGNMENT_BOTTOM
  private var backgroundColor: Int? = null
  private var textColor: Int? = null

  override val pointerEvents: PointerEvents = PointerEvents.NONE

  constructor(context: Context) : super(context)
  constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)
  constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
    context,
    attrs,
    defStyleAttr
  )

  fun setMessage(value: String?) {
    message = value?.trim().orEmpty()
    requestRender()
  }

  fun setVisible(value: Boolean) {
    visible = value
    requestRender()
  }

  fun setDuration(value: Int) {
    durationMs = value.coerceAtLeast(0)
    requestRender()
  }

  fun setHorizontalAlignment(value: Int) {
    horizontalAlignment = sanitizeAlignment(value, ALIGNMENT_CENTER)
    requestRender()
  }

  fun setVerticalAlignment(value: Int) {
    verticalAlignment = sanitizeAlignment(value, ALIGNMENT_BOTTOM)
    requestRender()
  }

  fun setSnackColor(value: Int?) {
    backgroundColor = value
    requestRender()
  }

  fun setSnackTextColor(value: Int?) {
    textColor = value
    requestRender()
  }

  override fun onAttachedToWindow() {
    super.onAttachedToWindow()
    requestRender()
  }

  override fun onDetachedFromWindow() {
    dismissSnackbar()
    super.onDetachedFromWindow()
  }

  private fun requestRender() {
    if (renderScheduled) {
      return
    }
    renderScheduled = true
    post {
      renderScheduled = false
      render()
    }
  }

  private fun render() {
    if (!isAttachedToWindow) {
      return
    }

    if (!visible || message.isBlank()) {
      dismissSnackbar()
      return
    }

    val presentation = currentPresentation()
    if (snackbar == null) {
      showSnackbar(presentation)
      return
    }

    if (displayedPresentation != presentation) {
      replaceSnackbar()
    }
  }

  private fun currentPresentation(): Presentation {
    return Presentation(
      message,
      durationMs,
      horizontalAlignment,
      verticalAlignment,
      backgroundColor,
      textColor
    )
  }

  private fun showSnackbar(presentation: Presentation) {
    val snack = Snackbar.make(this, presentation.message, Snackbar.LENGTH_SHORT).also { createdSnack ->
      snackbar = createdSnack
      displayedPresentation = presentation
      createdSnack.addCallback(object : Snackbar.Callback() {
        override fun onDismissed(transientBottomBar: Snackbar?, event: Int) {
          if (snackbar !== createdSnack) {
            return
          }
          snackbar = null
          displayedPresentation = null
          if (replacementInProgress) {
            replacementInProgress = false
            requestRender()
          }
        }
      })
    }

    snack.setText(presentation.message)
    snack.duration =
      if (presentation.durationMs == 0) Snackbar.LENGTH_INDEFINITE else presentation.durationMs

    presentation.backgroundColor?.let { snack.setBackgroundTint(it) }
    val textView = snack.view.findViewById<TextView>(com.google.android.material.R.id.snackbar_text)
    textView?.maxLines = Int.MAX_VALUE
    textView?.setSingleLine(false)
    textView?.ellipsize = null
    textView?.setHorizontallyScrolling(false)
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
      textView?.breakStrategy = Layout.BREAK_STRATEGY_HIGH_QUALITY
      textView?.hyphenationFrequency = Layout.HYPHENATION_FREQUENCY_NORMAL
    }

    presentation.textColor?.let { color ->
      snack.setTextColor(color)
      textView?.setTextColor(color)
    }

    val layoutParams = snack.view.layoutParams
    when (layoutParams) {
      is FrameLayout.LayoutParams -> {
        layoutParams.gravity = horizontalGravity(presentation.horizontalAlignment) or
          verticalGravity(presentation.verticalAlignment)
        layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT
        val edgeMargin = dpToPx(12)
        val verticalMargin = dpToPx(8)
        layoutParams.setMargins(edgeMargin, verticalMargin, edgeMargin, verticalMargin)
        snack.view.layoutParams = layoutParams
      }

      is CoordinatorLayout.LayoutParams -> {
        layoutParams.gravity = horizontalGravity(presentation.horizontalAlignment) or
          verticalGravity(presentation.verticalAlignment)
        layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT
        val edgeMargin = dpToPx(12)
        val verticalMargin = dpToPx(8)
        layoutParams.setMargins(edgeMargin, verticalMargin, edgeMargin, verticalMargin)
        snack.view.layoutParams = layoutParams
      }
    }

    snack.show()
  }

  private fun replaceSnackbar() {
    if (replacementInProgress) {
      return
    }

    val activeSnackbar = snackbar
    if (activeSnackbar == null) {
      requestRender()
      return
    }

    replacementInProgress = true
    activeSnackbar.dismiss()
  }

  private fun dismissSnackbar() {
    val activeSnackbar = snackbar
    snackbar = null
    displayedPresentation = null
    replacementInProgress = false
    activeSnackbar?.dismiss()
  }

  private fun horizontalGravity(alignment: Int): Int {
    return when (alignment) {
      ALIGNMENT_LEFT -> Gravity.START
      ALIGNMENT_RIGHT -> Gravity.END
      else -> Gravity.CENTER_HORIZONTAL
    }
  }

  private fun verticalGravity(alignment: Int): Int {
    return when (alignment) {
      ALIGNMENT_TOP -> Gravity.TOP
      ALIGNMENT_CENTER -> Gravity.CENTER_VERTICAL
      else -> Gravity.BOTTOM
    }
  }

  private fun sanitizeAlignment(value: Int, defaultValue: Int): Int {
    return when (value) {
      ALIGNMENT_LEFT, ALIGNMENT_CENTER, ALIGNMENT_RIGHT -> value
      ALIGNMENT_TOP, ALIGNMENT_BOTTOM -> value
      else -> defaultValue
    }
  }

  private fun dpToPx(dp: Int): Int {
    return (dp * resources.displayMetrics.density).toInt()
  }

  companion object {
    private const val ALIGNMENT_LEFT = 0
    private const val ALIGNMENT_TOP = 0
    private const val ALIGNMENT_CENTER = 1
    private const val ALIGNMENT_RIGHT = 2
    private const val ALIGNMENT_BOTTOM = 2
  }
}
