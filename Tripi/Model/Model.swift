//
//  Model.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-03-05.
//

import SwiftUI
import Combine

// used to show and hide nav bar depending on whether or not view is full screen
class Model: ObservableObject {
    @Published var fullScreen: Bool = false
}
