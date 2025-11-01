import SwiftUI
import MapKit

// MARK: - Root Response
struct DriverBookingResponse: Codable {
    let status: Bool
    let message: String
    let data: [DriverBookingData]
}

// MARK: - Each Booking Assigned to Driver
struct DriverBookingData: Identifiable, Codable {
    let id: Int
    let dateofbooking: String
    let status: BookingDriverStatus
    let pickupAddress: String?
    let destinationAddress: String?
    let username: String
    let contactNumber: String
    let email: String
    let driver_name: String

    enum CodingKeys: String, CodingKey {
        case id = "booking_id"
        case dateofbooking
        case status
        case pickupAddress = "pickup_address"
        case destinationAddress = "destination_address"
        case username
        case contactNumber = "contact_number"
        case email
        case driver_name
    }
}

// MARK: - Booking Status Enum
enum BookingDriverStatus: String, Codable {
    case accepted = "accepted"
    case rejected = "rejected"
    case pending = "Pending"
}




// MARK: - Availability Response
struct AvailabilityResponse: Codable {
    let status: Bool
    let message: String
}

// MARK: - GlassCard View
struct GlassCard<Content: View>: View {
    let content: () -> Content

    var body: some View {
        content()
            .padding()
            .background(.ultraThickMaterial.opacity(1.0))
            .cornerRadius(20)
            .shadow(radius: 4)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Availability Sheet View
struct AvailabilitySheetView: View {
    @Environment(\.dismiss) var dismiss
    var date: Date
    var onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Set Availability").font(.title2)
            Text("Are you available on \(formatted(date))?").font(.body)
            HStack {
                Button("NO") { dismiss() }
                    .foregroundColor(.red)
                Spacer()
                Button("YES") {
                    onConfirm()
                    dismiss()
                }
                .foregroundColor(.green)
            }
            .padding(.top, 10)
        }
        .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .padding()
    }

    func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Driver Page View
import SwiftUI

struct DriverPageView: View {
    let driverID: Int

    @State private var selectedDate = Date()
    @State private var confirmedAvailabilityDate: Date? = nil
    @State private var showAvailabilitySheet = false
    @State private var showLoginView = false
    @State private var bookings: [DriverBookingData] = []
    @State private var navigateToViewAll = false
    @State private var navigateToProfile = false
    @State private var navigateToAddCars = false
    @State private var navigateToRouteFinder = false


    // Price Section States
    @State private var selectedOrigin = ""
    @State private var selectedDestination = ""
    @State private var selectedDays = ""
    @State private var totalAmount: Int? = nil
    @State private var priceError: String? = nil
    @State private var isLoadingPrice = false

    // General loading and alerts
    @State private var isLoading = false
    @State private var showSuccessAlert = false
    @State private var alertMessage = ""

    let origins = ["Chennai", "Coimbatore", "Chengalpet", "Kanchipuram", "Villupuram", "Banglore", "Pondicherry", "Thiruvannamalai", "Thirupathi", "Vellore"]
    let destinations = ["Chennai", "Coimbatore", "Chengalpet", "Kanchipuram", "Villupuram", "Banglore", "Pondicherry", "Thiruvannamalai", "Thirupathi", "Vellore"]
    let days = ["1 Day", "2 Days", "3 Days", "4 Days","5 Days","6 Days","7 Days"]

    var appUsers: [AppUser] {
        bookings.map {
            AppUser(
                id: String($0.id),
                name: $0.username,
                username: $0.username,
                contact: $0.contactNumber,
                bookingDate: $0.dateofbooking,
                origin: $0.pickupAddress ?? "",
                destination: $0.destinationAddress ?? ""
            )
        }
    }

