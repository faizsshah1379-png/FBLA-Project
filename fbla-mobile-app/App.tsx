import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';
import { HomeScreen } from './src/screens/HomeScreen';
import { ProfileScreen } from './src/screens/ProfileScreen';
import { CalendarScreen } from './src/screens/CalendarScreen';
import { ResourcesScreen } from './src/screens/ResourcesScreen';
import { NewsScreen } from './src/screens/NewsScreen';
import { CommunityScreen } from './src/screens/CommunityScreen';
import { colors } from './src/theme/colors';

const Tab = createBottomTabNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <StatusBar style="light" />
      <Tab.Navigator
        screenOptions={({ route }) => ({
          headerShown: false,
          tabBarActiveTintColor: colors.blue,
          tabBarInactiveTintColor: '#8D9AB3',
          tabBarStyle: {
            height: 68,
            paddingBottom: 8,
            paddingTop: 6,
            backgroundColor: '#FFFFFF'
          },
          tabBarIcon: ({ color, size }) => {
            const iconMap: Record<string, keyof typeof MaterialCommunityIcons.glyphMap> = {
              Dashboard: 'view-dashboard',
              Guests: 'account-group',
              Timeline: 'calendar-month',
              Budget: 'wallet',
              Vendors: 'storefront-outline',
              Ideas: 'lightbulb-on-outline'
            };

            return <MaterialCommunityIcons name={iconMap[route.name]} size={size} color={color} />;
          }
        })}
      >
        <Tab.Screen name="Dashboard" component={HomeScreen} />
        <Tab.Screen name="Guests" component={ProfileScreen} />
        <Tab.Screen name="Timeline" component={CalendarScreen} />
        <Tab.Screen name="Budget" component={ResourcesScreen} />
        <Tab.Screen name="Vendors" component={NewsScreen} />
        <Tab.Screen name="Ideas" component={CommunityScreen} />
      </Tab.Navigator>
    </NavigationContainer>
  );
}
