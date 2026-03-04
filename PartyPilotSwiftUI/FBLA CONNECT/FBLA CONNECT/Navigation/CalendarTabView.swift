import SwiftUI

/// Calendar tab with two key features:
/// 1) Event calendar + day detail view
/// 2) Reminder management
struct CalendarTabView: View {
    @EnvironmentObject var store: MemberAppStore

    /// Which month is currently shown in the month calendar.
    @State private var monthAnchor = Date()
    /// Which day user tapped in the month calendar.
    @State private var selectedDate = Date()

    /// Events for the selected date only.
    private var eventsOnSelectedDay: [EventItem] {
        store.chapterEvents.filter { event in
            guard let eventDate = event.dateValue else { return false }
            return Calendar.current.isDate(eventDate, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        AppPage(title: "Calendar & Reminders", subtitle: "FBLA events, competition dates, and member reminders.") {
            StandardCard(
                title: "Chapter Event Calendar",
                subtitle: "Showing events for \(store.profile.chapter)",
                meta: "\(store.detectedState) FBLA"
            )

            // Actual month calendar control.
            CalendarMonthView(
                monthAnchor: $monthAnchor,
                selectedDate: $selectedDate,
                events: store.chapterEvents
            )

            SectionTitle("Event Details")
            if eventsOnSelectedDay.isEmpty {
                StandardCard(
                    title: "No event on this date",
                    subtitle: selectedDate.formatted(date: .abbreviated, time: .omitted)
                )
            }
            ForEach(eventsOnSelectedDay) { event in
                StandardCard(title: event.title, subtitle: "\(event.date) | \(event.location)", meta: event.type)
            }

            SectionTitle("Add Reminder")
            LabeledInput(label: "Reminder Title", text: $store.reminderTitle, placeholder: "Ex: Practice objective test")
            LabeledInput(label: "Date (YYYY-MM-DD)", text: $store.reminderDate, placeholder: "2026-03-20")

            // Validation feedback.
            if let message = store.reminderValidationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .accessibilityLabel("Validation error: \(message)")
            }

            Button("Save Reminder") {
                store.addReminder()
            }
            .buttonStyle(.borderedProminent)
            .disabled(store.reminderValidationMessage != nil)

            SectionTitle("Saved Reminders")
            ForEach(store.reminders) { reminder in
                HStack {
                    StandardCard(title: reminder.title, subtitle: "Due: \(reminder.date)")
                    Button(role: .destructive) {
                        store.deleteReminder(reminder.id)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Delete reminder \(reminder.title)")
                }
            }
        }
    }
}
