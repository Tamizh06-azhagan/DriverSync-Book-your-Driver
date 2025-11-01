import SwiftUI

// MARK: - Enum for Booking Status
enum BookingStatus: String, Codable {
    case accepted = "accepted"
    case rejected = "rejected"
    case pending = "Pending" // Match case exactly with your JSON
}

// MARK: - Model for Each Booking Returned to User
struct UserBooking: Identifiable, Codable {
    let id: Int
    let date: String
    let pickupAddress: String?
    let destinationAddress: String?
    let driverName: String
    let status: BookingStatus

    enum CodingKeys: String, CodingKey {
        case id = "booking_id"
        case date
        case pickupAddress = "pickup_address"
        case destinationAddress = "destination_address"
        case driverName = "driver_name"
        case status
    }
}

// MARK: - Root Response Model
struct BookingStatusResponse: Codable {
    let status: Bool
    let message: String
    let data: [UserBooking]
}

// MARK: - Booking Status View
struct BookingStatusView: View {
    let userID: Int

    @State private var bookings: [BookingStatusData] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Image("Loginbackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                Text("My Booking Status")
                    .font(.title)
                    .bold()
                    .padding(.top)

                if isLoading {
                    ProgressView("Fetching bookings...")
                        .padding()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if bookings.isEmpty {
                    Text("No bookings found.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(bookings, id: \.bookingID) { booking in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Date: \(booking.date)")
                                        .font(.headline)

                                    Text("Driver: \(booking.driverName)")
                                        .font(.subheadline)

                                    Text("Pickup: \(booking.pickupAddress ?? "N/A")")
                                        .font(.caption)

                                    Text("Destination: \(booking.destinationAddress ?? "N/A")")
                                        .font(.caption)

                                    Text("Status: \(booking.status.rawValue.capitalized)")
                                        .font(.subheadline)
                                        .foregroundColor(
                                            booking.status.rawValue.lowercased() == "accepted" ? .green :
                                            booking.status.rawValue.lowercased() == "rejected" ? .red :
                                            .orange
                                        )
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 3)
                            }

                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .onAppear {
            fetchBookingStatus()
        }
    }

    private func statusColor(for status: BookingStatus) -> Color {
        switch status {
        case .accepted: return .green
        case .rejected: return .red
        case .pending:  return .orange
        }
    }

    private func fetchBookingStatus() {
        let formData = ["userid": String(userID)]

        APIHandler.shared.postAPIValues(
            type: BookingStatusUser.self,
            apiUrl: ServiceAPI.fetchBookingStatus,
            method: "POST",
            formData: formData
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    if response.status {
                        bookings = response.data
                    } else {
                        errorMessage = response.message
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
