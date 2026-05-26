import {
  codegenNativeComponent,
  type ColorValue,
  type ViewProps,
} from 'react-native';
import type { Int32 } from 'react-native/Libraries/Types/CodegenTypes';

export interface SnackBarViewNativeProps extends ViewProps {
  message?: string;
  visible?: boolean;
  duration?: Int32;
  alignX?: Int32;
  alignY?: Int32;
  color?: ColorValue;
  textColor?: ColorValue;
  animation?: Int32;
  animationDuration?: Int32;
  appearance?: Int32;
  glassStyle?: Int32;
  glassTintColor?: ColorValue;
  glassInteractive?: boolean;
}

export default codegenNativeComponent<SnackBarViewNativeProps>('SnackBarView');
