import { NativeModules } from 'react-native';
import { SnackBar, toast } from '../index';

const nativeSnackBar = {
  show: jest.fn(),
  dismiss: jest.fn(),
};

beforeEach(() => {
  NativeModules.SnackBar = nativeSnackBar;
  jest.clearAllMocks();
});

it('normalizes SnackBar options before presenting natively', () => {
  SnackBar.show('Saved', {
    duration: 0,
    animation: 'fade',
    animationDuration: 480,
    appearance: 'regular-glass',
    interactive: true,
  });

  expect(nativeSnackBar.show).toHaveBeenCalledWith('Saved', {
    duration: 0,
    animation: 1,
    animationDuration: 480,
    appearance: 0,
    glassStyle: 1,
    glassInteractive: true,
  });
});

it('supports the toast shorthand and dismisses an empty message', () => {
  toast('Updated');
  SnackBar.show('   ');
  toast.dismiss();

  expect(nativeSnackBar.show).toHaveBeenCalledWith('Updated', {
    duration: 3500,
    animation: 2,
    animationDuration: 350,
    appearance: 0,
    glassStyle: 0,
    glassInteractive: false,
  });
  expect(nativeSnackBar.dismiss).toHaveBeenCalledTimes(2);
});
