import SwiftUI

struct CarDetailView: View {
    let carID: Int

    @Environment(\.dismiss) var dismiss
    @State private var car: CarDetail?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Image("Loginbackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView("Loading Car Details...")
                        .padding()
                        .background(.ultraThickMaterial)
                        .cornerRadius(12)
                } else if let car = car {
                    ScrollView {
                        VStack(spacing: 20) {
                            Spacer().frame(height: 20)

                            // Car Image
                            AsyncImage(url: URL(string: "http://localhost/Driver/\(car.image_path)")) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 280, height: 180)
                            .clipped()
                            .cornerRadius(10)

                            // Car Details
                            HintFieldView(placeholder: "Car Name: \(car.car_name)", systemIcon: "car.fill")
                            HintFieldView(placeholder: "Driver Name: \(car.driver_name)", systemIcon: "person.fill")
                            HintFieldView(placeholder: "Condition: \(car.condition)", systemIcon: "wrench.fill")

                            HintFieldView(
                                placeholder: "Contact Number: \(car.contactnumber ?? "Not Provided")",
                                systemIcon: "phone.fill",
                                isPhone: car.contactnumber != nil,
                                phoneNumber: car.contactnumber ?? ""
                            )

                            HintFieldView(
                                placeholder: "Driver Age: \(car.age?.description ?? "Not Provided")",
                                systemIcon: "person.circle"
                            )

                            HintFieldView(
                                placeholder: "Experience: \(car.experienceyears?.description ?? "Not Provided") years",
                                systemIcon: "clock"
                            )

                            Spacer()
                        }
                        .padding()
                    }
                } else {
                    Text(errorMessage ?? "Failed to load car details.")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Car Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true) // 🔹 This line hides the default back button
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss() // Go back to UserPageView
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .onAppear(perform: fetchCarDetails)
        }
    }

    // MARK: - API Call
    func fetchCarDetails() {
        let url = "http://localhost/Driver/fetchsinglecar.php"
        let formData = ["car_id": carID]

        APIHandler.shared.postAPIValues(
            type: CarDetailResponse.self,
            apiUrl: url,
            method: "POST",
            formData: formData
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    if response.status, let carData = response.data {
                        self.car = carData
                    } else {
                        errorMessage = "Car not found or server returned an error."
                    }
                case .failure(let error):
                    errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CarDetailView(carID: 14)
}

// MARK: - Response Models
struct CarDetailResponse: Codable {
    let status: Bool
    let data: CarDetail?
}

struct CarDetail: Codable {
    let car_id: Int
    let car_name: String
    let image_path: String
    let condition: String
    let driver_name: String
    let age: Int?
    let experienceyears: Int?
    let contactnumber: String?
}
