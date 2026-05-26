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

  @ReactProp(name = "animation", defaultInt = 3)
  override fun setAnimation(view: SnackBarView?, value: Int) {
    // Custom animation styles are implemented by the iOS native view.
  }

  @ReactProp(name = "animationDuration", defaultInt = 350)
  override fun setAnimationDuration(view: SnackBarView?, value: Int) {
    // Custom animation duration is implemented by the iOS native view.
  }

  @ReactProp(name = "appearance", defaultInt = 0)
  override fun setAppearance(view: SnackBarView?, value: Int) {
    // Liquid Glass appearance is implemented by the iOS native view.
  }

  @ReactProp(name = "glassStyle", defaultInt = 0)
  override fun setGlassStyle(view: SnackBarView?, value: Int) {
    // Liquid Glass styles are implemented by the iOS native view.
  }

  @ReactProp(name = "glassTintColor")
  override fun setGlassTintColor(view: SnackBarView?, color: Int?) {
    // Liquid Glass tint is implemented by the iOS native view.
  }

  @ReactProp(name = "glassInteractive", defaultBoolean = false)
  override fun setGlassInteractive(view: SnackBarView?, interactive: Boolean) {
    // Interactive Liquid Glass is implemented by the iOS native view.
  }

  companion object {
    const val NAME = "SnackBarView"
  }
}
