//
//  NotificationManager.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/02/22.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("通知の許可エラー: \(error.localizedDescription)")
            }
            if granted {
                print("✅ 通知が許可されました")
                self.scheduleDailyNotification()
            } else {
                print("❌ 通知が拒否されました")
            }
        }
    }
    func scheduleDailyNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        var dateComponents = DateComponents()
        dateComponents.hour = 12
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "📸 今日の1枚を撮ろう！"
        content.body = "metpicで今日の写真を撮って、思い出を残そう！"
        content.sound = .default

        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("通知のスケジュールエラー: \(error.localizedDescription)")
            } else {
                print("✅ 通知がスケジュールされました (毎日12:00)")
            }
        }
    }
}
