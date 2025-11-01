import SwiftUI
import MapKit

struct RouteMapView: View {
    @Environment(\.dismiss) var dismiss

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 11.0168, longitude: 76.9558),
        span: MKCoordinateSpan(latitudeDelta: 2.5, longitudeDelta: 2.5)
    )

    @State private var originCoordinate: CLLocationCoordinate2D?
    @State private var destinationCoordinate: CLLocationCoordinate2D?
    @State private var route: MKRoute?
    @State private var distanceInKM: Double?

    @State private var originAddress = ""
    @State private var destinationAddress = ""
    @State private var geocodingError: String?

    var body: some View {
        ZStack {
            Image("Loginbackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Spacer().frame(height: 30)

                // Address Inputs
                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.blue)
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
                            .foregroundColor(.red)
                        TextField("Enter Destination", text: $destinationAddress)
                            .autocapitalization(.words)
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                    .frame(height: 40)
                    .background(Color.white)
                    .cornerRadius(10)
                    .frame(width: 330)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))

                    Button(action: {
                        geocodeAddresses()
                    }) {
                        HStack {
                            Text("Find Route")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .frame(minWidth: 140)

                    if let error = geocodingError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding(.horizontal)

                // Map View
                MapViewRepresentables(
                    region: $region,
                    origin: $originCoordinate,
                    destination: $destinationCoordinate,
                    route: $route
                )
                .frame(height: 450)
                .cornerRadius(15)
                .padding(.horizontal)

                // Clear Button
                Button("Clear") {
                    originCoordinate = nil
                    destinationCoordinate = nil
                    originAddress = ""
                    destinationAddress = ""
                    route = nil
                    distanceInKM = nil
                    geocodingError = nil
                }
                .foregroundColor(.red)
                .padding(8)
                .background(Color.white)
                .cornerRadius(10)

                // Distance View
                if let distance = distanceInKM {
                    HStack(spacing: 12) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)

                        Text(String(format: "Distance: %.2f km", distance))
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 5)
                    .padding(.top, 5)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.easeInOut(duration: 0.5), value: distanceInKM)
                }

                Spacer()
            }
        }
    }

    // MARK: - Geocode
    func geocodeAddresses() {
        let geocoder = CLGeocoder()

        guard !originAddress.isEmpty, !destinationAddress.isEmpty else {
            geocodingError = "Please enter both origin and destination."
            return
        }

        geocoder.geocodeAddressString(originAddress) { originPlacemarks, _ in
            if let originCoord = originPlacemarks?.first?.location?.coordinate {
                originCoordinate = originCoord

                geocoder.geocodeAddressString(destinationAddress) { destPlacemarks, _ in
                    if let destCoord = destPlacemarks?.first?.location?.coordinate {
                        destinationCoordinate = destCoord
                        calculateRoute()
                    } else {
                        geocodingError = "Unable to find destination location."
                    }
                }
            } else {
                geocodingError = "Unable to find origin location."
            }
        }
    }

    // MARK: - Route Calculation
    func calculateRoute() {
        geocodingError = nil
        guard let origin = originCoordinate, let destination = destinationCoordinate else { return }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile

        MKDirections(request: request).calculate { response, _ in
            if let route = response?.routes.first {
                self.route = route
                self.distanceInKM = route.distance / 1000.0
                self.region = MKCoordinateRegion(route.polyline.boundingMapRect)
            }
        }
    }
}

// MARK: - MapViewRepresentables
struct MapViewRepresentables: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var origin: CLLocationCoordinate2D?
    @Binding var destination: CLLocationCoordinate2D?
    @Binding var route: MKRoute?

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.setRegion(region, animated: false)
        map.showsUserLocation = true
        map.isZoomEnabled = true
        map.isScrollEnabled = true

        let gesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
        map.addGestureRecognizer(gesture)

        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.removeOverlays(uiView.overlays)

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

        if let route = route {
            uiView.addOverlay(route.polyline)
            let rect = route.polyline.boundingMapRect
            uiView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 40, left: 20, bottom: 40, right: 20), animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentables

        init(_ parent: MapViewRepresentables) {
            self.parent = parent
        }

        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began,
                  let mapView = gesture.view as? MKMapView else { return }

            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

            if parent.origin == nil {
                parent.origin = coordinate
            } else if parent.destination == nil {
                parent.destination = coordinate
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(overlay: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
