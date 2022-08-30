////
////  StopwatchManager.swift
////  Tripi
////
////  Created by Joshua Terry on 2022-08-28.
////
//
//import Foundation
//
//class StopwatchManager: RouteManager {
//    
//    @Published var timeElapsed = 0.0
//    @Published var formattedTime = "0"
//    
//    var startTime: Date = Date()
//    
//    var timer = Timer()
//    
//    func startTimer() {
//        startTime = Date()
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
//            let current = Date()
//            let diffComponents = Calendar.current.dateComponents([.second, .nanosecond], from: self.startTime, to: current)
//            let seconds = Double(diffComponents.second ?? 0) + Double(diffComponents.nanosecond ?? 0) / 1000000000
//            self.timeElapsed += seconds
//            secondstoMinutesSeconds(seconds: timeElapsed.self)
//            self.startTime = current
//        }
//    }
//    
//    func pauseTimer() {
//        timer.invalidate()
//    }
//    
//    func secondstoMinutesSeconds(seconds: Double) {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.minute, .second]
//        formatter.unitsStyle = .positional
//        formatter.zeroFormattingBehavior  = .pad
//        
//        self.formattedTime = formatter.string(from: TimeInterval(seconds))!
//    }
//    
//    func minutesSecondstoHoursMinutes() {
//        
//    }
//}
