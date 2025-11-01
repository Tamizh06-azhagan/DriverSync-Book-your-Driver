//
//  HintFieldView.swift
//  DriverSync
//
//  Created by SAIL on 17/06/25.
//



import SwiftUI

struct HintFieldView: View {
    var placeholder: String
    var systemIcon: String? = nil
    var isPhone: Bool = false
    var phoneNumber: String? = nil

    var body: some View {
        HStack {
            if let icon = systemIcon {
                Image(systemName: icon)
                    .foregroundColor(.black)
                    .padding(.leading, 12)
            }

            Text(placeholder)
                .foregroundColor(.gray)
                .padding(.leading, systemIcon == nil ? 16 : 4)

            Spacer()

            if isPhone, let number = phoneNumber {
                Button(action: {
                    if let url = URL(string: "tel://\(number)"),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                        .padding(.trailing, 12)
                }
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

#Preview {
    HintFieldView(
        placeholder: "Contact Number: 9876543210",
        systemIcon: "phone.fill",
        isPhone: true,
        phoneNumber: "9876543210"
    )
}

