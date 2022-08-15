//
//  TripManager.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-08-15.
//

import Foundation

class TripManager: NSObject, ObservableObject {
    @Published var trackingState = TrackingState.inactive
}
