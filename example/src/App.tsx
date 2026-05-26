import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { toast, type SnackBarOptions } from 'react-native-snack-bar';

interface Demo extends SnackBarOptions {
  label: string;
  description: string;
  message: string;
}

interface DemoSection {
  title: string;
  demos: Demo[];
}

const defaultDemo: Demo = {
  label: 'Clear glass default',
  description:
    'The default iOS 26 surface uses clear Liquid Glass with no tint fill.',
  message: 'iOS 26 default: fully clear Liquid Glass with no tint fill.',
  duration: 3500,
};

const sections: DemoSection[] = [
  {
    title: 'Liquid Glass',
    demos: [
      defaultDemo,
      {
        label: 'Regular glass',
        description: 'Uses the more visible regular Liquid Glass material.',
        message: 'Regular Liquid Glass style.',
        duration: 3500,
        appearance: 'regular-glass',
      },
      {
        label: 'Tinted glass',
        description: 'Applies a blue tint while keeping the clear glass style.',
        message: 'Clear glass tinted blue.',
        duration: 3500,
        appearance: 'clear-glass',
        tintColor: '#357CFF',
      },
      {
        label: 'Interactive glass',
        description: 'Uses interactive regular glass with a violet tint.',
        message: 'Interactive regular glass with a violet tint.',
        duration: 3500,
        appearance: 'regular-glass',
        tintColor: '#8B5CF6',
        interactive: true,
      },
    ],
  },
  {
    title: 'Content And Solid Surfaces',
    demos: [
      {
        label: 'Wrapped text',
        description:
          'A long message grows vertically and stays inside screen margins.',
        message:
          'This is a longer snackbar message that wraps onto multiple lines and grows vertically while remaining inside the screen margins.',
        duration: 5000,
        animation: 'slide',
      },
      {
        label: 'Custom colors',
        description: 'Disables glass and renders a solid blue background.',
        message: 'Solid blue surface with white text and no Liquid Glass.',
        duration: 3500,
        appearance: 'solid',
        backgroundColor: '#1649B8',
        textColor: '#FFFFFF',
        animation: 'fade',
      },
      {
        label: 'High contrast',
        description: 'Combines a solid dark surface with warm text.',
        message: 'Solid dark surface with warm highlighted text.',
        duration: 3500,
        appearance: 'solid',
        backgroundColor: '#111827',
        textColor: '#FDE68A',
        animation: 'fade',
      },
    ],
  },
  {
    title: 'Animations',
    demos: [
      {
        label: 'Fade',
        description: 'Fades the complete snackbar surface in and out.',
        message: 'Fade animation.',
        duration: 3000,
        animation: 'fade',
        animationDuration: 450,
      },
      {
        label: 'Slide',
        description:
          'Slides up from below the screen using the built-in spring motion.',
        message: 'Slide animation.',
        duration: 3000,
        animation: 'slide',
        animationDuration: 450,
      },
    ],
  },
  {
    title: 'Duration',
    demos: [
      {
        label: 'Quick 1 second',
        description: 'Automatically dismisses after one second.',
        message: 'This dismisses after one second.',
        duration: 1000,
        animation: 'fade',
        animationDuration: 200,
      },
      {
        label: 'Persistent',
        description: 'Stays visible until the dismiss action is pressed.',
        message: 'Duration is 0. Use Dismiss Current to hide this snackbar.',
        duration: 0,
        animation: 'slide',
      },
    ],
  },
];

export default function App() {
  return (
    <View style={styles.container}>
      <ScrollView
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
      >
        <Text style={styles.title}>React Native Snack Bar</Text>
        <Text style={styles.subtitle}>
          Explore Liquid Glass, solid backgrounds, duration, and motion.
        </Text>

        {sections.map((section) => (
          <View key={section.title} style={styles.section}>
            <Text style={styles.sectionTitle}>{section.title}</Text>
            <View style={styles.cardList}>
              {section.demos.map((demo) => (
                <View key={demo.label} style={styles.demoCard}>
                  <Text style={styles.cardTitle}>{demo.label}</Text>
                  <Text style={styles.cardDescription}>{demo.description}</Text>
                  <Pressable
                    onPress={() => toast(demo.message, demo)}
                    style={({ pressed }) => [
                      styles.button,
                      pressed && styles.pressedButton,
                    ]}
                  >
                    <Text style={styles.buttonLabel}>Show</Text>
                  </Pressable>
                </View>
              ))}
            </View>
          </View>
        ))}

        <Pressable onPress={() => toast.dismiss()} style={styles.dismissButton}>
          <Text style={styles.dismissLabel}>Dismiss Current</Text>
        </Pressable>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0A0D12',
  },
  content: {
    paddingTop: 64,
    paddingHorizontal: 18,
    paddingBottom: 48,
  },
  title: {
    color: '#FFFFFF',
    fontSize: 30,
    fontWeight: '700',
  },
  subtitle: {
    color: '#AAB5C7',
    fontSize: 15,
    lineHeight: 22,
    marginTop: 6,
    marginBottom: 26,
  },
  section: {
    marginBottom: 20,
  },
  sectionTitle: {
    color: '#F2F5FA',
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 10,
  },
  cardList: {
    gap: 10,
  },
  demoCard: {
    backgroundColor: '#141A24',
    borderColor: '#29354A',
    borderRadius: 16,
    borderWidth: 1,
    padding: 14,
  },
  cardTitle: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  cardDescription: {
    color: '#AAB5C7',
    fontSize: 13,
    lineHeight: 19,
    marginBottom: 13,
    marginTop: 5,
  },
  button: {
    alignSelf: 'flex-start',
    backgroundColor: '#17366E',
    borderColor: '#3F7BEE',
    borderRadius: 10,
    borderWidth: 1,
    paddingHorizontal: 18,
    paddingVertical: 9,
  },
  pressedButton: {
    opacity: 0.72,
  },
  buttonLabel: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '500',
  },
  dismissButton: {
    borderColor: '#54647D',
    borderRadius: 12,
    borderWidth: 1,
    paddingVertical: 13,
    marginTop: 4,
  },
  dismissLabel: {
    color: '#CFD8E8',
    fontSize: 14,
    fontWeight: '600',
    textAlign: 'center',
  },
});
