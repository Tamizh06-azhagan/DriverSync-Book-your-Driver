import SwiftUI

// MARK: - Models
struct Login: Codable {
    let status: String
    let message: String
    let data: DataClass
}

struct DataClass: Codable {
    let id, name, username, role, email: String
}

// MARK: - LoginView
struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isLoading = false
    @State private var navigateToNextPage = false
    @State private var navigateToSignup = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var isPressed = false
    @State private var loggedInUserID: Int?
    @State private var loggedInUserRole: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Image("Loginbackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()

                    // Logo & Heading
                    VStack(spacing: 10) {
                        Image("LoginLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)

                        Text("Get Started")
                            .font(.title2.bold())
                            .foregroundColor(.black)
                    }

                    // Username Field
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.black)

                        ZStack(alignment: .leading) {
                            if username.isEmpty {
                                Text("Enter Username").foregroundColor(.gray)
                            }
                            TextField("", text: $username)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)

                    // Password Field
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.black)

                        ZStack(alignment: .leading) {
                            if password.isEmpty {
                                Text("Enter Password").foregroundColor(.gray)
                            }

                            Group {
                                if isPasswordVisible {
                                    TextField("", text: $password)
                                } else {
                                    SecureField("", text: $password)
                                }
                            }
                            .foregroundColor(.black)
                        }

                        Button {
                            isPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)

                    // Login Button or Spinner
                    if isLoading {
                        ProgressView().padding()
                    } else {
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            isPressed = true
                            login()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isPressed = false
                            }
                        }) {
                            Text("Login")
                                .frame(width: 150, height: 20)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .scaleEffect(isPressed ? 0.95 : 1.0)
                                .animation(.easeOut(duration: 0.2), value: isPressed)
                        }
                        .padding(.top, 10)
                    }

                    // Are you new? Sign Up
                    HStack(spacing: 4) {
                        Text("Are you new?")
                            .foregroundColor(.black)

                        Button {
                            navigateToSignup = true
                        } label: {
                            Text("Create Account")
                                .foregroundColor(.blue)
                                
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.top, 5)

                    Spacer()
                }
            }
            .alert("Login", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }

            // Navigate to User/Driver View
            .navigationDestination(isPresented: $navigateToNextPage) {
                if let id = loggedInUserID, let role = loggedInUserRole {
                    if role == "user" {
                        UserPageView(userID: id)
                    } else if role == "driver" {
                        DriverPageView(driverID: id)
                    } else {
                        Text("Unknown role: \(role)")
                    }
                } else {
                    Text("Invalid user data")
                }
            }

            // Navigate to SignUp
            .navigationDestination(isPresented: $navigateToSignup) {
                SignUpView()
            }
        }
    }

    // MARK: - Login Function
    func login() {
        guard !username.isEmpty, !password.isEmpty else {
            alertMessage = "Please enter username and password."
            showAlert = true
            return
        }

        let params = [
            "username": username,
            "password": password
        ]

        isLoading = true

        APIHandler.shared.postAPIValues(
            type: Login.self,
            apiUrl: ServiceAPI.login,
            method: "POST",
            formData: params
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let loginResponse):
                    if loginResponse.status.lowercased() == "success" {
                        alertMessage = loginResponse.message
                        loggedInUserID = Int(loginResponse.data.id)
                        loggedInUserRole = loginResponse.data.role.lowercased()

                        UserDefaults.standard.set(loggedInUserRole, forKey: "user_role")
                        navigateToNextPage = true
                    } else {
                        alertMessage = loginResponse.message
                        loggedInUserID = nil
                        loggedInUserRole = nil
                        showAlert = true
                    }

                case .failure(let error):
                    alertMessage = "Login failed: \(error.localizedDescription)"
                    loggedInUserID = nil
                    loggedInUserRole = nil
                    showAlert = true
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LoginView()
}
