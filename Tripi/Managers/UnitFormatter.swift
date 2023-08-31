//
//  UnitFormatters.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-02-04.
//

import SwiftUI

struct UnitFormatter {
    private let numberFormatter: NumberFormatter

    init() {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 4
    }

    // format distances as a double to one decimal place
    func formatDistance(distance: Double, selectedUnits: String) -> Double {
        var formattedDistance = 0.0
        
        if selectedUnits == "metric" {
            formattedDistance = round(distance * 10) / 10.0
        }
        // convert to imperial units if selected
        else if selectedUnits == "imperial" {
            formattedDistance = round((distance * 0.62137119223733) * 10) / 10.0
        }
        return formattedDistance
    }

    // format speeds as a double rounded to a whole number
    func formatSpeed(speed: Double, selectedUnits: String) -> Double {
        var formattedSpeed = 0.0
        
        if selectedUnits == "metric" {
            formattedSpeed = round(speed)
        }
        // convert to imperial units if selected
        else if selectedUnits == "imperial" {
            formattedSpeed = round(speed * 0.62137119223733)
        }
        return formattedSpeed
    }
    
    // format dollar values to a string with a $ and two decimal places
    func formatReimbursable(amount: Double) -> String {
        var formattedReimbursable = ""
        
        formattedReimbursable = "$"+String(format: "%.2f", amount)
        
        return formattedReimbursable
    }
    
    // format dollar values to a string with a $ and two decimal places
    func formatReimbursableLong(amount: Double) -> String {
        var formattedReimbursable = ""
        
        formattedReimbursable = numberFormatter.string(from: amount as NSNumber)!
        
        return formattedReimbursable
    }
    
}
