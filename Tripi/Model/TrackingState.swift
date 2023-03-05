//
//  TrackingState.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-08-15.
//

import Foundation

// defines current trip tracking state
enum TrackingState {
    case inactive // trip is not in progress
    case paused // trip is in progress, but not currently gathering data (paused)
    case active // trip is currently in progress and data is being published
}
