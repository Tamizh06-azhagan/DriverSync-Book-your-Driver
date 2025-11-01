//
//  DriverRowView.swift
//  DriverSync
//
//  Created by SAIL on 10/06/25.
//

import SwiftUI

struct DriverRowView: View {
    let driver: Driver

    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.black)
                .padding(.trailing, 10)

            Text(driver.name)
                .font(.headline)
                .foregroundColor(.black)

            Spacer()

            Button("Book Now") {
                print("Booked \(driver.name)")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

#Preview {
    DriverRowView(driver: Driver(
        id: "1",
        name: "name",
        contact: "1234567890",
        availableDate: "2025-06-07",
        imagePath: "https://yourserver.com/images/driver1.jpg" // sample image path
    ))
    .previewLayout(.sizeThatFits)
    .padding()
    .background(Color.gray.opacity(0.1))
}
