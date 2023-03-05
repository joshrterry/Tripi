//
//  Graphs.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-02-09.
//

import SwiftUI
import Charts

struct Speed: Identifiable {
    var speed: Double
    var timestamp: Date
    var id = UUID()
}

struct Graphs: View {
    @State var tripData: [Speed] = []
    @State var trip: Trip
    @State var minSpeed = 0.0
    @State var maxSpeed = 0.0
    @AppStorage("selectedUnits") var selectedUnits = "metric"
    let unitFormatter = UnitFormatter()
    
    
    var body: some View {
        // graph of speed data
        Chart {
            ForEach(tripData) { speed in
                // lines connecting each point
                LineMark(
                    x: .value("Time", speed.timestamp),
                    y: .value("Speed", unitFormatter.formatSpeed(speed: speed.speed, selectedUnits: selectedUnits))
                )
                .lineStyle(StrokeStyle(lineWidth: 5))
                // points at each interval of data
                PointMark(
                    x: .value("Time", speed.timestamp),
                    y: .value("Speed", unitFormatter.formatSpeed(speed: speed.speed, selectedUnits: selectedUnits))
                ).symbolSize(120)
                    .symbol(symbol: {
                        Circle()
                            .strokeBorder(.blue, lineWidth: 4)
                            .background(Circle().fill(.white))
                            .frame(width: 12, height: 12)        
                    })
            }
        }
        // set y scale based on speed range
        .chartYScale(domain: (unitFormatter.formatSpeed(speed: minSpeed, selectedUnits: selectedUnits)-20)...(unitFormatter.formatSpeed(speed: maxSpeed, selectedUnits: selectedUnits)+20))
        .chartYAxis {
            // show grid line markings
            AxisMarks { value in
                AxisGridLine()
                if let value = value.as(Int.self) {
                    let valueLabel = "\(value) " + (selectedUnits == "metric" ? "kph" : "mph")
                    AxisValueLabel(valueLabel)
                }
            }
        }
        // set x scale based on date range
        .chartXScale(range: .plotDimension(padding: 20))
        .chartXAxis {
            // show grid line markings
            AxisMarks(values: .stride(by: .minute, count: Int((trip.secondsElapsed/60)/5) == 0 ? 1 : Int((trip.secondsElapsed/60)/5))) { timestamp in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .omitted)).minute(), horizontalSpacing: -20)
            }
        }
        
        .onAppear {
            // on appear, determine max and min speeds to use for y scale
            for (index, _) in trip.graphedSpeedsX.enumerated() {
                tripData.append(Speed(speed: trip.graphedSpeedsY[index], timestamp: trip.graphedSpeedsX[index]))
            }
            minSpeed = trip.graphedSpeedsY.min() ?? 0
            maxSpeed = trip.graphedSpeedsY.max() ?? 100
        }
    }
}
