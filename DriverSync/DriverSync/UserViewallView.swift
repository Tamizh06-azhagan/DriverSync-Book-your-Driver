import SwiftUI

struct UserViewallView: View {
    let drivers: [TouchDriver]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Image("Loginbackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                
                // Back Button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                            .padding()
                    }
                    Spacer()
                }
                
                // Title
                Text("Available Drivers")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Driver List
                if drivers.isEmpty {
                    Text("No drivers available")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(drivers) { driver in
                                HStack(spacing: 16) {
                                    // Remove AsyncImage entirely
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(driver.driverName)
                                            .font(.headline)
                                        Text("Date: \(driver.availabilityDate)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("Contact: \(driver.driverContact)")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }

                                    Spacer()
                                }
                                .padding()
                                .background(.ultraThickMaterial)
                                .cornerRadius(15)
                                .shadow(radius: 3)
                                .padding(.horizontal)
                            }

                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}
