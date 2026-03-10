package com.snackbar

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

  @ReactProp(name = "message")
  override fun setMessage(view: SnackBarView?, message: String?) {
    view?.setMessage(message)
  }

  @ReactProp(name = "visible")
  override fun setVisible(view: SnackBarView?, visible: Boolean) {
    view?.setVisible(visible)
  }

  @ReactProp(name = "duration", defaultInt = 3500)
  override fun setDuration(view: SnackBarView?, duration: Int) {
    view?.setDuration(duration)
  }

  @ReactProp(name = "top", defaultBoolean = false)
  override fun setTop(view: SnackBarView?, top: Boolean) {
    view?.setTop(top)
  }

  @ReactProp(name = "alignX", defaultInt = 1)
  override fun setAlignX(view: SnackBarView?, value: Int) {
    view?.setHorizontalAlignment(value)
  }

  @ReactProp(name = "alignY", defaultInt = 2)
  override fun setAlignY(view: SnackBarView?, value: Int) {
    view?.setVerticalAlignment(value)
  }

  @ReactProp(name = "color")
  override fun setColor(view: SnackBarView?, color: Int?) {
    view?.setSnackColor(color)
  }

  @ReactProp(name = "textColor")
  override fun setTextColor(view: SnackBarView?, color: Int?) {
    view?.setSnackTextColor(color)
  }

  companion object {
    const val NAME = "SnackBarView"
  }
}
