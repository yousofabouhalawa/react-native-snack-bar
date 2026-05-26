import { NativeModules, processColor, type ColorValue } from 'react-native';

export type SnackBarAnimation = 'fade' | 'slide';
export type SnackBarAppearance = 'clear-glass' | 'regular-glass' | 'solid';

export interface SnackBarOptions {
  duration?: number;
  animation?: SnackBarAnimation;
  animationDuration?: number;
  appearance?: SnackBarAppearance;
  tintColor?: ColorValue;
  interactive?: boolean;
  backgroundColor?: ColorValue;
  textColor?: ColorValue;
}

interface NativeSnackBarOptions {
  duration: number;
  animation: number;
  animationDuration: number;
  appearance: number;
  glassStyle: number;
  glassInteractive: boolean;
  color?: ReturnType<typeof processColor>;
  textColor?: ReturnType<typeof processColor>;
  glassTintColor?: ReturnType<typeof processColor>;
}

interface NativeSnackBarModule {
  show(message: string, options: NativeSnackBarOptions): void;
  dismiss(): void;
}

const animationMap: Record<SnackBarAnimation, number> = {
  fade: 1,
  slide: 2,
};

function nativeModule(): NativeSnackBarModule {
  const module = NativeModules.SnackBar as NativeSnackBarModule | undefined;
  if (!module) {
    throw new Error(
      'react-native-snack-bar is not linked. Rebuild the native app after installing the package.'
    );
  }
  return module;
}

function nativeOptions(options: SnackBarOptions): NativeSnackBarOptions {
  const appearance = options.appearance ?? 'clear-glass';
  const normalized: NativeSnackBarOptions = {
    duration: Math.max(0, options.duration ?? 3500),
    animation: animationMap[options.animation ?? 'slide'],
    animationDuration: Math.max(0, options.animationDuration ?? 350),
    appearance: appearance === 'solid' ? 1 : 0,
    glassStyle: appearance === 'regular-glass' ? 1 : 0,
    glassInteractive: options.interactive ?? false,
  };

  if (options.backgroundColor !== undefined) {
    normalized.color = processColor(options.backgroundColor);
  }
  if (options.textColor !== undefined) {
    normalized.textColor = processColor(options.textColor);
  }
  if (options.tintColor !== undefined) {
    normalized.glassTintColor = processColor(options.tintColor);
  }

  return normalized;
}

export const SnackBar = {
  show(message: string, options: SnackBarOptions = {}): void {
    if (message.trim().length === 0) {
      nativeModule().dismiss();
      return;
    }

    nativeModule().show(message, nativeOptions(options));
  },

  dismiss(): void {
    nativeModule().dismiss();
  },
};

interface ToastFunction {
  (message: string, options?: SnackBarOptions): void;
  dismiss(): void;
}

export const toast: ToastFunction = Object.assign(
  (message: string, options?: SnackBarOptions) => {
    SnackBar.show(message, options);
  },
  {
    dismiss: () => SnackBar.dismiss(),
  }
);
