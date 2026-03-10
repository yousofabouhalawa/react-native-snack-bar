import { useEffect, useRef, useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { SnackBarView } from 'react-native-snack-bar';

export default function App() {
  const dismissTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const [visible, setVisible] = useState(false);
  const [message, setMessage] = useState('Native snackbar ready');

  useEffect(() => {
    return () => {
      if (dismissTimer.current) {
        clearTimeout(dismissTimer.current);
      }
    };
  }, []);

  const showSnack = () => {
    const sampleMessages = [
      'Saved successfully.',
      'Profile updated and synced.',
      'Network is slow, retrying in the background.',
      'Native Fabric snackbar with liquid glass animation on iOS.',
      'This is a very long snack bar message to verify wrapping and dynamic height growth without overflowing the screen boundaries.',
    ];
    const nextMessage =
      sampleMessages[Math.floor(Math.random() * sampleMessages.length)] ??
      'Snack bar triggered';

    if (dismissTimer.current) {
      clearTimeout(dismissTimer.current);
    }

    setMessage(nextMessage);
    setVisible(false);
    requestAnimationFrame(() => {
      setVisible(true);
    });

    dismissTimer.current = setTimeout(() => {
      setVisible(false);
    }, 3800);
  };

  return (
    <View style={styles.container}>
      <Pressable onPress={showSnack} style={styles.button}>
        <Text style={styles.buttonLabel}>Trigger Snack Bar</Text>
      </Pressable>
      <SnackBarView
        visible={visible}
        duration={3500}
        message={message}

        color="#000000"
        textColor="#ff0000"
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#0A0D12',
  },
  button: {
    borderRadius: 14,
    backgroundColor: '#0D5BFF',
    paddingHorizontal: 18,
    paddingVertical: 12,
  },
  buttonLabel: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
});
