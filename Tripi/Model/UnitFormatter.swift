//
//  UnitFormatters.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-02-04.
//

import SwiftUI

struct UnitFormatter {
//    @AppStorage("selectedUnits") var selectedUnits = "metric"

    func formatDistance(distance: Double, selectedUnits: String) -> Double {
        var formattedDistance = 0.0
        
        if selectedUnits == "metric" {
            formattedDistance = round(distance * 10) / 10.0
        }
        else if selectedUnits == "imperial" {
            formattedDistance = round((distance * 0.62137119223733) * 10) / 10.0
        }
        return formattedDistance
    }

    func formatSpeed(speed: Double, selectedUnits: String) -> Double {
        var formattedSpeed = 0.0
        
        if selectedUnits == "metric" {
            formattedSpeed = round(speed)
        }
        else if selectedUnits == "imperial" {
            formattedSpeed = round(speed * 0.62137119223733)
        }
        return formattedSpeed
    }
    
    func formatReimbursable(amount: Double) -> String {
        var formattedReimbursable = ""
        
        formattedReimbursable = "$"+String(format: "%.2f", amount)
        
        return formattedReimbursable
    }
    
}
