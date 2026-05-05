import SwiftUI
import SwiftData

struct AddClientView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var company = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var notes = ""
    @State private var pipelineStage: PipelineStage = .new

    var body: some View {
        NavigationStack {
            Form {
                Section("Contact Info") {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Company", text: $company)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }

                Section("Pipeline Stage") {
                    Picker("Stage", selection: $pipelineStage) {
                        ForEach(PipelineStage.allCases, id: \.self) { stage in
                            Text(stage.rawValue).tag(stage)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }
            }
            .navigationTitle("New Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveClient()
                    }
                    .disabled(firstName.isEmpty)
                }
            }
        }
    }

    private func saveClient() {
        let client = Client(
            firstName: firstName,
            lastName: lastName,
            company: company,
            email: email,
            phone: phone,
            notes: notes
        )
        client.pipelineStage = pipelineStage
        modelContext.insert(client)
        dismiss()
    }
}
