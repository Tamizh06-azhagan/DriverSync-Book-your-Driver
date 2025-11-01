import SwiftUI

struct UserProfileView: View {
    let userID: Int

    @State private var name: String = ""
    @State private var username: String = ""
    @State private var imagePath: String? = nil
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil

    private let baseURL = "http://localhost/Driver/" // Update if needed

    var body: some View {
        ZStack {
            Image("Loginbackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            if isLoading {
                ProgressView("Loading...")
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                VStack(spacing: 20) {
                    // Profile Image
                    if let path = imagePath {
                        let fullPath = baseURL + path
                        if let encoded = fullPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                           let url = URL(string: encoded) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure(_):
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 5)
                        } else {
                            Text("Invalid image URL")
                                .foregroundColor(.red)
                        }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                    }

                    // Info Fields
                    UserInfoField(title: "Name", value: name)
                    UserInfoField(title: "Username", value: username)

                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            loadUserProfile()
        }
    }

    private func loadUserProfile() {
        isLoading = true
        errorMessage = nil

        let formData = ["id": "\(userID)"]

        APIHandler.shared.postAPIValues(
            type: ProfileResponse.self,
            apiUrl: ServiceAPI.fetchuserprofile,
            method: "POST",
            formData: formData
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    if response.status, let profile = response.data {
                        self.name = profile.name
                        self.username = profile.username
                        self.imagePath = profile.image_path
                    } else {
                        self.errorMessage = response.message
                    }
                case .failure(let error):
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct UserInfoField: View {
    var title: String
    var value: String

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

// MARK: - Profile Response Model
struct ProfileResponse: Codable {
    let status: Bool
    let message: String
    let data: UserProfile?
}

struct UserProfile: Codable {
    let name: String
    let username: String
    let image_path: String
}
