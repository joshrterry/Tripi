//
//  Stopwatch.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-08-28.
//

import Foundation

//class Stopwatch: ObservableObject {
//    private var startTime: Date?
//    private var accumulatedTime:TimeInterval = 0
//  
//    @Published private(set) var isRunning = false
//    @Published private(set) var elapsedTime: TimeInterval = 0
//    func start() -> Void {
//        self.startTime = Date()
//        self.isRunning = true
//    }
//    func stop() -> Void {
//        self.accumulatedTime = self.elapsedTime()
//        self.startTime = nil
//        self.isRunning = false
//    }
//    func reset() -> Void {
//        self.accumulatedTime = 0
//        self.elapsedTime = 0
//        self.startTime = nil
//        self.isRunning = false
//    }
//    private func getElapsedTime() -> TimeInterval {
//       return -(self.startTime?.timeIntervalSinceNow ?? 0)+self.accumulatedTime
//    }
//}
