import SwiftUI
import SwiftData

struct AddFollowUpView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Client.firstName) private var clients: [Client]
    @Query(filter: #Predicate<FollowUpTemplate> { $0.isDefault }, sort: \FollowUpTemplate.name)
    private var defaultTemplates: [FollowUpTemplate]

    var preselectedClient: Client?

    @State private var selectedClientId: UUID?
    @State private var title = ""
    @State private var notes = ""
    @State private var dueDate = Date().addingTimeInterval(3600)
    @State private var channel: FollowUpChannel = .any
    @State private var reminderOffset: ReminderOffset = .fifteenMinutes
    @State private var selectedTemplateId: UUID?
    @State private var showingAIGeneration = false
    @State private var aiContent: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Client") {
                    if let preselected = preselectedClient {
                        HStack {
                            Text(preselected.displayName)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Picker("Client", selection: $selectedClientId) {
                            Text("Select client").tag(nil as UUID?)
                            ForEach(clients) { client in
                                Text(client.displayName).tag(client.id as UUID?)
                            }
                        }
                    }
                }

                Section("Follow-Up Details") {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)

                    DatePicker("Due Date", selection: $dueDate, in: Date()...)

                    Picker("Channel", selection: $channel) {
                        ForEach(FollowUpChannel.allCases, id: \.self) { ch in
                            Text(ch.rawValue).tag(ch)
                        }
                    }

                    Picker("Reminder", selection: $reminderOffset) {
                        ForEach(ReminderOffset.allCases, id: \.self) { offset in
                            Text(offset.displayName).tag(offset)
                        }
                    }
                }

                Section("Template") {
                    Picker("Use Template", selection: $selectedTemplateId) {
                        Text("None").tag(nil as UUID?)
                        ForEach(defaultTemplates) { template in
                            Text(template.name).tag(template.id as UUID?)
                        }
                    }
                    .onChange(of: selectedTemplateId) { _, newValue in
                        if let id = newValue,
                           let template = defaultTemplates.first(where: { $0.id == id }) {
                            title = template.name
                            notes = template.content
                            channel = template.channel
                        }
                    }
                }

                if PurchaseManager.shared.isProUnlocked {
                    Section("AI Assistant") {
                        Button {
                            generateAIContent()
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Generate Follow-Up Message")
                            }
                        }

                        if let content = aiContent {
                            Text(content)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(8)
                                .background(Color.purple.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
            .navigationTitle("New Follow-Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveFollowUp()
                    }
                    .disabled(title.isEmpty || (selectedClientId == nil && preselectedClient == nil))
                }
            }
            .onAppear {
                if let preselected = preselectedClient {
                    selectedClientId = preselected.id
                }
            }
        }
    }

    private func generateAIContent() {
        guard let clientId = selectedClientId ?? preselectedClient?.id,
              let client = clients.first(where: { $0.id == clientId }) else { return }

        Task {
            let service = AIFollowUpService()
            let lastInteraction = client.interactions.sorted { $0.date > $1.date }.first
            let template = selectedTemplateId.flatMap { id in defaultTemplates.first { $0.id == id } }

            do {
                let suggestion = try await service.generateFollowUp(
                    client: client,
                    lastInteraction: lastInteraction,
                    template: template
                )
                aiContent = suggestion.body
                if title.isEmpty {
                    title = suggestion.subject.isEmpty ? "Follow up with \(client.firstName)" : suggestion.subject
                }
                if notes.isEmpty {
                    notes = suggestion.body
                }
            } catch {
                aiContent = "Could not generate AI content. Please write manually."
            }
        }
    }

    private func saveFollowUp() {
        guard let clientId = selectedClientId ?? preselectedClient?.id,
              let client = clients.first(where: { $0.id == clientId }) else { return }

        let followUp = FollowUp(
            title: title,
            notes: notes,
            dueDate: dueDate,
            channel: channel,
            reminderOffset: reminderOffset
        )
        followUp.client = client
        followUp.aiGeneratedContent = aiContent
        client.followUps.append(followUp)
        modelContext.insert(followUp)

        Task {
            await NotificationManager.shared.scheduleFollowUpReminder(followUp, client: client)
        }

        dismiss()
    }
}
