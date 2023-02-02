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
    
    func generateCSV(trips: FetchedResults<Trip>, startDate: Date, endDate: Date) -> URL {
        // name of the file to be shared
        let fileName = "tripi_export.csv"
        
        // path to the iOS document directory
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
        let documentURL = URL(filePath: documentDirectoryPath).appendingPathComponent(fileName)
        let output = OutputStream.toMemory()
        
        // initialize CHCSVWriter
        let csvWriter = CHCSVWriter(outputStream: output, encoding: String.Encoding.utf8.rawValue, delimiter: ",".utf16.first!)
        
        // csv file header row
        csvWriter?.writeField("TRIP_START_TIME")
        csvWriter?.writeField("TRIP_END_TIME")
        csvWriter?.writeField("TRIP_DISTANCE")
        csvWriter?.finishLine()
        
        // two-dimensional array of trips data
        var tripsData = [[String]]()
        
        // for each trip, write its corresponding data to the tripsData array
        for trip in trips {
            if trip.startTimestamp ?? Date() >= Calendar.current.startOfDay(for: startDate) && trip.endTimestamp ?? Date() <= Calendar.current.startOfDay(for: endDate + 86400) {
                tripsData.append(["\(trip.startTimestamp ?? Date())", "\(trip.endTimestamp ?? Date())", "\(trip.distance)"])
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

