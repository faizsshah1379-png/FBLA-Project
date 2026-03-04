import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { colors } from '../theme/colors';

type Props = {
  title: string;
  subtitle: string;
};

export function GradientHeader({ title, subtitle }: Props) {
  return (
    <LinearGradient colors={[colors.navy, colors.royal, colors.blue]} style={styles.wrap}>
      <Text style={styles.title}>{title}</Text>
      <Text style={styles.subtitle}>{subtitle}</Text>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  wrap: {
    borderRadius: 24,
    padding: 20,
    marginBottom: 16
  },
  title: {
    color: colors.white,
    fontSize: 25,
    fontWeight: '800'
  },
  subtitle: {
    color: '#DDE8FF',
    fontSize: 14,
    marginTop: 8,
    lineHeight: 20
  }
});
