import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<FollowUp> { !$0.isCompleted }, sort: \FollowUp.dueDate)
    private var pendingFollowUps: [FollowUp]

    @Query private var clients: [Client]

    @State private var selectedFilter: DateFilter = .today
    @State private var showingAddFollowUp = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    statsSection
                    filterPicker
                    followUpList
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("FollowUpNow")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddFollowUp = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddFollowUp) {
                AddFollowUpView()
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(title: "Due Today", value: todayCount, color: .blue)
            StatCard(title: "Overdue", value: overdueCount, color: .red)
            StatCard(title: "This Week", value: weekCount, color: .orange)
            StatCard(title: "Clients", value: clients.count, color: .green)
        }
    }

    private var filterPicker: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(DateFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
    }

    private var followUpList: some View {
        LazyVStack(spacing: 10) {
            if filteredFollowUps.isEmpty {
                ContentUnavailableView(
                    "All Caught Up!",
                    systemImage: "checkmark.circle.fill",
                    description: Text("No follow-ups pending. Great job!")
                )
            } else {
                ForEach(filteredFollowUps) { followUp in
                    FollowUpRow(followUp: followUp)
                        .swipeActions(edge: .leading) {
                            Button {
                                completeFollowUp(followUp)
                            } label: {
                                Label("Done", systemImage: "checkmark.circle.fill")
                            }
                            .tint(.green)
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                snoozeFollowUp(followUp)
                            } label: {
                                Label("Snooze", systemImage: "clock.arrow.circlepath")
                            }
                            .tint(.orange)

                            Button(role: .destructive) {
                                deleteFollowUp(followUp)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }

    private var filteredFollowUps: [FollowUp] {
        let now = Date()
        let calendar = Calendar.current

        return pendingFollowUps.filter { followUp in
            switch selectedFilter {
            case .today:
                return calendar.isDateInToday(followUp.dueDate)
            case .overdue:
                return followUp.dueDate < now
            case .thisWeek:
                return followUp.dueDate >= now && followUp.dueDate <= calendar.date(byAdding: .day, value: 7, to: now)!
            case .all:
                return true
            }
        }
    }

    private var todayCount: Int {
        pendingFollowUps.filter { Calendar.current.isDateInToday($0.dueDate) }.count
    }

    private var overdueCount: Int {
        pendingFollowUps.filter { $0.dueDate < Date() }.count
    }

    private var weekCount: Int {
        let now = Date()
        let weekLater = Calendar.current.date(byAdding: .day, value: 7, to: now)!
        return pendingFollowUps.filter { $0.dueDate >= now && $0.dueDate <= weekLater }.count
    }

    private func completeFollowUp(_ followUp: FollowUp) {
        followUp.isCompleted = true
        followUp.completedAt = Date()
        NotificationManager.shared.cancelReminder(for: followUp.id)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func snoozeFollowUp(_ followUp: FollowUp) {
        followUp.dueDate = Calendar.current.date(byAdding: .hour, value: 1, to: followUp.dueDate)!
        Task {
            if let client = followUp.client {
                await NotificationManager.shared.scheduleFollowUpReminder(followUp, client: client)
            }
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func deleteFollowUp(_ followUp: FollowUp) {
        NotificationManager.shared.cancelReminder(for: followUp.id)
        modelContext.delete(followUp)
    }
}
