import UserNotifications
import SwiftData
import Foundation

@MainActor
final class NotificationManager: NSObject, @unchecked Sendable {
    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func scheduleFollowUpReminder(_ followUp: FollowUp, client: Client) async {
        let content = UNMutableNotificationContent()
        content.title = "Follow Up: \(client.displayName)"
        content.body = followUp.title
        content.sound = .default
        content.userInfo = [
            "followUpId": followUp.id.uuidString,
            "clientId": client.id.uuidString,
            "channel": followUp.channel.rawValue
        ]
        content.categoryIdentifier = "FOLLOW_UP_CATEGORY"

        let triggerDate = followUp.dueDate.addingTimeInterval(
            -TimeInterval(followUp.reminderOffset.rawValue * 60)
        )

        guard triggerDate > Date() else { return }

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: followUp.id.uuidString,
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
        await updateBadge()
    }

    func cancelReminder(for followUpId: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [followUpId.uuidString]
            )
    }

    func setupNotificationCategories() {
        let callAction = UNNotificationAction(
            identifier: "CALL_ACTION",
            title: "Call Now",
            options: [.foreground]
        )
        let textAction = UNNotificationAction(
            identifier: "TEXT_ACTION",
            title: "Send Text",
            options: [.foreground]
        )
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze 1 Hour",
            options: []
        )
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_ACTION",
            title: "Mark Done",
            options: []
        )

        let category = UNNotificationCategory(
            identifier: "FOLLOW_UP_CATEGORY",
            actions: [callAction, textAction, snoozeAction, completeAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        UNUserNotificationCenter.current()
            .setNotificationCategories([category])
    }

    func updateBadge() async {
        let requests = await UNUserNotificationCenter.current()
            .pendingNotificationRequests()
        let count = requests.filter { $0.content.categoryIdentifier == "FOLLOW_UP_CATEGORY" }.count
        try? await UNUserNotificationCenter.current().setBadgeCount(count)
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        switch response.actionIdentifier {
        case "CALL_ACTION":
            handleCallAction(userInfo: userInfo)
        case "TEXT_ACTION":
            handleTextAction(userInfo: userInfo)
        case "SNOOZE_ACTION":
            handleSnoozeAction(userInfo: userInfo)
        case "COMPLETE_ACTION":
            handleCompleteAction(userInfo: userInfo)
        default:
            break
        }

        completionHandler()
    }

    private func handleCallAction(userInfo: [AnyHashable: Any]) {
        guard let clientId = userInfo["clientId"] as? String,
              let uuid = UUID(uuidString: clientId) else { return }
        NotificationCenter.default.post(
            name: .init("InitiateCall"),
            object: nil,
            userInfo: ["clientId": uuid]
        )
    }

    private func handleTextAction(userInfo: [AnyHashable: Any]) {
        guard let clientId = userInfo["clientId"] as? String,
              let uuid = UUID(uuidString: clientId) else { return }
        NotificationCenter.default.post(
            name: .init("InitiateText"),
            object: nil,
            userInfo: ["clientId": uuid]
        )
    }

    private func handleSnoozeAction(userInfo: [AnyHashable: Any]) {
        guard let followUpId = userInfo["followUpId"] as? String,
              let uuid = UUID(uuidString: followUpId) else { return }
        NotificationCenter.default.post(
            name: .init("SnoozeFollowUp"),
            object: nil,
            userInfo: ["followUpId": uuid, "snoozeMinutes": 60]
        )
    }

    private func handleCompleteAction(userInfo: [AnyHashable: Any]) {
        guard let followUpId = userInfo["followUpId"] as? String,
              let uuid = UUID(uuidString: followUpId) else { return }
        NotificationCenter.default.post(
            name: .init("CompleteFollowUp"),
            object: nil,
            userInfo: ["followUpId": uuid]
        )
    }
}
