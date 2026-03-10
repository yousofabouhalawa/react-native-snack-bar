package com.snackbar

import android.graphics.Color
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.SnackBarViewManagerInterface
import com.facebook.react.viewmanagers.SnackBarViewManagerDelegate

@ReactModule(name = SnackBarViewManager.NAME)
class SnackBarViewManager : SimpleViewManager<SnackBarView>(),
  SnackBarViewManagerInterface<SnackBarView> {
  private val mDelegate: ViewManagerDelegate<SnackBarView>

  init {
    mDelegate = SnackBarViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<SnackBarView>? {
    return mDelegate
  }

  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): SnackBarView {
    return SnackBarView(context)
  }

  @ReactProp(name = "color")
  override fun setColor(view: SnackBarView?, color: Int?) {
    view?.setBackgroundColor(color ?: Color.TRANSPARENT)
  }

  companion object {
    const val NAME = "SnackBarView"
  }
}
