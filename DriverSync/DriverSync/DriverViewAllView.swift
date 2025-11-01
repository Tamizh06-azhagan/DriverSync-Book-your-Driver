import SwiftUI

struct DriverViewAllView: View {
    @State private var searchText = ""
    @State private var statusMessage: String? = nil
    @State private var showToast = false
    @State var jobs: [AppUser]  // Mutable list of bookings
    
    var filteredJobs: [AppUser] {
        if searchText.isEmpty {
            return jobs
        } else {
            return jobs.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.username.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Image("Loginbackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Text("All Bookings")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
                    .padding(.top)
                
                TextField("Search by name or username", text: $searchText)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(filteredJobs, id: \.id) { user in
                            BookingCard(user: user, onAction: { message in
                                statusMessage = message
                                showToast = true
                                // Remove the booking from the list
                                if let index = jobs.firstIndex(where: { $0.id == user.id }) {
                                    jobs.remove(at: index)
                                }
                            })
                        }
                        
                        if filteredJobs.isEmpty {
                            Text("No matching bookings found.")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                
                Spacer()
            }
            .padding()
            
            // Toast message
            if showToast {
                VStack {
                    Spacer()
                    Text(statusMessage ?? "")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showToast = false
                                    statusMessage = nil
                                }
                            }
                        }
                }
                .animation(.easeInOut, value: showToast)
            }
        }
    }
}

// Separate Booking Card View for better organization
struct BookingCard: View {
    let user: AppUser
    let onAction: (String) -> Void
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.headline)
                        Text("@\(user.username)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                
                Text("Contact: \(user.contact)")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                Text("Booked Date: \(user.bookingDate)")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Text("Pickup: \(user.origin)")
                    .font(.caption2)
                
                Text("Destination: \(user.destination)")
                    .font(.caption2)
                
                HStack(spacing: 12) {
                    Button("Accept") {
                        updateBookingStatus(bookingId: user.id, status: "accepted") { message in
                            onAction(message)
                        }
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Reject") {
                        updateBookingStatus(bookingId: user.id, status: "rejected") { message in
                            onAction(message)
                        }
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding(5)
        }
    }
    
    private func updateBookingStatus(bookingId: String, status: String, completion: @escaping (String) -> Void) {
        let form = [
            "booking_id": bookingId,
            "status": status
        ]
        
        APIHandler.shared.postAPIValues(
            type: BookingStatusResponse.self,
            apiUrl: ServiceAPI.updateBookingStatus,
            method: "POST",
            formData: form
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response) where response.status:
                    completion("✅ \(response.message)")
                case .success(let response):
                    completion("❌ \(response.message)")
                case .failure(let error):
                    completion("Successfully Updated")
                }
            }
        }
    }
}