    var body: some View {
            ZStack {
                Image("Loginbackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    // Header
                    HStack {
                        HStack(spacing: 10) {
                            Image("userlogo") // Add your logo in Assets with name "logo"
                                .resizable()
                                .frame(width: 32, height: 32)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Text("Driver Dashboard")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }

                        Spacer()

                        Button(action: {
                            fetchDriverBookings(driverID: driverID)
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundColor(.black)
                        }
                        .frame(width: 30, height: 30)

                        Menu {
                            Button {
                                showLoginView = true
                            } label: {
                                Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                            }

                            Button {
                                navigateToAddCars = true
                            } label: {
                                Label("Add Cars", systemImage: "car.fill")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundColor(.black)
                        }
                        .frame(width: 30, height: 30)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .cornerRadius(14)
                    .padding(.top, 10)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20){
                            // In the Jobs Section of DriverPageView, replace the existing code with:
                            GlassCard {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Jobs").font(.headline)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            // Display first 5 jobs or all if less than 5
                                            ForEach(bookings.prefix(5)) { booking in
                                                VStack(spacing: 6) {
                                                    Image(systemName: "person.crop.circle.fill")
                                                        .resizable()
                                                        .frame(width: 40, height: 40)
                                                        .foregroundColor(.blue)
                                                    
                                                    Text(booking.username).font(.subheadline)
                                                    Text("Date: \(booking.dateofbooking)")
                                                        .font(.caption2).foregroundColor(.gray)
                                                    Text("From: \(booking.pickupAddress ?? "")").font(.caption2)
                                                    Text("To: \(booking.destinationAddress ?? "")").font(.caption2)
                                                    Text("Status: \(booking.status.rawValue.capitalized)")
                                                        .font(.caption2)
                                                        .foregroundColor(color(for: booking.status))
                                                }
                                                .padding()
                                                .background(.ultraThinMaterial.opacity(0.8))
                                                .cornerRadius(12)
                                            }
                                            
                                            // Show chevron button if more than 5 jobs
                                            if bookings.count > 5 {
                                                Button(action: {
                                                    navigateToViewAll = true
                                                }) {
                                                    VStack {
                                                        Image(systemName: "chevron.right.circle.fill")
                                                            .resizable()
                                                            .frame(width: 40, height: 40)
                                                            .foregroundColor(.blue)
                                                        Text("More")
                                                            .font(.caption)
                                                    }
                                                    .padding()
                                                }
                                            }
                                        }
                                    }
                                    
                                    Button("View All") {
                                        navigateToViewAll = true
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                }
                            }

                            // Availability Section
                            GlassCard {
                                VStack(alignment: .leading, spacing: 12) {
                                Text("Availability").font(.headline)

                                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .onChange(of: selectedDate) { _ in
                                    showAvailabilitySheet = true
                                }

                                    if let date = confirmedAvailabilityDate {
                                    Text("Confirmed: \(formatted(date))")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                            }
                        }

                            // MARK: - Route Finder Section
                            GlassCard {
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Route Finder")
                                        .font(.headline)
                                        .foregroundColor(.black)

                                    // Mini live map preview
                                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: 11.0168, longitude: 76.9558), // Coimbatore center
                                        span: MKCoordinateSpan(latitudeDelta: 2.5, longitudeDelta: 2.5)
                                    )))
                                    .frame(height: 150)
                                    .cornerRadius(12)

                                    // Find Your Route Button
                                    Button("Find Your Route") {
                                        navigateToRouteFinder = true
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            }


                        // Profile Section
                            GlassCard {
                            VStack(spacing: 10) {
                                Text("Profile").font(.headline)
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.blue)

                                Button("View Profile") {
                                    navigateToProfile = true
                                }
                                .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 17).fill(Color.black))
                                    .foregroundColor(.white)
                            }
                            }
                        }
                    .padding(.horizontal)
                }
                }

                if isLoading {
                    Color.black.opacity(0.25).ignoresSafeArea()
                    ProgressView("Submitting...")
                        .padding()
                        .background(.ultraThickMaterial)
                        .cornerRadius(12)
                }
            }

            .sheet(isPresented: $showAvailabilitySheet) {
                AvailabilitySheetView(date: selectedDate) {
                    confirmedAvailabilityDate = selectedDate
                submitAvailability(date: selectedDate)
            }
            }

            .alert(isPresented: $showSuccessAlert) {
                Alert(title: Text("Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }

        .fullScreenCover(isPresented: $showLoginView) {
            LoginView()
        }

        .onAppear {
            fetchDriverBookings(driverID: driverID)
        }

            NavigationLink(destination: AddCarsView(userid: driverID), isActive: $navigateToAddCars) {
                EmptyView()
            }

            NavigationLink(destination: DriverViewAllView(jobs: appUsers), isActive: $navigateToViewAll) { EmptyView() }
            NavigationLink(destination: DriverProfileView(driverID: driverID), isActive: $navigateToProfile) { EmptyView() }
            NavigationLink(destination: RouteMapView(), isActive: $navigateToRouteFinder) {
                EmptyView()
            }

        
    }

    // MARK: - Utilities

    func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
}

    func color(for status: BookingDriverStatus) -> Color {
        switch status {
        case .accepted: return .green
        case .rejected: return .red
        case .pending: return .orange
    }
    }

    func submitAvailability(date: Date) {
        let formData: [String: Any] = [
            "userid": driverID,
            "availability": "Yes",
            "availability_date": formatted(date)
        ]

        isLoading = true

        APIHandler.shared.postAPIValues(
            type: AvailabilityResponse.self,
            apiUrl: ServiceAPI.driveravailability,
            method: "POST",
            formData: formData
        ) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let response):
                        alertMessage = response.message
                    case .failure(let error):
                        alertMessage = "Failed: \(error.localizedDescription)"
                    }
                    showSuccessAlert = true
                }
            }
    }

    func fetchDriverBookings(driverID: Int) {
        let formData: [String: Any] = ["driverid": driverID]

        isLoading = true
        APIHandler.shared.postAPIValues(
            type: DriverBookingResponse.self,
    apiUrl: ServiceAPI.fetchbooking,
            method: "POST",
    formData: formData
        ) { result in
                DispatchQueue.main.async {
            self.isLoading = false
            switch result {
            case .success(let res):
                if res.status {
                    self.bookings = res.data
                } else {
                        self.alertMessage = res.message
                self.showSuccessAlert = true
                    }
            case .failure(let error):
                print(error)
                self.alertMessage = "Error: \(error.localizedDescription)"
                self.showSuccessAlert = true
            }
        }
        }
    }



//    // ✅ New Function to Fetch Price
//    func fetchPriceDetails() {
//        guard !selectedOrigin.isEmpty,
//                      !selectedDestination.isEmpty,
//                      let daysCount = Int(selectedDays.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) else {
//            priceError = "All fields are required."
//            return
//        }
//
//        isLoadingPrice = true
//
//        APIHandler.shared.fetchPriceDetails(origin: selectedOrigin, destination: selectedDestination, days: daysCount) { result in
//            DispatchQueue.main.async {
//                isLoadingPrice = false
//                switch result {
//                case .success(let response) where response.status:
//            totalAmount = response.totalAmount
//            priceError = nil
//        case .success:
//            totalAmount = nil
//            priceError = "Unable to calculate price."
//        case .failure(let error):
//            totalAmount = nil
//            priceError = error.localizedDescription
//        }
//    }
//        }
//    }

}

