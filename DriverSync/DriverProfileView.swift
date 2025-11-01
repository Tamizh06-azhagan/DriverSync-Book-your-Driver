import SwiftUI

struct DriverProfileView: View {
    let driverID: Int

    @State private var driverInfo: DriverInfo?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Image("Loginbackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            if isLoading {
                ProgressView("Loading...")
            } else if let driver = driverInfo {
                VStack(spacing: 20) {
                    if let url = URL(string: "\(ServiceAPI.baseURL)\(driver.imagePath)") {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 5)
                    }

                    DriverInfoField(title: "Name", value: driver.name)
                    DriverInfoField(title: "Username", value: driver.username)

                    Spacer()
                }
                .padding()
            } else if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            fetchDriverProfile()
        }
    }

    private func fetchDriverProfile() {
        let formData: [String: Any] = ["driver_id": driverID]

        APIHandler.shared.postAPIValues(
            type: DriverProfileResponse.self,
            apiUrl: ServiceAPI.fetchdriverprofile,
            method: "POST",
            formData: formData
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    if response.status, let driver = response.driver {
                        self.driverInfo = driver
                    } else {
                        self.errorMessage = response.message
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct DriverInfoField: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text("\(title):")
                .bold()
                .foregroundColor(.black)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}
