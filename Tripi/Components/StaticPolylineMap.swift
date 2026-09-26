//
//  StaticPolylineMap.swift
//  Tripi
//
//  Created by Joshua Terry on 2023-08-19.
//

import SwiftUI
import MapKit


struct StaticPolylineMap: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var region: MKCoordinateRegion
    @Binding var routeCoordinates: [CLLocationCoordinate2D]
    @State private var snapshotImage: UIImage? = nil
    @State private var snapshotImageData: Data? = nil
    @State private var snapshotImageL: UIImage? = nil
    @State private var snapshotImageDataL: Data? = nil
    @State private var snapshotImageD: UIImage? = nil
    @State private var snapshotImageDataD: Data? = nil
    @State var trip: Trip
    @AppStorage("hasHomeButton") var hasHomeButton = false
    
    func drawLineOnImage(snapshot: MKMapSnapshotter.Snapshot) -> UIImage {
        let image = snapshot.image
        
        // for Retina screen
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0)
        
        // draw original image into the context
        image.draw(at: CGPoint.zero)
        
        // get the context for CoreGraphics
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return image
        }
        
        // set stroking width and color of the context
        context.setLineWidth(7.0)
        context.setLineCap(.round)
        context.setStrokeColor(UIColor.systemBlue.cgColor)
        
        // Here is the trick :
        // We use addLine() and move() to draw the line, this should be easy to understand.
        // The diificult part is that they both take CGPoint as parameters, and it would be way too complex for us to calculate by ourselves
        // Thus we use snapshot.point() to save the pain.
        if !routeCoordinates.isEmpty {
            context.move(to: snapshot.point(for: routeCoordinates[0]))
            for i in 0...routeCoordinates.count-1 {
                context.addLine(to: snapshot.point(for: routeCoordinates[i]))
                context.move(to: snapshot.point(for: routeCoordinates[i]))
            }
        }
        
        
        // apply the stroke to the context
        context.strokePath()
        
        // get the image from the graphics context
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end the graphics context
        UIGraphicsEndImageContext()
        
        return resultImage ?? image
    }
    
    func generateSnapshot(width: CGFloat, height: CGFloat, condition: ColorScheme) {
        if trip.lightImage == nil || trip.darkImage == nil {
            
            // Map options
            let mapOptions = MKMapSnapshotter.Options()
            mapOptions.region.center = self.region.center
            mapOptions.region.span.longitudeDelta = self.region.span.longitudeDelta // *2
            mapOptions.region.span.latitudeDelta = self.region.span.latitudeDelta // *2
            mapOptions.size = CGSize(width: width, height: height)
            mapOptions.showsBuildings = true
            mapOptions.pointOfInterestFilter = .excludingAll
            mapOptions.mapType = .standard
            
            mapOptions.traitCollection = UITraitCollection(userInterfaceStyle: .light)
            // Create the snapshotter and run it
            let snapshotterLight = MKMapSnapshotter(options: mapOptions)
            snapshotterLight.start(with: .global()) { (snapshotOrNil, errorOrNil) in
                if let error = errorOrNil {
                    print(error)
                    return
                }
                if let lightSnapshot = snapshotOrNil {
                    self.snapshotImageL = self.drawLineOnImage(snapshot: lightSnapshot)
                    if colorScheme == .light {
                        self.snapshotImage = self.snapshotImageL
                    }
                    self.snapshotImageDataL = self.snapshotImageL?.jpegData(compressionQuality: 1.0)
                    if let lightData = self.snapshotImageDataL {
                        DispatchQueue.main.async {
                            trip.lightImage = lightData
                            PersistenceController.shared.save()
                        }
                        
                    }
                }
            }
            
            mapOptions.traitCollection = UITraitCollection(userInterfaceStyle: .dark)
            // Create the snapshotter and run it
            let snapshotterDark = MKMapSnapshotter(options: mapOptions)
            snapshotterDark.start(with: .global()) { (snapshotOrNil, errorOrNil) in
                if let error = errorOrNil {
                    print(error)
                    return
                }
                if let darkSnapshot = snapshotOrNil {
                    self.snapshotImageD = self.drawLineOnImage(snapshot: darkSnapshot)
                    if colorScheme == .dark {
                        self.snapshotImage = self.snapshotImageD
                    }
                    self.snapshotImageDataD = self.snapshotImageD?.jpegData(compressionQuality: 1.0)
                    if let darkData = self.snapshotImageDataD {
                        DispatchQueue.main.async {
                            trip.darkImage = darkData
                            PersistenceController.shared.save()
                        }
                        
                    }
                }
            }
            
        } else {
            self.snapshotImage = UIImage(data: (colorScheme == condition ? trip.lightImage : trip.darkImage)!, scale: hasHomeButton ? 2.75 : 3)
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
            generateSnapshot(width: 140, height: 162, condition: .light)
        }
        .onChange(of: colorScheme) { _, newValue in
            generateSnapshot(width: 140, height: 162, condition: .dark)
        }
    }
}



//struct StaticPolylineMap_Previews: PreviewProvider {
//    static var previews: some View {
//        StaticPolylineMap(region: MKCoordinateRegion())
//    }
//}
