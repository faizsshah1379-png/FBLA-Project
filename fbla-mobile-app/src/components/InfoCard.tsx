import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors } from '../theme/colors';

type Props = {
  title: string;
  subtitle?: string;
  meta?: string;
};

export function InfoCard({ title, subtitle, meta }: Props) {
  return (
    <View style={styles.card}>
      <Text style={styles.title}>{title}</Text>
      {subtitle ? <Text style={styles.subtitle}>{subtitle}</Text> : null}
      {meta ? <Text style={styles.meta}>{meta}</Text> : null}
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: colors.white,
    borderRadius: 18,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: '#E6EEF9'
  },
  title: {
    fontSize: 16,
    fontWeight: '700',
    color: colors.text
  },
  subtitle: {
    fontSize: 14,
    color: colors.muted,
    marginTop: 6,
    lineHeight: 20
  },
  meta: {
    marginTop: 8,
    fontSize: 12,
    color: colors.blue,
    fontWeight: '700'
  }
});
