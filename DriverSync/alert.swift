//
//  alert.swift
//  DriverSync
//
//  Created by SAIL on 18/06/25.
//



import SwiftUI

struct CommonAlert: ViewModifier {
    @Binding var isPresented: Bool
    var title: String
    var message: String

    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isPresented) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(message)
            }
    }
}
extension View {
    func commonAlert(isPresented: Binding<Bool>, title: String, message: String) -> some View {
        self.modifier(CommonAlert(isPresented: isPresented, title: title, message: message))
    }
}
class Manager {
    
    static let shared = Manager()
    
    init() {
        
    }
    var driverID:Int = 0
}
