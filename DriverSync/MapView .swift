import SwiftUI
import MapKit

struct SavedRoute: Identifiable {
    let id = UUID()
    let from: String
    let to: String
    let distance: Double
    let duration: TimeInterval
    let fare: Int
}

struct MapFareSelectorViews: View {
    @Binding var originCoordinate: CLLocationCoordinate2D?
    @Binding var destinationCoordinate: CLLocationCoordinate2D?

    @Environment(\.dismiss) var dismiss
    @State private var route: MKRoute?

    @State private var originAddress = ""
    @State private var destinationAddress = ""
    @State private var placeNameOrigin = ""
    @State private var placeNameDestination = ""
    @State private var geocodingError: String?

    @State private var savedRoutes: [SavedRoute] = []
    @State private var showSavedRoutes = false
    @State private var isRouteSaved = false

    var body: some View {
        ZStack {
            // Background image only - no additional colors
            Image("Loginbackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Toast message
            if isRouteSaved {
                Text("Successfully saved!")
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .transition(.opacity)
                    .animation(.easeInOut, value: isRouteSaved)
                    .zIndex(1)
                    .offset(y: -UIScreen.main.bounds.height / 3)
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    Spacer().frame(height: 60)

                    // Saved Routes Button
                    Button(action: {
                        showSavedRoutes.toggle()
                    }) {
                        HStack {
                            Image(systemName: "tray.full")
                            Text("Saved Routes")
                        }
                        .font(.subheadline)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }

                    // Input Fields
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.black)
                            TextField("Enter Origin", text: $originAddress)
                                .autocapitalization(.words)
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                        .frame(height: 40)
                        .frame(width: 330)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))

                        HStack(spacing: 8) {
                            Image(systemName: "flag.circle.fill")
                                .foregroundColor(.black)
                            TextField("Enter Destination", text: $destinationAddress)
                                .autocapitalization(.words)
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                        .frame(height: 40)
                        .frame(width: 330)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))

                        Button("Find Route") {
                            geocodeAndCalculateRoute()
                        }
                        .font(.subheadline)
                        .frame(width: 140, height: 40)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        if let error = geocodingError {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }

                    // Map View
                    MapViewRepresentable(origin: $originCoordinate, destination: $destinationCoordinate, route: $route)
                        .frame(height: 450)
                        .cornerRadius(16)
                        .padding(.horizontal)

                    // Clear Map
                    Button("Clear Map") {
                        originAddress = ""
                        destinationAddress = ""
                        originCoordinate = nil
                        destinationCoordinate = nil
                        route = nil
                        placeNameOrigin = ""
                        placeNameDestination = ""
                        isRouteSaved = false
                    }
                    .foregroundColor(.red)
                    .padding(.top, 4)

                    // Route Info
                    if let route = route {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text("From: ").bold() + Text(placeNameOrigin)
                            }
                            HStack {
                                Image(systemName: "flag.circle")
                                Text("To: ").bold() + Text(placeNameDestination)
                            }
                            Divider()
                            HStack {
                                Image(systemName: "ruler")
                                Text("Distance: ") + Text(String(format: "%.2f km", route.distance / 1000))
                            }
                            HStack {
                                Image(systemName: "clock")
                                Text("Duration: ") + Text("\(Int(route.expectedTravelTime / 60)) mins")
                            }
                            HStack {
                                Image(systemName: "creditcard")
                                Text("Estimated Fare: ") + Text("₹\(Int((route.distance / 1000) * 15))")
                            }

