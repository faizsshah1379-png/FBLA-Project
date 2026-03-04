import React from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { guestGroups, plannerUser, sampleGuests } from '../data/mockData';
import { colors } from '../theme/colors';
import { GradientHeader } from '../components/GradientHeader';
import { InfoCard } from '../components/InfoCard';

export function ProfileScreen() {
  return (
    <ScrollView style={styles.page} contentContainerStyle={styles.content}>
      <GradientHeader title="Guest Management" subtitle="Track invites, RSVP status, and meal preferences." />

      <View style={styles.profileCard}>
        <Text style={styles.name}>{plannerUser.name}</Text>
        <Text style={styles.role}>{plannerUser.role}</Text>
        <Text style={styles.meta}>Preferred Theme: {plannerUser.preferredTheme}</Text>
      </View>

      <Text style={styles.section}>RSVP by Group</Text>
      {guestGroups.map((group) => (
        <InfoCard
          key={group.id}
          title={`${group.name} • Invited ${group.invited}`}
          subtitle={`Yes: ${group.rsvpYes} | No: ${group.rsvpNo} | Pending: ${group.pending}`}
        />
      ))}

      <Text style={styles.section}>Guest List Preview</Text>
      {sampleGuests.map((guest) => (
        <InfoCard
          key={guest.id}
          title={guest.name}
          subtitle={`${guest.group} • Meal: ${guest.meal}`}
          meta={guest.status}
        />
      ))}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  page: { backgroundColor: colors.bg },
  content: { padding: 16, paddingBottom: 30 },
  profileCard: {
    backgroundColor: colors.white,
    borderRadius: 18,
    padding: 18,
    marginBottom: 14,
    borderWidth: 1,
    borderColor: '#E6EEF9'
  },
  name: { fontSize: 24, fontWeight: '800', color: colors.text },
  role: { fontSize: 16, marginTop: 4, color: colors.blue, fontWeight: '700' },
  meta: { fontSize: 14, marginTop: 6, color: colors.muted },
  section: {
    fontSize: 18,
    fontWeight: '800',
    color: colors.text,
    marginBottom: 12
  }
});
