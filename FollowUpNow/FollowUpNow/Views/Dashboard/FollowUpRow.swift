import SwiftUI

struct FollowUpRow: View {
    let followUp: FollowUp

    private var isOverdue: Bool {
        followUp.dueDate < Date() && !followUp.isCompleted
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(followUp.dueDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(isOverdue ? Color.red : (isToday ? Color.orange : Color.blue))
                    .frame(width: 8, height: 8)

                if let client = followUp.client {
                    Text(client.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    if !client.company.isEmpty {
                        Text("- \(client.company)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: followUp.channel.systemImage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(followUp.title)
                .font(.subheadline)
                .foregroundStyle(.primary)

            HStack {
                Text(followUp.dueDate, style: .relative)
                    .font(.caption)
                    .foregroundStyle(isOverdue ? .red : .secondary)

                if isOverdue {
                    Text("Overdue")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red, in: Capsule())
                }

                Spacer()

                if followUp.aiGeneratedContent != nil {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                        .foregroundStyle(.purple)
                }
            }
        }
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isOverdue ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}
