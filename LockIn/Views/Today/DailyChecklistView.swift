import SwiftUI
import SwiftData

struct DailyChecklistView: View {
    @Bindable var log: DailyLog
    @Environment(\.modelContext) private var modelContext

    private let groups = ["Morning", "Nutrition", "Compliance", "Activity"]

    var body: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "Checklist \u2014 \(log.totalPoints) pts")
            ForEach(groups, id: \.self) { group in
                let items = log.checklistItems
                    .filter { $0.category.group == group }
                    .sorted { $0.category.rawValue < $1.category.rawValue }
                if !items.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(items) { item in
                            ChecklistRow(item: item, onToggle: {
                                item.toggle()
                                try? modelContext.save()
                            })
                            if item.id != items.last?.id {
                                Divider().background(LockInTheme.border)
                            }
                        }
                    }
                    .cardStyle()
                }
            }
        }
    }
}

struct ChecklistRow: View {
    let item: ChecklistEntry
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                // Checkmark
                ZStack {
                    Circle()
                        .fill(item.isCompleted ? LockInTheme.accent : LockInTheme.surface)
                        .frame(width: 28, height: 28)
                    if item.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Circle().stroke(LockInTheme.borderBright, lineWidth: 1.5)
                            .frame(width: 28, height: 28)
                    }
                }

                // Icon + label
                Image(systemName: item.category.sfSymbol)
                    .font(.system(size: 14))
                    .foregroundColor(item.isCompleted ? LockInTheme.accent : LockInTheme.textMuted)
                    .frame(width: 18)

                Text(item.category.displayName)
                    .font(.system(size: 14))
                    .foregroundColor(item.isCompleted ? LockInTheme.textPrimary : LockInTheme.textSecondary)
                    .strikethrough(item.isCompleted, color: LockInTheme.textMuted)

                Spacer()

                // Points
                if item.category.points > 0 {
                    Text("+\(item.category.points)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(item.isCompleted ? LockInTheme.success : LockInTheme.textMuted)
                }

                // Timestamp
                if item.isCompleted, let ts = item.completedAt {
                    Text(timeString(ts))
                        .font(.system(size: 10))
                        .foregroundColor(LockInTheme.textMuted)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter(); f.timeStyle = .short
        return f.string(from: date)
    }
}
