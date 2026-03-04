import React from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { dashboardHighlights, plannerUser } from '../data/mockData';
import { colors } from '../theme/colors';
import { GradientHeader } from '../components/GradientHeader';
import { InfoCard } from '../components/InfoCard';

export function HomeScreen() {
  return (
    <ScrollView style={styles.page} contentContainerStyle={styles.content}>
      <GradientHeader
        title="PartyPilot"
        subtitle="Plan events, track guests, manage budget, and coordinate vendors in one app."
      />

      <View style={styles.statsRow}>
        <View style={styles.statCard}>
          <Text style={styles.statValue}>{plannerUser.totalEvents}</Text>
          <Text style={styles.statLabel}>Active Events</Text>
        </View>
        <View style={styles.statCard}>
          <Text style={styles.statValue}>56</Text>
          <Text style={styles.statLabel}>Open Tasks</Text>
        </View>
      </View>

      <Text style={styles.section}>Planning Highlights</Text>
      {dashboardHighlights.map((item) => (
        <InfoCard key={item.id} title={item.title} meta={item.tag} />
      ))}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  page: { backgroundColor: colors.bg },
  content: { padding: 16, paddingBottom: 30 },
  section: {
    fontSize: 18,
    fontWeight: '800',
    color: colors.text,
    marginBottom: 12,
    marginTop: 8
  },
  statsRow: {
    flexDirection: 'row',
    gap: 10,
    marginBottom: 12
  },
  statCard: {
    flex: 1,
    backgroundColor: colors.white,
    borderRadius: 18,
    padding: 16,
    borderWidth: 1,
    borderColor: '#E6EEF9'
  },
  statValue: {
    fontSize: 24,
    fontWeight: '800',
    color: colors.blue
  },
  statLabel: {
    marginTop: 6,
    fontSize: 12,
    color: colors.muted,
    fontWeight: '600'
  }
});
