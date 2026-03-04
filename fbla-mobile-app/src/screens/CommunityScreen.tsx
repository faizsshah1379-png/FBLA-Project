import React from 'react';
import { Linking, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { inspirationBoards } from '../data/mockData';
import { colors } from '../theme/colors';
import { GradientHeader } from '../components/GradientHeader';

const sourceLinks: Record<string, string> = {
  'Pinterest Board': 'https://www.pinterest.com',
  'Instagram Collection': 'https://www.instagram.com',
  'YouTube Playlist': 'https://www.youtube.com',
  'TikTok Favorites': 'https://www.tiktok.com',
  'Design Moodboard': 'https://dribbble.com'
};

export function CommunityScreen() {
  return (
    <ScrollView style={styles.page} contentContainerStyle={styles.content}>
      <GradientHeader
        title="Theme Inspiration"
        subtitle="Save and explore theme ideas from social platforms and design boards."
      />

      {inspirationBoards.map((board) => (
        <View key={board.id} style={styles.card}>
          <Text style={styles.title}>{board.theme}</Text>
          <Text style={styles.handle}>{board.source}</Text>
          <Text style={styles.subtitle}>{board.detail}</Text>

          <Pressable style={styles.connectBtn} onPress={() => void Linking.openURL(sourceLinks[board.source])}>
            <Text style={styles.connectText}>Open Source</Text>
          </Pressable>
        </View>
      ))}

      <Text style={styles.note}>
        Tip: Keep moodboards tied to your budget and venue size to avoid unrealistic planning choices.
      </Text>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  page: { backgroundColor: colors.bg },
  content: { padding: 16, paddingBottom: 30 },
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
    fontWeight: '800',
    color: colors.text
  },
  handle: {
    marginTop: 3,
    color: colors.blue,
    fontWeight: '700'
  },
  subtitle: {
    marginTop: 8,
    fontSize: 14,
    color: colors.muted,
    lineHeight: 20
  },
  connectBtn: {
    alignSelf: 'flex-start',
    marginTop: 10,
    backgroundColor: '#EAF2FF',
    borderRadius: 10,
    paddingVertical: 8,
    paddingHorizontal: 12
  },
  connectText: {
    color: colors.blue,
    fontWeight: '700',
    fontSize: 12
  },
  note: {
    marginTop: 8,
    fontSize: 13,
    color: colors.muted,
    lineHeight: 20,
    backgroundColor: '#EAF2FF',
    borderRadius: 14,
    padding: 12
  }
});
