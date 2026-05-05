import SwiftUI
import SwiftData

struct ClientDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var client: Client
    @State private var showingAddFollowUp = false
    @State private var showingAddInteraction = false
    @State private var newInteractionType: FollowUpChannel = .phone
    @State private var newInteractionSummary = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                clientHeader
                quickActions
                upcomingFollowUps
                interactionHistory
                notesSection
            }
            .padding()
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(client.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddFollowUp) {
            AddFollowUpView(preselectedClient: client)
        }
    }

    private var clientHeader: some View {
        VStack(spacing: 8) {
            Text(client.displayName)
                .font(.title2)
                .fontWeight(.bold)

            if !client.company.isEmpty {
                Label(client.company, systemImage: "building.2.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Picker("Stage", selection: $client.pipelineStage) {
                ForEach(PipelineStage.allCases, id: \.self) { stage in
                    Text(stage.rawValue).tag(stage)
                }
            }
            .pickerStyle(.segmented)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var quickActions: some View {
        HStack(spacing: 16) {
            if !client.phone.isEmpty {
                QuickActionButton(icon: "phone.fill", title: "Call", color: .green) {
                    if let url = URL(string: "tel://\(client.phone)") {
                        UIApplication.shared.open(url)
                    }
                }
            }
            if !client.phone.isEmpty {
                QuickActionButton(icon: "message.fill", title: "Text", color: .blue) {
                    if let url = URL(string: "sms://\(client.phone)") {
                        UIApplication.shared.open(url)
                    }
                }
            }
            if !client.email.isEmpty {
                QuickActionButton(icon: "envelope.fill", title: "Email", color: .orange) {
                    if let url = URL(string: "mailto:\(client.email)") {
                        UIApplication.shared.open(url)
                    }
                }
            }
            QuickActionButton(icon: "plus.circle.fill", title: "Follow Up", color: .purple) {
                showingAddFollowUp = true
            }
        }
    }

    private var upcomingFollowUps: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Upcoming Follow-Ups")
                    .font(.headline)
                Spacer()
                Button("Add") {
                    showingAddFollowUp = true
                }
                .font(.subheadline)
            }

            let upcoming = client.followUps.filter { !$0.isCompleted }.sorted { $0.dueDate < $1.dueDate }

            if upcoming.isEmpty {
                Text("No upcoming follow-ups")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(upcoming) { followUp in
                    HStack {
                        Image(systemName: followUp.channel.systemImage)
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading) {
                            Text(followUp.title)
                                .font(.subheadline)
                            Text(followUp.dueDate, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button {
                            followUp.isCompleted = true
                            followUp.completedAt = Date()
                            NotificationManager.shared.cancelReminder(for: followUp.id)
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
    }

    private var interactionHistory: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Interaction History")
                    .font(.headline)
                Spacer()
                Button("Log") {
                    showingAddInteraction = true
                }
                .font(.subheadline)
            }

            let sorted = client.interactions.sorted { $0.date > $1.date }

            if sorted.isEmpty {
                Text("No interactions recorded")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(sorted) { interaction in
                    HStack {
                        Image(systemName: interaction.type.systemImage)
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading) {
                            Text(interaction.summary)
                                .font(.subheadline)
                            Text(interaction.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .alert("Log Interaction", isPresented: $showingAddInteraction) {
            TextField("Summary", text: $newInteractionSummary)
            Button("Save") {
                let interaction = Interaction(type: newInteractionType, summary: newInteractionSummary)
                interaction.client = client
                client.interactions.append(interaction)
                modelContext.insert(interaction)
                newInteractionSummary = ""
            }
            Button("Cancel", role: .cancel) {
                newInteractionSummary = ""
            }
        } message: {
            Picker("Type", selection: $newInteractionType) {
                ForEach(FollowUpChannel.allCases.filter { $0 != .any }, id: \.self) { channel in
                    Text(channel.rawValue).tag(channel)
                }
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
            TextEditor(text: $client.notes)
                .font(.subheadline)
                .frame(minHeight: 80)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        }
    }
}
