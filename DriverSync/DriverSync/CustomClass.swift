//
//  CustomClass.swift
//  DriverSync
//
//  Created by SAIL on 05/06/25.
//

import SwiftUI
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}


struct CustomImage: View {
    var name: String
    var width: CGFloat = 100
    var height: CGFloat = 100
    var cornerRadius: CGFloat = 10
    var isSystemImage: Bool = false

    var body: some View {
        Group {
            if isSystemImage {
                Image(systemName: name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: width, height: height)
        .cornerRadius(cornerRadius)
        .clipped()
    }
}



struct CustomButtonImage: View {
    var title: String
    var imageName: String // image from Assets
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(imageName) // This loads from Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)

                Text(title)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(12)
        }
    }
}



struct CustomText: View {
    var text: String
    var font: Font = .body
    var color: Color = .primary
    var weight: Font.Weight = .regular
    var backgroundColor: Color = .blue


    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(color)
            .fontWeight(weight)
            .background(backgroundColor)
    }
}



struct CustomButton: View {
    var title: String
    var action: () -> Void
    
    // Customizable properties
    var backgroundColor: Color = .blue
    var font: Font = .headline
    var cornerRadius: CGFloat = 12
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
                .shadow(radius: 5)
        }
    }
}
