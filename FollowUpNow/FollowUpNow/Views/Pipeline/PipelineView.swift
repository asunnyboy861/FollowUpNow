import SwiftUI
import SwiftData

struct PipelineView: View {
    @Query private var clients: [Client]

    var body: some View {
        NavigationStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    pipelineColumn(title: "New", stage: .new, color: .blue)
                    pipelineColumn(title: "Contacted", stage: .contacted, color: .orange)
                    pipelineColumn(title: "Converted", stage: .converted, color: .green)
                }
                .padding()
            }
            .navigationTitle("Pipeline")
        }
    }

    private func pipelineColumn(title: String, stage: PipelineStage, color: Color) -> some View {
        let stageClients = clients.filter { $0.pipelineStage == stage }

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                Text(title)
                    .font(.headline)
                Text("\(stageClients.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.15), in: Capsule())
            }

            LazyVStack(spacing: 8) {
                ForEach(stageClients) { client in
                    NavigationLink {
                        ClientDetailView(client: client)
                    } label: {
                        PipelineClientCard(client: client, color: color)
                    }
                }

                if stageClients.isEmpty {
                    Text("No clients")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                }
            }
        }
        .frame(width: 260)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct PipelineClientCard: View {
    let client: Client
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(client.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)

            if !client.company.isEmpty {
                Text(client.company)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            let pendingCount = client.followUps.filter { !$0.isCompleted }.count
            if pendingCount > 0 {
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                    Text("\(pendingCount) pending")
                        .font(.caption2)
                }
                .foregroundStyle(color)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 10))
    }
}
