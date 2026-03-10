package com.snackbar

import android.content.Context
import android.text.Layout
import android.util.AttributeSet
import android.view.Gravity
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.coordinatorlayout.widget.CoordinatorLayout
import com.google.android.material.snackbar.Snackbar

class SnackBarView : FrameLayout {
  private var snackbar: Snackbar? = null
  private var message: String = ""
  private var visible: Boolean = false
  private var durationMs: Int = 3500
  private var top: Boolean = false
  private var horizontalAlignment: Int = ALIGNMENT_CENTER
  private var verticalAlignment: Int = ALIGNMENT_BOTTOM
  private var backgroundColor: Int? = null
  private var textColor: Int? = null

  constructor(context: Context) : super(context)
  constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)
  constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
    context,
    attrs,
    defStyleAttr
  )

  fun setMessage(value: String?) {
    message = value?.trim().orEmpty()
    render()
  }

  fun setVisible(value: Boolean) {
    visible = value
    render()
  }

  fun setDuration(value: Int) {
    durationMs = value.coerceAtLeast(0)
    render()
  }

  fun setTop(value: Boolean) {
    top = value
    verticalAlignment = if (value) ALIGNMENT_TOP else ALIGNMENT_BOTTOM
    render()
  }

  fun setHorizontalAlignment(value: Int) {
    horizontalAlignment = sanitizeAlignment(value, ALIGNMENT_CENTER)
    render()
  }

  fun setVerticalAlignment(value: Int) {
    verticalAlignment = sanitizeAlignment(value, ALIGNMENT_BOTTOM)
    top = verticalAlignment == ALIGNMENT_TOP
    render()
  }

  fun setSnackColor(value: Int?) {
    backgroundColor = value
    render()
  }

  fun setSnackTextColor(value: Int?) {
    textColor = value
    render()
  }

  override fun onAttachedToWindow() {
    super.onAttachedToWindow()
    render()
  }

  override fun onDetachedFromWindow() {
    dismissSnackbar()
    super.onDetachedFromWindow()
  }

  private fun render() {
    if (!isAttachedToWindow) {
      return
    }

    if (!visible || message.isBlank()) {
      dismissSnackbar()
      return
    }

    showSnackbar()
  }

  private fun showSnackbar() {
    val snack = snackbar ?: Snackbar.make(this, message, Snackbar.LENGTH_SHORT).also {
      snackbar = it
    }

    snack.setText(message)
    snack.duration = durationMs

    backgroundColor?.let { snack.setBackgroundTint(it) }
    val textView = snack.view.findViewById<TextView>(com.google.android.material.R.id.snackbar_text)
    textView?.maxLines = Int.MAX_VALUE
    textView?.setSingleLine(false)
    textView?.ellipsize = null
    textView?.setHorizontallyScrolling(false)
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
      textView?.breakStrategy = Layout.BREAK_STRATEGY_HIGH_QUALITY
      textView?.hyphenationFrequency = Layout.HYPHENATION_FREQUENCY_NORMAL
    }

    textColor?.let { color ->
      snack.setTextColor(color)
      textView?.setTextColor(color)
    }

    val layoutParams = snack.view.layoutParams
    when (layoutParams) {
      is FrameLayout.LayoutParams -> {
        layoutParams.gravity = horizontalGravity() or verticalGravity()
        layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT
        val edgeMargin = dpToPx(12)
        val verticalMargin = dpToPx(8)
        layoutParams.setMargins(edgeMargin, verticalMargin, edgeMargin, verticalMargin)
        snack.view.layoutParams = layoutParams
      }

      is CoordinatorLayout.LayoutParams -> {
        layoutParams.gravity = horizontalGravity() or verticalGravity()
        layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT
        val edgeMargin = dpToPx(12)
        val verticalMargin = dpToPx(8)
        layoutParams.setMargins(edgeMargin, verticalMargin, edgeMargin, verticalMargin)
        snack.view.layoutParams = layoutParams
      }
    }

    if (!snack.isShown) {
      snack.show()
    }
  }

  private fun dismissSnackbar() {
    snackbar?.dismiss()
    snackbar = null
  }

  private fun horizontalGravity(): Int {
    return when (horizontalAlignment) {
      ALIGNMENT_LEFT -> Gravity.START
      ALIGNMENT_RIGHT -> Gravity.END
      else -> Gravity.CENTER_HORIZONTAL
    }
  }

  private fun verticalGravity(): Int {
    return when (verticalAlignment) {
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
