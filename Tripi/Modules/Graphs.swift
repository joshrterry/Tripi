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
        Chart {
            ForEach(tripData) { speed in
                LineMark(
                    x: .value("Time", speed.timestamp),
                    y: .value("Speed", unitFormatter.formatSpeed(speed: speed.speed, selectedUnits: selectedUnits))
                )
                .lineStyle(StrokeStyle(lineWidth: 5))
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
        .chartYScale(domain: (unitFormatter.formatSpeed(speed: minSpeed, selectedUnits: selectedUnits)-20)...(unitFormatter.formatSpeed(speed: maxSpeed, selectedUnits: selectedUnits)+20))
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                if let value = value.as(Int.self) {
                    let valueLabel = "\(value) " + (selectedUnits == "metric" ? "kph" : "mph")
                    AxisValueLabel(valueLabel)
                }
            }
        }
        .chartXScale(range: .plotDimension(padding: 20))
        .chartXAxis {
            AxisMarks(values: .stride(by: .minute, count: Int((trip.secondsElapsed/60)/5) == 0 ? 1 : Int((trip.secondsElapsed/60)/5))) { timestamp in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .omitted)).minute(), horizontalSpacing: -20)
            }
        }
        
        .onAppear {
            for (index, _) in trip.graphedSpeedsX.enumerated() {
                tripData.append(Speed(speed: trip.graphedSpeedsY[index], timestamp: trip.graphedSpeedsX[index]))
            }
            minSpeed = trip.graphedSpeedsY.min() ?? 0
            maxSpeed = trip.graphedSpeedsY.max() ?? 100
        }
    }
}

//struct Graphs_Previews: PreviewProvider {
//    static var previews: some View {
//        Graphs()
//    }
//}