                            Button(action: {
                                let saved = SavedRoute(
                                    from: placeNameOrigin,
                                    to: placeNameDestination,
                                    distance: route.distance,
                                    duration: route.expectedTravelTime,
                                    fare: Int((route.distance / 1000) * 15)
                                )
                                savedRoutes.append(saved)
                                isRouteSaved = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isRouteSaved = false
                                }
                            }) {
                                if isRouteSaved {
                                    Label("Saved", systemImage: "checkmark")
                                } else {
                                    Label("Save Route", systemImage: "square.and.arrow.down")
                                }
                            }
                            .font(.subheadline)
                            .frame(width: 120, height: 40)
                            .background(isRouteSaved ? Color.green : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top, 8)
                            .animation(.easeInOut, value: isRouteSaved)
                        }
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }

                    Spacer(minLength: 20)
                }
                .frame(minHeight: UIScreen.main.bounds.height)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear) // Critical for removing white flash
            .sheet(isPresented: $showSavedRoutes) {
                NavigationView {
                    List(savedRoutes) { route in
                        VStack(alignment: .leading) {
                            Text("From: \(route.from)")
                            Text("To: \(route.to)")
                            Text(String(format: "Distance: %.2f km", route.distance / 1000))
                            Text("Duration: \(Int(route.duration / 60)) mins")
                            Text("Fare: ₹\(route.fare)")
                        }
                        .padding(.vertical, 4)
                    }
                    .navigationTitle("Saved Routes")
                    .toolbar {
                        Button("Close") {
                            showSavedRoutes = false
                        }
                    }
                }
            }
        }
    }

    // Rest of your existing functions (geocodeAndCalculateRoute, drawRoute) remain the same...
    func geocodeAndCalculateRoute() {
        let geocoder = CLGeocoder()

        guard !originAddress.isEmpty, !destinationAddress.isEmpty else {
            geocodingError = "Please enter both origin and destination."
            return
        }

        geocoder.geocodeAddressString(originAddress) { originPlacemarks, _ in
            if let originPlacemark = originPlacemarks?.first,
               let originCoord = originPlacemark.location?.coordinate {
                originCoordinate = originCoord
                placeNameOrigin = originPlacemark.name ?? originAddress

                geocoder.geocodeAddressString(destinationAddress) { destPlacemarks, _ in
                    if let destPlacemark = destPlacemarks?.first,
                       let destCoord = destPlacemark.location?.coordinate {
                        destinationCoordinate = destCoord
                        placeNameDestination = destPlacemark.name ?? destinationAddress
                        drawRoute()
                    } else {
                        geocodingError = "Invalid destination address."
                    }
                }
            } else {
                geocodingError = "Invalid origin address."
            }
        }
    }

    func drawRoute() {
        geocodingError = nil
        guard let origin = originCoordinate, let destination = destinationCoordinate else { return }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile

        MKDirections(request: request).calculate { response, _ in
            if let route = response?.routes.first {
                self.route = route
            }
        }
    }
}

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var origin: CLLocationCoordinate2D?
    @Binding var destination: CLLocationCoordinate2D?
    @Binding var route: MKRoute?

    let mapView = MKMapView()

    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = true

        mapView.setRegion(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 21.0, longitude: 78.0),
            span: MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20)
        ), animated: false)

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)

        if let origin = origin {
            let annotation = MKPointAnnotation()
            annotation.coordinate = origin
            annotation.title = "Origin"
            uiView.addAnnotation(annotation)
        }

        if let destination = destination {
            let annotation = MKPointAnnotation()
            annotation.coordinate = destination
            annotation.title = "Destination"
            uiView.addAnnotation(annotation)
        }

        uiView.removeOverlays(uiView.overlays)
        if let route = route {
            uiView.addOverlay(route.polyline)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }

        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let location = gestureRecognizer.location(in: parent.mapView)
            let coordinate = parent.mapView.convert(location, toCoordinateFrom: parent.mapView)

            if parent.origin == nil {
                parent.origin = coordinate
            } else if parent.destination == nil {
                parent.destination = coordinate
                drawRoute()
            } else {
                parent.origin = coordinate
                parent.destination = nil
                parent.route = nil
            }
        }

        func drawRoute() {
            guard let origin = parent.origin, let destination = parent.destination else { return }

            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
            request.transportType = .automobile

            MKDirections(request: request).calculate { response, _ in
                if let route = response?.routes.first {
                    DispatchQueue.main.async {
                        self.parent.route = route
                    }
                }
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(overlay: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
