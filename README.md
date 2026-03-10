# react-native-snack-bar

A native iOS and Android snack bar in react native.

## Installation


```sh
npm install react-native-snack-bar
```


## Usage


```js
import { SnackBarView } from "react-native-snack-bar";

// ...

<SnackBarView
  visible
  message="Saved successfully"
  duration={3500}
  horizontalAlignment="center"
  verticalAlignment="bottom"
  color="rgba(20,20,20,0.85)"
  textColor="#fff"
/>
```

### Props

- `message?: string` message text.
- `visible?: boolean` show/hide the snack bar.
- `duration?: number` auto-hide duration in milliseconds. `0` keeps it visible until hidden.
- `top?: boolean` render from top edge instead of bottom.
- `horizontalAlignment?: "left" | "center" | "right"` snackbar horizontal placement. Defaults to `center`.
- `verticalAlignment?: "top" | "center" | "bottom"` snackbar vertical placement. Defaults to `bottom`.
- `color?: ColorValue` snack bar surface color.
- `textColor?: ColorValue` text color.

`SnackBarView` auto-positions itself as an overlay host, so you do not need to provide `position: "absolute"` styles for normal usage.


## Contributing

- [Development workflow](CONTRIBUTING.md#development-workflow)
- [Sending a pull request](CONTRIBUTING.md#sending-a-pull-request)
- [Code of conduct](CODE_OF_CONDUCT.md)

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
