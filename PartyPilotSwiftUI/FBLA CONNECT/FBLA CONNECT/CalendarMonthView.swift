import SwiftUI

/// Reusable month calendar view.
/// It highlights event dates and lets the user select a day.
struct CalendarMonthView: View {
    /// Current month being displayed.
    @Binding var monthAnchor: Date
    /// Currently selected date cell.
    @Binding var selectedDate: Date
    /// Event source used to determine highlighted dates.
    let events: [EventItem]

    private let calendar = Calendar.current
    private let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]

    /// Display label like "March 2026".
    private var monthTitle: String {
        monthAnchor.formatted(.dateTime.month(.wide).year())
    }

    /// Normalized start-of-day date set for event day membership checks.
    private var eventDays: Set<Date> {
        Set(events.compactMap { $0.dateValue }.map { calendar.startOfDay(for: $0) })
    }

    /// 6-week style month grid (with leading/trailing empty cells as nil).
    private var daysGrid: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthAnchor),
              let firstWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end.addingTimeInterval(-1)) else {
            return []
        }

        var dates: [Date?] = []
        var cursor = firstWeekInterval.start
        while cursor < lastWeekInterval.end {
            if calendar.isDate(cursor, equalTo: monthAnchor, toGranularity: .month) {
                dates.append(cursor)
            } else {
                dates.append(nil)
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return dates
    }

    var body: some View {
        VStack(spacing: 10) {
            // Month navigation row.
            HStack {
                Button {
                    if let prev = calendar.date(byAdding: .month, value: -1, to: monthAnchor) {
                        monthAnchor = prev
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }

                Spacer()
                Text(monthTitle).font(.headline)
                Spacer()

                Button {
                    if let next = calendar.date(byAdding: .month, value: 1, to: monthAnchor) {
                        monthAnchor = next
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
            }

            // Weekday headers.
            HStack {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Day cell grid.
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(Array(daysGrid.enumerated()), id: \.offset) { _, day in
                    if let day {
                        let hasEvent = eventDays.contains(calendar.startOfDay(for: day))
                        let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)

                        Button {
                            selectedDate = day
                        } label: {
                            Text("\(calendar.component(.day, from: day))")
                                .font(.subheadline)
                                .frame(width: 32, height: 32)
                                .background(
                                    // Blue circle for event dates.
                                    Circle().fill(hasEvent ? Color.blue.opacity(isSelected ? 0.95 : 0.65) : Color.clear)
                                )
                                .foregroundStyle(hasEvent ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                    } else {
                        // Empty placeholder cell for alignment.
                        Color.clear.frame(height: 32)
                    }
                }
            }
            //fdsajkfnhjkasfhjksahdfkahdfak
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
//testing for github desktop change
