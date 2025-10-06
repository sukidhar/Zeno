//
//  ContentView.swift
//  Zeno
//
//  Created by Sukidhar Darisi on 05/10/25.
//

import SwiftUI
import UserNotifications
import Combine

struct ContentView: View {
    @State private var startTime: Date? = nil
    @State private var elapsed: TimeInterval = 0
    @State private var startTimer: Bool = false
    @State private var paused: Bool = false
    private let duration: TimeInterval = 10
    
    private var formattedElapsed: String {
        let total = Int(elapsed)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack{
            HStack{
                Image(.zeno)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .offset(y: -5)
                Text("Zeno")
                    .font(.custom("Cookie-Regular", size: 28))
                    .foregroundStyle(Color.init(red: 0.8, green: 0.35, blue: 0.4))
            }
            .padding(10)
            VStack{
                Text("Time elapsed")
                    .font(Font.custom("QuickSand-SemiBold", size: 14))
                    .foregroundStyle(Color.init(red: 0.8, green: 0.4, blue: 0.35))
                Text(formattedElapsed)
                    .font(.custom("QuickSand-SemiBold", size: 20))
                    .foregroundStyle(Color.init(red: 0.8, green: 0.35, blue: 0.4))
            }.padding(.bottom, 20)
            HStack(spacing: 12) {
                // Start / Reset
                Button(action: {
                    handleStartReset()
                }) {
                    Text(startTimer ? "Reset" : "Start")
                        .font(.custom("QuickSand-SemiBold", size: 16))
                        .padding(5)
                        .foregroundStyle(Color.init(red: 0.8, green: 0.35, blue: 0.4))
                }
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.init(red: 0.8, green: 0.35, blue: 0.4), lineWidth: 1.5))

                // Pause / Resume
                Button(action: {
                    handlePauseResume()
                }) {
                    Text(paused ? "Resume" : "Pause")
                        .font(.custom("QuickSand-SemiBold", size: 16))
                        .padding(5)
                        .foregroundStyle(Color.init(red: 0.8, green: 0.35, blue: 0.4))
                }
                .disabled(!startTimer)
                .opacity(startTimer ? 1.0 : 0.5)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.init(red: 0.8, green: 0.35, blue: 0.4), lineWidth: 1.5))
            }
        }
        .padding(.bottom, 20)
        .frame(width: 300)
        .background(Color.init(red: 1, green: 0.97, blue: 0.95))
        .onAppear(perform: requestNotificationPermission)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            tick()
        }
    }
    
    // MARK: - Timer Logic
    private func handleStartReset() {
        if !startTimer {
            startTimer = true
            paused = false
            startTime = Date()
            elapsed = 0
        } else {
            resetTimer()
        }
    }
    
    private func handlePauseResume() {
        guard startTimer else { return }
        if paused {
            paused = false
            startTime = Date().addingTimeInterval(-elapsed)
        } else {
            paused = true
        }
    }
    
    private func tick() {
        guard startTimer, !paused, let start = startTime else { return }
        let elapsedNow = Date().timeIntervalSince(start)
        elapsed = min(elapsedNow, duration)
        if elapsed >= duration {
            startTimer = false
            paused = false
            sendTimeUpNotification()
        }
    }
    
    private func resetTimer() {
        startTimer = false
        paused = false
        startTime = nil
        elapsed = 0
    }
    
    private func sendTimeUpNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time's up!"
        content.body = "Your 20-minute session has finished."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "timer.timeUp",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { granted, error in
            print("Permission granted: \(granted)")
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
