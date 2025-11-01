import SwiftUI
import MapKit

struct UserPageView: View {
    let userID: Int
    init(userID: Int = -1) { self.userID = userID }

    @State private var selectedDate = Date()
    @State private var availableDrivers: [TouchDriver] = []
    @State private var availableCars: [Car] = []
    @State private var isMenuOpen = false
    @State private var showLoginView = false
    @State private var totalAmount: Int? = nil
    @State private var priceError: String? = nil
    @State private var isLoadingDrivers = false
    @State private var isLoadingPrice = false
    @State private var selectedCar: Car? = nil
    @State private var navigateToDriverBooking = false
    @State private var selectedCarID: Int? = nil

    @State private var originCoordinate: CLLocationCoordinate2D? = nil
    @State private var destinationCoordinate: CLLocationCoordinate2D? = nil

    @State private var path = NavigationPath()
    
    @State private var openCardDetail = false

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Image("Loginbackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 12) {
                    headerView

                    ScrollView {
                        VStack(spacing: 20) {
                            availabilityCalendarSection
                            priceDetailsSection
                            availableCarsSection
                            profileSection
                            bookingDetailsSection
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                    }
                }

                if isLoadingDrivers || isLoadingPrice {
                    Color.black.opacity(0.25).ignoresSafeArea()
                    ProgressView("Loading...")
                        .padding()
                        .background(.ultraThickMaterial)
                        .cornerRadius(12)
                }
            }
            .onAppear { fetchAvailableCars() }
//            .navigationDestination(item: $selectedCarID) { id in
//                CarDetailView(carID: id.id)
//            }
            .navigationDestination(isPresented: $openCardDetail) {
                CarDetailView(carID: selectedCarID ?? 0)
            }
            .navigationDestination(isPresented: $showLoginView) {
                    LoginView()
                }
        }
    }

    

    

    private var headerView: some View {
        HStack(spacing: 10) {
            Image("userlogo")
                .resizable()
                .scaledToFit()
                .frame(height: 28)

            Text("User Dashboard")
                .font(.title.bold())
                .foregroundColor(.black)

            Spacer()

            Menu {
                Button(role: .destructive) {
                    showLoginView = true
                } label: {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                }
            } label: {
                Image(systemName: isMenuOpen ? "xmark" : "ellipsis.circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)
                    .padding(8)
            }
            .onTapGesture {
                withAnimation {
                    isMenuOpen.toggle()
                }
            }
            .onChange(of: isMenuOpen) { newValue in
                // Handle menu state changes if needed
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .cornerRadius(20)
        .shadow(radius: 4)
        .padding(.horizontal)
    }
    private var availabilityCalendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Availability calendar").font(.headline)

            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .onChange(of: selectedDate) { _ in
                    navigateToDriverBooking = true
                }

            NavigationLink(
                destination: DriverBookingView(initialDate: selectedDate, userID: userID),
                isActive: $navigateToDriverBooking
            ) {
                EmptyView()
            }

            ForEach(availableDrivers) { d in
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .resizable().frame(width: 40, height: 40).foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text(d.driverName).bold()
                        Text(d.driverContact.description).font(.caption).foregroundColor(.secondary)
                    }
                }
            }
        }.sectionCardStyle()
    }

    private var priceDetailsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Price Details").font(.headline)

            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: originCoordinate ?? destinationCoordinate ?? CLLocationCoordinate2D(latitude: 11.1271, longitude: 78.6569),
                span: MKCoordinateSpan(latitudeDelta: 2.5, longitudeDelta: 2.5)
            )), annotationItems: annotationPlaces) { place in
                MapPin(coordinate: place.coordinate, tint: place.name == "Origin" ? .green : .red)
            }
            .frame(height: 220)
            .cornerRadius(12)
            .shadow(radius: 4)

            NavigationLink(destination: MapFareSelectorViews(originCoordinate: $originCoordinate, destinationCoordinate: $destinationCoordinate)) {
                Text("View full map to see price")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(10)
            }

            if let fare = totalAmount {
                HStack {
                    Text("Total Fare")
                    Spacer()
                    Text("\u{20B9}\(fare)").bold()
                }
            } else if let err = priceError {
                Text(err).foregroundColor(.red).font(.caption)
            }
        }
        .sectionCardStyle()
    }

    private var annotationPlaces: [Place] {
        var result: [Place] = []
        if let o = originCoordinate { result.append(Place(name: "Origin", coordinate: o)) }
        if let d = destinationCoordinate { result.append(Place(name: "Destination", coordinate: d)) }
        return result
    }

    private var availableCarsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Available Cars").font(.headline)
            GeometryReader { outerGeo in
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(availableCars) { car in
                                GeometryReader { itemGeo in
                                    let itemFrame = itemGeo.frame(in: .global)
                                    let outerFrame = outerGeo.frame(in: .global)
                                    let distanceFromCenter = abs(itemFrame.midX - outerFrame.midX)
                                    let scale = max(1.0, 1.2 - (distanceFromCenter / 300))
                                    let isCentered = distanceFromCenter < 30

                                    Button {
                                        withAnimation {
                                            
                                            selectedCar = car
                                            openCardDetail = true
                                            selectedCarID = car.id
                                            scrollProxy.scrollTo(car.id, anchor: .center)
                                           
                                           
                                        }
                                    } label: {
                                        VStack {
                                            AsyncImage(url: URL(string: "http://localhost/Driver/\(car.imageURL)")) { image in
                                                image.resizable().scaledToFill()
                                                    .frame(width: 100, height: 80)
                                                    .clipped().cornerRadius(10)
                                            } placeholder: {
                                                ProgressView().frame(width: 80, height: 80)
                                            }
                                            Text(car.carName)
                                                .font(.caption)
                                                .foregroundColor(.primary)
                                        }
                                        .padding(6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .shadow(color: isCentered ? .blue.opacity(0.3) : .clear, radius: 8)
                                        )
                                        .scaleEffect(scale)
                                        .animation(.easeInOut(duration: 0.25), value: scale)
                                    }
                                    .buttonStyle(.plain)
                                    .id(car.id)
                                }
                                .frame(width: 120, height: 120)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
            .frame(height: 150)
        }
        .sectionCardStyle()
    }

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Profiles").font(.headline).padding(.leading)
            VStack(spacing: 10) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable().frame(width: 80, height: 80).foregroundColor(.blue)

                NavigationLink(destination: UserProfileView(userID: userID)) {
                    Text("View Profile")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(20)
                        .foregroundColor(.white)
                }.padding(.horizontal)
            }.frame(maxWidth: .infinity)
        }.sectionCardStyle()
    }

    private var bookingDetailsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Bookings").font(.headline).padding(.leading)
            VStack(spacing: 10) {
                Image(systemName: "calendar")
                    .resizable().frame(width: 80, height: 80).foregroundColor(.orange)

                NavigationLink(destination: BookingStatusView(userID: userID)) {
                    Text("Booking Details")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(20)
                        .foregroundColor(.white)
                }.padding(.horizontal)
            }.frame(maxWidth: .infinity)
        }.sectionCardStyle()
    }

    private func fetchAvailableCars() {
        APIHandler.shared.fetchCars(for: userID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cars): self.availableCars = cars
                case .failure(let error): print("Fetch cars error:", error.localizedDescription)
                }
            }
        }
    }
   
    
    
}

// MARK: - Supporting Types

extension View {
    func sectionCardStyle() -> some View {
        self.padding()
            .background(.ultraThickMaterial)
            .cornerRadius(20)
            .shadow(radius: 4)
            .padding(.horizontal)
    }
}

extension Int: Identifiable {
    public var id: Int { self }
}

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
