import SwiftUI

struct DriverFieldView: View {
    var driverID: Int  // This should come from login or signup response

    @State private var age = ""
    @State private var experience = ""
    @State private var contact = ""
    @State private var navigateToDriverPage = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Image("Loginbackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()

                    // Title
                    HStack(spacing: 10) {
                        Image(systemName: "doc.text.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)

                        Text("Fill to Continue")
                            .font(.title2)
                            .foregroundColor(.black)
                            .bold()
                    }

                    // Input fields
                    InputField(icon: "person.fill", placeholder: "Enter Age", text: $age, keyboard: .numberPad)
                    InputField(icon: "briefcase.fill", placeholder: "Enter Experience Year", text: $experience, keyboard: .numberPad)
                    InputField(icon: "phone.fill", placeholder: "Enter Contact Number", text: $contact, keyboard: .phonePad)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                    }

                    // Submit button
                    Button(action: {
                        if age.isEmpty || experience.isEmpty || contact.isEmpty {
                            errorMessage = "All fields are required."
                        } else {
                            errorMessage = ""
                            saveDriverInfo()
                        }
                    }) {
                        Text("Submit")
                            .frame(width: 150, height: 20)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }

                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationDestination(isPresented: $navigateToDriverPage) {
                DriverPageView(driverID: driverID)
            }
        }
    }

    // MARK: - Save Driver Info to PHP
    func saveDriverInfo() {
        print("Submitting driverID: \(driverID), age: \(age), experience: \(experience), contact: \(contact)")

        let form: [String: String] = [
            "userid": "\(driverID)",              // ✅ key matches PHP
            "age": age,
            "experience_years": experience,       // ✅ key matches PHP
            "contact_number": contact             // ✅ key matches PHP
        ]

        APIHandler.shared.postAPIValues(
            type: GenericAPIResponse.self,
            apiUrl: ServiceAPI.driverinfo,
            method: "POST",
            formData: form
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response) where response.status:
                    navigateToDriverPage = true
                case .success(let response):
                    errorMessage = response.message
                case .failure(let error):
                    errorMessage = "Network error: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Reusable Input Field View
struct InputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.black)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray)
                }
                TextField("", text: $text)
                    .keyboardType(keyboard)
                    .foregroundColor(.black)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal, 40)
    }
}

// MARK: - Generic API Response Model
struct GenericAPIResponse: Codable {
    let status: Bool
    let message: String
}

// MARK: - Preview
#Preview {
    DriverFieldView(driverID: 32)  // Replace with actual login ID
}
