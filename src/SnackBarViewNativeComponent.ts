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
  top?: boolean;
  alignX?: Int32;
  alignY?: Int32;
  color?: ColorValue;
  textColor?: ColorValue;
}

export default codegenNativeComponent<SnackBarViewNativeProps>('SnackBarView');
