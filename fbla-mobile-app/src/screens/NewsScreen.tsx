import React, { useMemo, useState } from 'react';
import { ScrollView, StyleSheet, TextInput } from 'react-native';
import { vendors } from '../data/mockData';
import { colors } from '../theme/colors';
import { GradientHeader } from '../components/GradientHeader';
import { InfoCard } from '../components/InfoCard';

export function NewsScreen() {
  const [query, setQuery] = useState('');

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return vendors;
    return vendors.filter((item) => item.type.toLowerCase().includes(q) || item.name.toLowerCase().includes(q));
  }, [query]);

  return (
    <ScrollView style={styles.page} contentContainerStyle={styles.content}>
      <GradientHeader
        title="Vendor Hub"
        subtitle="Compare and manage venues, catering, music, decor, and more."
      />

      <TextInput
        value={query}
        onChangeText={setQuery}
        placeholder="Search vendors"
        placeholderTextColor="#94A3B8"
        style={styles.input}
      />

      {filtered.map((item) => (
        <InfoCard
          key={item.id}
          title={`${item.name} • ${item.type}`}
          subtitle={item.notes}
          meta={`Rating ${item.rating}/5`}
        />
      ))}

      {filtered.length === 0 ? <InfoCard title="No vendors found" subtitle="Try type names like venue, decor, or music." /> : null}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  page: { backgroundColor: colors.bg },
  content: { padding: 16, paddingBottom: 30 },
  input: {
    borderWidth: 1,
    borderColor: '#D6E1F1',
    borderRadius: 12,
    paddingHorizontal: 12,
    paddingVertical: 10,
    marginBottom: 10,
    color: colors.text,
    backgroundColor: '#FBFDFF'
  }
});
