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
    @State var tripData = [Speed(speed: 0, timestamp: Date())]
    @State var trip: Trip
    @State var minSpeed = 0.0
    @State var maxSpeed = 0.0
    
    var body: some View {
        Chart {
            ForEach(tripData) { speed in
                LineMark(
                    x: .value("Time", speed.timestamp),
                    y: .value("Speed", speed.speed)
                )
                    .lineStyle(StrokeStyle(lineWidth: 5))
                PointMark(
                    x: .value("Time", speed.timestamp),
                    y: .value("Speed", speed.speed)
                ).symbolSize(120)
                    .symbol(symbol: {
                        Circle()
                            .strokeBorder(.blue, lineWidth: 4)
                            .background(Circle().fill(.white))
                            .frame(width: 12, height: 12)
                            
                    })
            }
        }
            .chartYScale(domain: (minSpeed-20)...(maxSpeed+20))
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    if let value = value.as(Int.self) {
                        let valueLabel = "\(value) kph"
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
            print(Int(trip.secondsElapsed/60)/5)
            tripData = []
            minSpeed = 99999.0
            maxSpeed = 0.0
            for waypoint in trip.locationsArray[2...].enumerated().compactMap({ tuple in tuple.offset.isMultiple(of: Int(trip.locationsArray.count / 15)) ? tuple.element : nil }) {
                tripData.append(Speed(speed: waypoint.speed, timestamp: waypoint.timestamp ?? Date()))
                if waypoint.speed < minSpeed {
                    minSpeed = waypoint.speed
                }
                if waypoint.speed > maxSpeed {
                    maxSpeed = waypoint.speed
                }
            }
        }
    }
}

//struct Graphs_Previews: PreviewProvider {
//    static var previews: some View {
//        Graphs()
//    }
//}
