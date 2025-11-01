import SwiftUI
import PhotosUI

// MARK: - Signup Response Model
struct SignupResponse: Codable {
    let status: Bool
    let message: String
    let id: Int?
}

struct SignUpView: View {
    @State private var name = ""
    @State private var username = ""
    @State private var email = ""
    @State private var contact = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var selectedRole = "User"
    let roles = ["User", "Driver"]

    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var userRole: String? = nil
    @State private var navigateToUserPage = false
    @State private var navigateToDriverField = false
    @State private var signedUpUserID: Int? = nil // ✅ NEW

    var body: some View {
        NavigationStack {
            ZStack {
                Image("Loginbackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()

                    ZStack(alignment: .bottomTrailing) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 100, height: 100)
                        }
                        Button(action: { showImagePicker = true }) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.black)
                        }
                    }

                    Picker("User Type", selection: $selectedRole) {
                        ForEach(roles, id: \.self) { Text($0) }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(.white)
                    .cornerRadius(12)
                    .frame(width: 200)

                    customField(icon: "person.fill", placeholder: "Name", text: $name)
                    customField(icon: "person", placeholder: "Username", text: $username)
                    customField(icon: "envelope.fill", placeholder: "Email", text: $email)
                    customField(icon: "phone", placeholder: "Contact", text: $contact)
                    passwordField()

                    Button("SIGNUP") {
                        signup()
                    }
                    .padding()
                    .frame(width: 200)
                    .background(.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    Spacer()
                }
                .padding()
            }

            // ✅ FIXED: Pass userID after signup
            .navigationDestination(isPresented: $navigateToUserPage) {
                if let id = signedUpUserID {
                    UserPageView(userID: id)
                } else {
                    Text("User ID missing.")
                }
            }

            .navigationDestination(isPresented: $navigateToDriverField) {
                DriverFieldView(driverID: signedUpUserID ?? 0)
            }

            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }

            .commonAlert(isPresented: $showAlert, title: "Signup", message: alertMessage)

            .onChange(of: showAlert) { isPresented in
                if !isPresented, let role = userRole {
                    if role == "user" {
                        navigateToUserPage = true
                    } else if role == "driver" {
                        navigateToDriverField = true
                    }
                }
            }
        }
    }

    func signup() {
        guard let selectedImage = selectedImage else {
            alertMessage = "Please select an image"
            showAlert = true
            return
        }

        guard let url = URL(string: ServiceAPI.signup) else {
            alertMessage = "Invalid signup URL"
            showAlert = true
            return
        }

        let body: [String: Any] = [
            "name": name,
            "username": username,
            "email": email,
            "password": password,
            "role": selectedRole,
            "contact_number": contact,
            "image": selectedImage
        ]

        APIHandler.shared.PostUIImageToAPI(apiUrl: url, id: username, requestBody: body) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    if let dict = json as? [String: Any],
                       let status = dict["status"] as? Bool,
                       let message = dict["message"] as? String {
                        alertMessage = message
                        userRole = status ? selectedRole.lowercased() : nil
                        signedUpUserID = dict["id"] as? Int // ✅ Store ID for navigation
                        showAlert = true
                    } else {
                        alertMessage = "Unexpected response"
                        showAlert = true
                    }

                case .failure:
                    alertMessage = "Signup failed"
                    showAlert = true
                }
            }
        }
    }

    func customField(icon: String, placeholder: String, text: Binding<String>, isSecure: Bool = false) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(.black)
            if isSecure {
                SecureField(placeholder, text: text)
            } else {
                TextField(placeholder, text: text)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(12)
        .frame(width: 300)
    }

    func passwordField() -> some View {
        HStack {
            Image(systemName: "lock.fill").foregroundColor(.black)
            Group {
                if isPasswordVisible {
                    TextField("Password", text: $password)
                } else {
                    SecureField("Password", text: $password)
                }
            }
            .foregroundColor(.black)

            Button(action: {
                isPasswordVisible.toggle()
            }) {
                Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(12)
        .frame(width: 300)
    }
}

#Preview {
    SignUpView()
}
