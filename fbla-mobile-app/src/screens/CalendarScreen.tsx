import React, { useMemo, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { partyEvents, reminderSettings } from '../data/mockData';
import { colors } from '../theme/colors';
import { GradientHeader } from '../components/GradientHeader';
import { InfoCard } from '../components/InfoCard';
import { useStoredReminders } from '../hooks/useStoredReminders';

const dateRegex = /^\d{4}-\d{2}-\d{2}$/;

export function CalendarScreen() {
  const { items, loading, addReminder, deleteReminder } = useStoredReminders();
  const [title, setTitle] = useState('');
  const [date, setDate] = useState('');
  const [error, setError] = useState('');

  const canSubmit = useMemo(() => title.trim().length >= 4 && dateRegex.test(date.trim()), [title, date]);

  function onAddReminder() {
    if (title.trim().length < 4) {
      setError('Reminder title must be at least 4 characters.');
      return;
    }
    if (!dateRegex.test(date.trim())) {
      setError('Date must use YYYY-MM-DD format.');
      return;
    }

    addReminder(title, date);
    setTitle('');
    setDate('');
    setError('');
  }

  return (
    <ScrollView style={styles.page} contentContainerStyle={styles.content}>
      <GradientHeader
        title="Event Timeline"
        subtitle="Keep every party event, task deadline, and reminder in one schedule."
      />

      <Text style={styles.section}>Upcoming Events</Text>
      {partyEvents.map((event) => (
        <InfoCard
          key={event.id}
          title={event.title}
          subtitle={`${event.date} at ${event.time} • ${event.location}`}
          meta="Add reminder"
        />
      ))}

      <Text style={styles.section}>Reminder Settings</Text>
      {reminderSettings.map((item) => (
        <InfoCard key={item.id} title={item.name} meta={item.status} />
      ))}

      <Text style={styles.section}>Custom Reminders</Text>
      <View style={styles.formCard}>
        <Text style={styles.label}>Title</Text>
        <TextInput
          value={title}
          onChangeText={setTitle}
          placeholder="Ex: Confirm final headcount"
          placeholderTextColor="#94A3B8"
          style={styles.input}
        />

        <Text style={styles.label}>Date</Text>
        <TextInput
          value={date}
          onChangeText={setDate}
          placeholder="YYYY-MM-DD"
          placeholderTextColor="#94A3B8"
          style={styles.input}
        />

        {error ? <Text style={styles.error}>{error}</Text> : null}

        <Pressable
          onPress={onAddReminder}
          style={[styles.button, !canSubmit && styles.buttonDisabled]}
          disabled={!canSubmit}
        >
          <Text style={styles.buttonText}>Save Reminder</Text>
        </Pressable>
      </View>

      {loading ? <InfoCard title="Loading reminders..." /> : null}
      {!loading && items.length === 0 ? <InfoCard title="No reminders yet" subtitle="Use the form above to add one." /> : null}

      {!loading &&
        items.map((item) => (
          <View key={item.id}>
            <InfoCard title={item.title} subtitle={`Due: ${item.date}`} />
            <Pressable onPress={() => deleteReminder(item.id)} style={styles.deleteBtn}>
              <Text style={styles.deleteText}>Delete</Text>
            </Pressable>
          </View>
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
    marginTop: 6
  },
  formCard: {
    backgroundColor: colors.white,
    borderRadius: 18,
    padding: 14,
    borderWidth: 1,
    borderColor: '#E6EEF9',
    marginBottom: 12
  },
  label: {
    fontSize: 13,
    color: colors.muted,
    fontWeight: '700',
    marginBottom: 6
  },
  input: {
    borderWidth: 1,
    borderColor: '#D6E1F1',
    borderRadius: 12,
    paddingHorizontal: 12,
    paddingVertical: 10,
    marginBottom: 12,
    color: colors.text,
    backgroundColor: '#FBFDFF'
  },
  error: {
    color: '#DC2626',
    marginBottom: 10,
    fontSize: 12,
    fontWeight: '600'
  },
  button: {
    backgroundColor: colors.blue,
    borderRadius: 12,
    paddingVertical: 12,
    alignItems: 'center'
  },
  buttonDisabled: {
    opacity: 0.55
  },
  buttonText: {
    color: colors.white,
    fontWeight: '700'
  },
  deleteBtn: {
    alignSelf: 'flex-end',
    marginTop: -8,
    marginBottom: 10,
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 10,
    backgroundColor: '#FFE4E6'
  },
  deleteText: {
    fontSize: 12,
    color: '#9F1239',
    fontWeight: '700'
  }
});
