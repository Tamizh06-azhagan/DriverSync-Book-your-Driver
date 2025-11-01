//
//  ContentView.swift
//  DriverSync
//
//  Created by SAIL on 05/06/25.
//
import SwiftUI

struct ContentView: View {
    @State private var showLogin = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 20) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showLogin = true
            }
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
        }
    }
}




#Preview {
    ContentView()
}
