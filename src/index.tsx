import SnackBarViewNativeComponent, {
  type SnackBarViewNativeProps,
} from './SnackBarViewNativeComponent';
import { StyleSheet } from 'react-native';

export type SnackBarHorizontalAlignment = 'left' | 'center' | 'right';
export type SnackBarVerticalAlignment = 'top' | 'center' | 'bottom';

export interface SnackBarViewProps
  extends Omit<SnackBarViewNativeProps, 'alignX' | 'alignY'> {
  horizontalAlignment?: SnackBarHorizontalAlignment;
  verticalAlignment?: SnackBarVerticalAlignment;
}

const horizontalAlignmentMap: Record<SnackBarHorizontalAlignment, number> = {
  left: 0,
  center: 1,
  right: 2,
};

const verticalAlignmentMap: Record<SnackBarVerticalAlignment, number> = {
  top: 0,
  center: 1,
  bottom: 2,
};

export function SnackBarView({
  horizontalAlignment = 'center',
  verticalAlignment = 'bottom',
  top,
  pointerEvents = 'none',
  style,
  ...rest
}: SnackBarViewProps) {
  const resolvedVerticalAlignment = top ? 'top' : verticalAlignment;

  return (
    <SnackBarViewNativeComponent
      {...rest}
      top={top}
      pointerEvents={pointerEvents}
      style={[styles.overlayHost, style]}
      alignX={horizontalAlignmentMap[horizontalAlignment]}
      alignY={verticalAlignmentMap[resolvedVerticalAlignment]}
    />
  );
}

export { SnackBarViewNativeComponent };

const styles = StyleSheet.create({
  overlayHost: {
    position: 'absolute',
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
  },
});
