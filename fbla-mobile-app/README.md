# PartyPilot (FBLA Mobile Application Development)

Expo React Native app built to align with the 2025-2026 FBLA Mobile Application Development event topic (party/event planning).

## Topic Alignment

This app is designed for planning and managing parties, events, and gatherings, with practical tools that judges can navigate live during the demo.

## What the App Includes

- `Dashboard`: progress highlights and planning status
- `Guests`: RSVP tracking, guest groups, and meal preferences
- `Timeline`: event schedule plus validated custom reminders
- `Budget`: planned vs spent budget tracking by category
- `Vendors`: vendor directory with ratings and quick filtering
- `Ideas`: theme inspiration boards with external source links

All tabs include substantial content (not empty placeholders).

## Rubric-Oriented Functionality

- Multi-screen navigation with reusable UI components
- Local persistent data (`AsyncStorage`) for custom reminders
- Input validation (minimum title length + date format)
- Search/filter behavior in budget and vendor sections
- External linking for inspiration/social-source integration

## Run Locally

```bash
cd fbla-mobile-app
npm install
npm run start
```

Open with Expo Go or device emulators.

## Before Competition Submission

- Replace mock event data with your final event scenario.
- Add your presentation assets (flowchart, storyboard, and speaking script).
- Include citations/attributions for external assets in your project documentation.
