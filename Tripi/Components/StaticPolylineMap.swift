//
//  StaticPolylineMap.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-08-19.
//

import SwiftUI
import MapKit

struct StaticPolylineMap: View {
    @Binding var region: MKCoordinateRegion
    @Binding var routeCoordinates: [CLLocationCoordinate2D]
    @State private var snapshotImage: UIImage? = nil
    @State private var snapshotImageData: Data? = nil
    @State var trip: Trip

        
    func drawLineOnImage(snapshot: MKMapSnapshotter.Snapshot) -> UIImage {
        let image = snapshot.image
        
        // for Retina screen
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0)
        
        // draw original image into the context
        image.draw(at: CGPoint.zero)
        
        // get the context for CoreGraphics
        let context = UIGraphicsGetCurrentContext()
        
        // set stroking width and color of the context
        context!.setLineWidth(7.0)
        context!.setLineCap(.round)
        context!.setStrokeColor(UIColor.systemBlue.cgColor)
        
        // Here is the trick :
        // We use addLine() and move() to draw the line, this should be easy to understand.
        // The diificult part is that they both take CGPoint as parameters, and it would be way too complex for us to calculate by ourselves
        // Thus we use snapshot.point() to save the pain.
        if !routeCoordinates.isEmpty {
            context!.move(to: snapshot.point(for: routeCoordinates[0]))
            for i in 0...routeCoordinates.count-1 {
                context!.addLine(to: snapshot.point(for: routeCoordinates[i]))
                context!.move(to: snapshot.point(for: routeCoordinates[i]))
            }
        }

        
        // apply the stroke to the context
        context!.strokePath()
        
        // get the image from the graphics context
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end the graphics context
        UIGraphicsEndImageContext()
        
        return resultImage!
    }
    
    func generateSnapshot(width: CGFloat, height: CGFloat) {
        if trip.routeImage == nil {
            // Map options
            let mapOptions = MKMapSnapshotter.Options()
            mapOptions.region.center = self.region.center
            mapOptions.region.span.longitudeDelta = self.region.span.longitudeDelta // *2
            mapOptions.region.span.latitudeDelta = self.region.span.latitudeDelta // *2
            mapOptions.size = CGSize(width: width, height: height)
            mapOptions.showsBuildings = true
            mapOptions.pointOfInterestFilter = .excludingAll
            mapOptions.mapType = .standard
            
            // Create the snapshotter and run it
            let snapshotter = MKMapSnapshotter(options: mapOptions)
            snapshotter.start(with: .global()) { (snapshotOrNil, errorOrNil) in
                if let error = errorOrNil {
                    print(error)
                    return
                }
                if let snapshot = snapshotOrNil {
                    self.snapshotImage = self.drawLineOnImage(snapshot: snapshot)
                    self.snapshotImageData = self.snapshotImage?.jpegData(compressionQuality: 1.0)
    //                trip.routeImage = snapshotImageData
                    if let data = self.snapshotImageData {
                        DispatchQueue.main.async {
                            PersistenceController.shared.addImageToTrip(trip: trip, image: data)

                        }

                    }
                }
            }
        } else {
            self.snapshotImage = UIImage(data: trip.routeImage!, scale: 3)
        }

    }
    
    var body: some View {
        Group {
            if let image = snapshotImage {
                Image(uiImage: image)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                //          .background(Color(UIColor.secondarySystemBackground))
            }
        }
        .onAppear {
            generateSnapshot(width: 150, height: 220)
        }
    }
}

//struct StaticPolylineMap_Previews: PreviewProvider {
//    static var previews: some View {
//        StaticPolylineMap(region: MKCoordinateRegion())
//    }
//}
