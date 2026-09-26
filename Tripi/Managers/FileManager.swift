//
//  FileManager.swift
//  Tripi
//
//  Created by Joshua Terry on 2022-11-23.
//
//

import SwiftUI

// code adapted from: https://youtu.be/7luhStOgXjk

class FileManager {
    
    let unitFormatter = UnitFormatter()
    @AppStorage("selectedUnits") var selectedUnits = "metric"
    
    func generateCSV(trips: FetchedResults<Trip>, startDate: Date, endDate: Date, tags: [String], fields: [Field]) -> URL {
        // name of the file to be shared
        let fileName = "tripi_export.csv"
        
        // path to the iOS document directory
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
        let documentURL = URL(filePath: documentDirectoryPath).appendingPathComponent(fileName)
        let output = OutputStream.toMemory()
        
        // initialize CHCSVWriter
        let csvWriter = CHCSVWriter(outputStream: output, encoding: String.Encoding.utf8.rawValue, delimiter: ",".utf16.first!)
        
        // csv file header row
        for field in fields {
            csvWriter?.writeField(field.id.uppercased())
        }
        csvWriter?.finishLine()
        
        // two-dimensional array of trips data
        var tripsData = [[String]]()
        
        
        // for each trip, write its corresponding data to the tripsData array
        for trip in trips {
            let idToData = [
                "Start time": trip.startTimestamp?.formatted(date: .abbreviated, time: .shortened) ?? Date(),
                "End time": trip.endTimestamp?.formatted(date: .abbreviated, time: .shortened) ?? Date(),
                "Duration": trip.durationText,
                "Distance": String(unitFormatter.formatDistance(distance: trip.distance, selectedUnits: selectedUnits)) + (selectedUnits == "metric" ? " km" : " mi"),
                "Average Speed": String(unitFormatter.formatSpeed(speed: trip.averageSpeed, selectedUnits: selectedUnits)) + (selectedUnits == "metric" ? " kph" : " mph"),
                "Amount Reimbursable": unitFormatter.formatReimbursableLong(amount: trip.amountReimbursable),
                "Notes": trip.notes ?? ""
            ] as [String : Any]
            
            // convert all metrics to strings
            let stringIdtoData = idToData.compactMapValues { "\($0)" }
            
            // find trips in selected date range
            if trip.startTimestamp ?? Date() >= Calendar.current.startOfDay(for: startDate) && trip.endTimestamp ?? Date() <= Calendar.current.startOfDay(for: endDate + 86400) {
                // if no tags selected, append all data to the array
                if tags.isEmpty {
                    var dataArray: [String] = []

                    // write each field to dataArray
                    for field in fields {
                        dataArray.append(stringIdtoData[field.id] ?? "")
                    }
                    tripsData.append(dataArray)
                } else {
                    // if tag filter applied, only allow accepted tags
                    var tagNames: [String] = []
                    for tag in trip.tagsArray {
                        if let name = tag.name { tagNames.append(name) }
                    }
                    for tagName in tagNames {
                        if tags.contains(tagName) {
                            var dataArray: [String] = []

                            // write each field to dataArray
                            for field in fields {
                                dataArray.append(stringIdtoData[field.id] ?? "")
                            }
                            tripsData.append(dataArray)
                            break
                        }
                    }
                }

            }
        }
        
        // write data from array to the csvWriter
        for row in tripsData {
            for column in row {
                csvWriter?.writeField(column)
            }
            csvWriter?.finishLine()
        }
        
        // close output stream
        csvWriter?.closeStream()
        
        // data written to memory is accessed and stored as Data to the buffer variable
        let buffer = (output.property(forKey: .dataWrittenToMemoryStreamKey) as? Data)!
        
        // do catch statement to handle errors when writing to CSV file (documentURL)
        do {
            try buffer.write(to: documentURL)
        }
        catch {
            print("Error writing to CSV")
        }
        
        // return the document URL
        return documentURL
    }
    
}

