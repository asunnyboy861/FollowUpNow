import SwiftUI
import SwiftData

struct TemplatesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FollowUpTemplate.name) private var templates: [FollowUpTemplate]
    @State private var showingAddTemplate = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(templates) { template in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(template.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: template.channel.systemImage)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if template.isDefault {
                                Text("Default")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1), in: Capsule())
                                    .foregroundStyle(.blue)
                            }
                        }
                        Text(template.content)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        Text("After \(template.daysAfterLastContact) day(s)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteTemplates)
            }
            .navigationTitle("Templates")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTemplate = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddTemplate) {
                AddTemplateView()
            }
            .onAppear {
                let service = TemplateService(modelContext: modelContext)
                service.createDefaultTemplates()
            }
        }
    }

    private func deleteTemplates(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(templates[index])
        }
    }
}

struct AddTemplateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var content = ""
    @State private var channel: FollowUpChannel = .email
    @State private var daysAfterLastContact = 3

    var body: some View {
        NavigationStack {
            Form {
                Section("Template Info") {
                    TextField("Name", text: $name)
                    TextField("Content", text: $content, axis: .vertical)
                        .lineLimit(3...8)
                    Picker("Channel", selection: $channel) {
                        ForEach(FollowUpChannel.allCases, id: \.self) { ch in
                            Text(ch.rawValue).tag(ch)
                        }
                    }
                    Stepper("After \(daysAfterLastContact) day(s)", value: $daysAfterLastContact, in: 1...90)
                }
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let service = TemplateService(modelContext: modelContext)
                        _ = service.createTemplate(
                            name: name,
                            content: content,
                            channel: channel,
                            daysAfterLastContact: daysAfterLastContact
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty || content.isEmpty)
                }
            }
        }
    }
}
