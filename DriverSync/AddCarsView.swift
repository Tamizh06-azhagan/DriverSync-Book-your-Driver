import SwiftUI
import PhotosUI

struct CarUploadResponse: Codable {
    let status: Bool
    let message: String
    let image_url: String?
}

struct AddCarsView: View {
    @Environment(\.dismiss) var dismiss
    let userid: Int

    @State private var carName = ""
    @State private var condition = ""
    @State private var contact = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isUploading = false
    @State private var uploadMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Image("Loginbackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 30)

                        // Image Picker
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            ZStack {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(height: 180)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.4))
                                    )

                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 180)
                                        .cornerRadius(12)
                                        .clipped()
                                } else {
                                    VStack(spacing: 6) {
                                        Image(systemName: "car.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.gray)
                                        Text("Tap to select car image")
                                            .foregroundColor(.gray)
                                            .font(.footnote)
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    selectedImage = uiImage
                                }
                            }
                        }

                        // Text Fields
                        formField(placeholder: "Car Name", text: $carName)
                        formField(placeholder: "Car Condition", text: $condition)
                        formField(placeholder: "Contact Number", text: $contact, keyboardType: .numberPad)

                        // Submit Button
                        Button(action: {
                            uploadCar()
                        }) {
                            if isUploading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Submit")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 10)

                        if !uploadMessage.isEmpty {
                            Text(uploadMessage)
                                .foregroundColor(.green)
                                .font(.subheadline)
                                .padding(.top, 10)
                        }
                    }
                }
            }
            .navigationTitle("Add Your Car")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func formField(placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: text)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .padding(.horizontal, 40)
            .keyboardType(keyboardType)
            .foregroundColor(.black)
    }

    // MARK: - Upload Handler
    func uploadCar() {
        guard let image = selectedImage else {
            uploadMessage = "Please select an image."
            return
        }

        isUploading = true
        uploadMessage = ""

        if let url = URL(string: ServiceAPI.addcars) {
            APIHandler.shared.uploadImageWithFormData(
                apiUrl: url,
                image: image,
                parameters: [
                    "userid": "\(userid)",
                    "car_name": carName,
                    "condition": condition
                ]
            ) { result in
                DispatchQueue.main.async {
                    isUploading = false
                    switch result {
                    case .success(let response):
                        if let status = response["status"] as? Bool,
                           let message = response["message"] as? String {
                            uploadMessage = message
                            if status {
                                dismiss()
                            }
                        } else {
                            uploadMessage = "Unexpected response format."
                        }

                    case .failure(let error):
                        uploadMessage = "Upload failed: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

#Preview {
    AddCarsView(userid: 1)
}
