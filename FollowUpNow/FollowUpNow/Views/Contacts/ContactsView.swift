import SwiftUI
import SwiftData

struct ContactsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Client.firstName) private var clients: [Client]
    @State private var searchText = ""
    @State private var showingAddClient = false
    @State private var selectedStage: PipelineStage?

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredClients) { client in
                    NavigationLink {
                        ClientDetailView(client: client)
                    } label: {
                        ClientRow(client: client)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search clients")
            .navigationTitle("People")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddClient = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddClient) {
                AddClientView()
            }
        }
    }

    private var filteredClients: [Client] {
        var result = clients

        if !searchText.isEmpty {
            result = result.filter {
                $0.displayName.localizedCaseInsensitiveContains(searchText) ||
                $0.company.localizedCaseInsensitiveContains(searchText) ||
                $0.email.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let stage = selectedStage {
            result = result.filter { $0.pipelineStage == stage }
        }

        return result
    }
}

struct ClientRow: View {
    let client: Client

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(colorForStage(client.pipelineStage))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(client.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if !client.company.isEmpty {
                    Text(client.company)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(client.pipelineStage.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(colorForStage(client.pipelineStage).opacity(0.15), in: Capsule())
                .foregroundStyle(colorForStage(client.pipelineStage))
        }
        .padding(.vertical, 4)
    }

    private func colorForStage(_ stage: PipelineStage) -> Color {
        switch stage {
        case .new: return .blue
        case .contacted: return .orange
        case .converted: return .green
        }
    }
}
