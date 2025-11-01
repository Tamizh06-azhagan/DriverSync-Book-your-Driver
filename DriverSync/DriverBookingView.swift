import SwiftUI

struct DriverBookingView: View {
    @Environment(\.dismiss) var dismiss

    let initialDate: Date
    let userID: Int  // 🔑 THIS is the USER ID (logged-in user)

    @State private var showSuccess = false
    @State private var bookedDriverName = ""
    @State private var priceError = ""

    @State private var allDrivers: [GetDriverData] = []
    @State private var selectedDriver: GetDriverData? = nil
    @State private var pickupLocation = ""
    @State private var destination = ""

    var body: some View {
        ZStack {
            Image("Loginbackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Available Drivers on \(formattedDate(initialDate))")
                    .font(.title3)
                    .fontWeight(.medium)

                if allDrivers.isEmpty {
                    Text("🎉 All drivers booked or none available.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(allDrivers, id: \.driverID) { driver in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .padding(.leading)

                                        Text(driver.driverName)
                                            .font(.headline)

                                        Spacer()

                                        Button("Book Now") {
                                            selectedDriver = driver
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    }

                                    if selectedDriver?.driverID == driver.driverID {
                                        VStack(alignment: .leading, spacing: 10) {
                                            TextField("Pickup Location", text: $pickupLocation)
                                                .padding()
                                                .background(Color(.systemGray6))
                                                .cornerRadius(8)

                                            TextField("Destination", text: $destination)
                                                .padding()
                                                .background(Color(.systemGray6))
                                                .cornerRadius(8)

                                            Button("Confirm Booking") {
                                                confirmBooking(for: driver)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)

                                            if !priceError.isEmpty {
                                                Text(priceError)
                                                    .foregroundColor(.red)
                                                    .font(.caption)
                                            }
                                        }
                                        .padding(.top)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(radius: 2)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding()

            if showSuccess {
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)

                    Text("Successfully Booked \(bookedDriverName)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(width: 280, height: 200)
                .background(Color.green)
                .cornerRadius(20)
                .shadow(radius: 10)
                .transition(.scale)
            }
        }
        .animation(.easeInOut, value: showSuccess)
        .onAppear {
            fetchAvailableDrivers()
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func formattedBookingDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func fetchAvailableDrivers() {
        let date = ISO8601DateFormatter().string(from: initialDate).split(separator: "T").first!
        let form = ["availability_date": String(date)]

        APIHandler.shared.postAPIValues(
            type: GetDriver.self,
            apiUrl: ServiceAPI.userAvailability,
            method: "POST",
            formData: form
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let resp) where resp.status:
                    let uniqueDrivers = Array(Set(resp.drivers.map { $0.driverID })).compactMap { id in
                        resp.drivers.first { $0.driverID == id }
                    }
                    allDrivers = uniqueDrivers
                case .success(let resp):
                    priceError = resp.message
                case .failure(let err):
                    priceError = err.localizedDescription
                }
            }
        }
    }

    private func confirmBooking(for driver: GetDriverData) {
        if pickupLocation.isEmpty || destination.isEmpty {
            priceError = "Please enter both Pickup and Destination"
            return
        }

        let form: [String: String] = [
            "userid": "\(userID)", // ✅ USER is booking
            "driver_id": "\(driver.driverID)", // ✅ DRIVER is being booked
            "dateofbooking": formattedBookingDate(initialDate),
            "status": "Pending",
            "pickup_address": pickupLocation,
            "destination_address": destination
        ]

        APIHandler.shared.postAPIValues(
            type: BookingInsertResponse.self,
            apiUrl: ServiceAPI.insertbooking,
            method: "POST",
            formData: form
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let resp) where resp.status == "success":
                    bookedDriverName = driver.driverName
                    showSuccess = true

                    if let index = allDrivers.firstIndex(where: { $0.driverID == driver.driverID }) {
                        allDrivers.remove(at: index)
                    }

                    selectedDriver = nil
                    pickupLocation = ""
                    destination = ""

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        showSuccess = false
                        dismiss()
                    }

                case .success(let resp):
                    priceError = resp.message
                case .failure(let err):
                    priceError = err.localizedDescription
                }
            }
        }
    }
}

// MARK: - Booking Response Model
struct BookingInsertResponse: Codable {
    let status: String
    let message: String
}
