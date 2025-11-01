//import Foundation
//// 👇 Required to use fetchUserProfile
//import SwiftUI
//
//class UserProfileViewModel: ObservableObject {
//    @Published var user: UserProfile? = nil
//    @Published var isLoading = false
//    @Published var errorMessage: String? = nil
//
//    func loadUserProfile(id: Int) {
//        isLoading = true
//        errorMessage = nil
//
//        fetchUserProfile(id: id) { result in
//            self.isLoading = false
//            switch result {
//            case .success(let profile):
//                self.user = profile
//            case .failure(let error):
//                self.errorMessage = error.localizedDescription
//            }
//        }
//    }
//}
