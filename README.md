# react-native-snack-bar

A native iOS and Android snack bar in react native.

## Installation


```sh
npm install react-native-snack-bar
```


## Usage


```js
import { toast, SnackBar } from "react-native-snack-bar";

toast("Saved successfully", {
  duration: 3500,
  animation: "slide",
});

toast.dismiss();

// Equivalent named API:
SnackBar.show("Profile updated");
SnackBar.dismiss();
```

On iOS 26 and later, the default surface is clear Liquid Glass without an
additional background fill. Use a tinted glass surface or switch to a normal
solid background explicitly:

```js
toast("Synced", {
  appearance: "regular-glass",
  tintColor: "rgba(46, 113, 255, 0.45)",
  interactive: true,
});

toast("Offline", {
  appearance: "solid",
  backgroundColor: "#111827",
  textColor: "#fff",
});
```

### Options

- `duration?: number` auto-hide duration in milliseconds. `0` keeps it visible until `toast.dismiss()` or `SnackBar.dismiss()` is called.
- `animation?: "fade" | "slide"` iOS entrance and exit animation. Defaults to `slide`; motion uses the built-in spring timing.
- `animationDuration?: number` iOS entrance animation duration in milliseconds. Exit animation uses a shorter matching duration. Defaults to `350`.
- `appearance?: "clear-glass" | "regular-glass" | "solid"` iOS surface mode. Defaults to `clear-glass`; `solid` disables glass and blur.
- `tintColor?: ColorValue` iOS 26 Liquid Glass tint. No tint is applied by default.
- `interactive?: boolean` enable UIKit's interactive Liquid Glass behavior on iOS 26. Defaults to `false`.
- `backgroundColor?: ColorValue` solid-mode background color.
- `textColor?: ColorValue` text color.

No host component or visibility state is required. `toast()` and `SnackBar.show()` present a bottom-centered native overlay from the active screen. On iOS, the surface grows with wrapped text up to the available screen width while keeping space at each horizontal edge. On versions before iOS 26, glass mode uses the closest available material blur fallback.

Calling `toast()` or `SnackBar.show()` while one is visible dismisses the displayed snackbar before presenting the new one instead of changing its text or style in place.


## Contributing

- [Development workflow](CONTRIBUTING.md#development-workflow)
- [Sending a pull request](CONTRIBUTING.md#sending-a-pull-request)
- [Code of conduct](CODE_OF_CONDUCT.md)

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
