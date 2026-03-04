import React, { useMemo, useState } from 'react';
import { ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { budgetItems, budgetSummary } from '../data/mockData';
import { colors } from '../theme/colors';
import { GradientHeader } from '../components/GradientHeader';
import { InfoCard } from '../components/InfoCard';

function money(value: number) {
  return `$${value.toLocaleString()}`;
}

export function ResourcesScreen() {
  const [query, setQuery] = useState('');

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return budgetItems;
    return budgetItems.filter((item) => item.category.toLowerCase().includes(q));
  }, [query]);

  return (
    <ScrollView style={styles.page} contentContainerStyle={styles.content}>
      <GradientHeader
        title="Budget Tracker"
        subtitle="Monitor planned vs spent amounts and keep every event under budget."
      />

      <View style={styles.summaryRow}>
        <View style={styles.summaryCard}>
          <Text style={styles.value}>{money(budgetSummary.totalBudget)}</Text>
          <Text style={styles.label}>Total Budget</Text>
        </View>
        <View style={styles.summaryCard}>
          <Text style={styles.value}>{money(budgetSummary.spent)}</Text>
          <Text style={styles.label}>Spent</Text>
        </View>
        <View style={styles.summaryCard}>
          <Text style={styles.value}>{money(budgetSummary.remaining)}</Text>
          <Text style={styles.label}>Remaining</Text>
        </View>
      </View>

      <TextInput
        value={query}
        onChangeText={setQuery}
        placeholder="Filter budget category"
        placeholderTextColor="#94A3B8"
        style={styles.input}
      />

      {filtered.map((item) => (
        <InfoCard
          key={item.id}
          title={item.category}
          subtitle={`Planned: ${money(item.planned)} • Spent: ${money(item.spent)}`}
          meta={item.spent > item.planned ? 'Over budget' : 'On track'}
        />
      ))}

      {filtered.length === 0 ? <InfoCard title="No matching categories" subtitle="Try venue, catering, or decor." /> : null}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  page: { backgroundColor: colors.bg },
  content: { padding: 16, paddingBottom: 30 },
  summaryRow: {
    flexDirection: 'row',
    gap: 8,
    marginBottom: 10
  },
  summaryCard: {
    flex: 1,
    backgroundColor: colors.white,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#E6EEF9',
    padding: 10
  },
  value: {
    fontSize: 14,
    fontWeight: '800',
    color: colors.blue
  },
  label: {
    fontSize: 11,
    color: colors.muted,
    marginTop: 4,
    fontWeight: '600'
  },
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
