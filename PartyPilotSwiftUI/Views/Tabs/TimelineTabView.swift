import SwiftUI

struct TimelineTabView: View {
    @EnvironmentObject var store: AppStore
    @State private var title: String = ""
    @State private var dueDate: String = ""
    @State private var error: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                BrandHeader(
                    title: "Events & Reminders",
                    subtitle: "Track chapter schedule and create custom reminders"
                )

                ForEach(store.events) { event in
                    InfoCard(
                        title: event.title,
                        subtitle: "\(event.date) at \(event.time) • \(event.location)",
                        meta: "Upcoming"
                    )
                }

                ForEach(store.reminderSettings) { item in
                    InfoCard(title: item.name, meta: item.enabledLabel)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Add Custom Reminder")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(FBLATheme.text)

                    TextField("Title (min 4 chars)", text: $title)
                        .textFieldStyle(.roundedBorder)

                    TextField("Due date YYYY-MM-DD", text: $dueDate)
                        .textFieldStyle(.roundedBorder)

                    if !error.isEmpty {
                        Text(error)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.red)
                    }

                    Button("Save Reminder") {
                        saveReminder()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(canSubmit ? FBLATheme.brightBlue : FBLATheme.muted)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(!canSubmit)
                }
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(red: 230/255, green: 238/255, blue: 249/255), lineWidth: 1))

                ForEach(store.customReminders) { reminder in
                    VStack(alignment: .leading, spacing: 6) {
                        InfoCard(title: reminder.title, subtitle: "Due: \(reminder.dueDate)")

                        Button(role: .destructive) {
                            store.deleteReminder(reminder)
                        } label: {
                            Text("Delete")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(FBLATheme.page)
    }

    private var canSubmit: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).count >= 4 && isDateFormatted(dueDate)
    }

    private func saveReminder() {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).count < 4 {
            error = "Title must be at least 4 characters."
            return
        }
        if !isDateFormatted(dueDate) {
            error = "Date must use YYYY-MM-DD format."
            return
        }

        store.addReminder(title: title, dueDate: dueDate)
        title = ""
        dueDate = ""
        error = ""
    }

    private func isDateFormatted(_ date: String) -> Bool {
        let pattern = #"^\d{4}-\d{2}-\d{2}$"#
        return date.range(of: pattern, options: .regularExpression) != nil
    }
}
