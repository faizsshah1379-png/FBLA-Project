import { useCallback, useEffect, useMemo, useState } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

const STORAGE_KEY = 'fbla_custom_reminders_v1';

export type CustomReminder = {
  id: string;
  title: string;
  date: string;
};

const seed: CustomReminder[] = [
  { id: 'r1', title: 'Submit NLC travel form', date: '2026-03-18' },
  { id: 'r2', title: 'Practice objective test set B', date: '2026-03-22' },
  { id: 'r3', title: 'Upload final presentation slides', date: '2026-03-27' }
];

export function useStoredReminders() {
  const [items, setItems] = useState<CustomReminder[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let isMounted = true;

    async function load() {
      try {
        const raw = await AsyncStorage.getItem(STORAGE_KEY);
        if (!isMounted) return;
        if (!raw) {
          setItems(seed);
          return;
        }

        const parsed = JSON.parse(raw) as CustomReminder[];
        setItems(Array.isArray(parsed) ? parsed : seed);
      } catch {
        setItems(seed);
      } finally {
        if (isMounted) setLoading(false);
      }
    }

    void load();

    return () => {
      isMounted = false;
    };
  }, []);

  useEffect(() => {
    if (loading) return;
    void AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(items));
  }, [items, loading]);

  const addReminder = useCallback((title: string, date: string) => {
    const newItem: CustomReminder = {
      id: `${Date.now()}`,
      title: title.trim(),
      date: date.trim()
    };
    setItems((prev) => [newItem, ...prev]);
  }, []);

  const deleteReminder = useCallback((id: string) => {
    setItems((prev) => prev.filter((item) => item.id !== id));
  }, []);

  return useMemo(
    () => ({ items, loading, addReminder, deleteReminder }),
    [items, loading, addReminder, deleteReminder]
  );
}
