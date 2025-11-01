import Foundation
import UIKit

struct Driver: Identifiable, Codable {
    let id: String
    let name: String
    let contact: String
    let availableDate: String
    let imagePath: String // ✅ This is what you are missing

    enum CodingKeys: String, CodingKey {
        case id, name, contact
        case availableDate = "available_date"
        case imagePath = "image_path"
    }
}

struct BookingStatusUser: Codable {
    let status: Bool
    let message: String
    let data: [BookingStatusData]
}

// MARK: - Datum
struct BookingStatusData: Codable {
    let bookingID: Int
    let date: String
    let pickupAddress, destinationAddress: String?
    let driverName: String
    let status: Status

    enum CodingKeys: String, CodingKey {
        case bookingID = "booking_id"
        case date
        case pickupAddress = "pickup_address"
        case destinationAddress = "destination_address"
        case driverName = "driver_name"
        case status
    }
}

enum Status: String, Codable {
    case accepted = "accepted"
    case pending = "pending"
    case rejected = "rejected"
}



//enum BookingStatus: String, Decodable {
//    case accepted = "Accepted"
//    case rejected = "Rejected"
//    case pending = "Pending"
//}

//struct CarResponse: Codable {
//    let status: Bool
//    let data: [Car]
//}
//struct CarDetailResponse: Codable {
//    let status: Bool
//    let data: Car
//}
//struct Car: Identifiable, Codable {
//    let id: String
//    let carName: String
//    let imagePath: String
//    let condition: String
//    let driverName: String
//    let contactNumber: String
//    let age: String? // Add this line
//    let experienceYears: String? // Add this if needed
//
//    enum CodingKeys: String, CodingKey {
//        case id = "car_id"
//        case carName = "car_name"
//        case imagePath = "image_path"
//        case condition
//        case driverName = "driver_name"
//        case contactNumber = "contact_number"
//        case age
//        case experienceYears = "experienceyears"
//    }
//
//    var imageURL: String {
//        return "http://180.235.121.245/driver_sync_api/\(imagePath)"
//    }
//}
struct PriceDetail: Decodable {
    let origin: String
    let destination: String
    let days: String
    let amount: String
}

struct AppUser: Identifiable, Decodable {
    let id: String
    let name: String
    let username: String
    let contact: String
  
    let bookingDate: String
    let origin: String
    let destination: String
}



//struct Login: Codable {
//    let status, message: String
//    let data: DataClass
//}
//struct DataClass: Codable {
//    let id, name, username, role: String
//    let email: String
//}

struct PriceResponse: Codable {
    let status: Bool
    let message: String
    let origin: String
    let destination: String
    let days: Int
    let pricePerDay: String
    let totalAmount: Int

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case origin
        case destination
        case days
        case pricePerDay = "price_per_day"
        case totalAmount = "total_amount"
    }
}


// MARK: - Profile Data Model
struct UserProfileData: Codable {
    let name: String
    let username: String
    let image_path: String?  // ✅ Include image_path here since it comes from the same response
}

// MARK: - API Response Model
struct ProfileResponses: Codable {
    let status: Bool
    let message: String
    let data: UserProfileData?
}


struct TouchAvailabilityResponse: Codable {
    let status: Bool
    let message: String
    let date: String
    let total_drivers: Int
    let drivers: [TouchDriver]
}

struct TouchDriver: Codable, Identifiable {
    var id: Int { availabilityID }
    let availabilityID: Int
    let driverID: Int
    let driverName: String
    let driverEmail: String
    let driverContact: Int
    let availabilityStatus: String
    let availabilityDate: String

    enum CodingKeys: String, CodingKey {
        case availabilityID = "availability_id"
        case driverID = "driver_id"
        case driverName = "driver_name"
        case driverEmail = "driver_email"
        case driverContact = "driver_contact"
        case availabilityStatus = "availability_status"
        case availabilityDate = "availability_date"
    }
}


struct GetDriver: Codable {
    let status: Bool
    let message, date: String
    let totalDrivers: Int
    let drivers: [GetDriverData]

    enum CodingKeys: String, CodingKey {
        case status, message, date
        case totalDrivers = "total_drivers"
        case drivers
    }
}

// MARK: - Driver
struct GetDriverData: Codable {
    let availabilityID, driverID: Int
    let driverName, driverEmail, driverContact, availabilityStatus: String
    let availabilityDate: String

    enum CodingKeys: String, CodingKey {
        case availabilityID = "availability_id"
        case driverID = "driver_id"
        case driverName = "driver_name"
        case driverEmail = "driver_email"
        case driverContact = "driver_contact"
        case availabilityStatus = "availability_status"
        case availabilityDate = "availability_date"
    }
}
struct DriverProfileResponse: Codable {
    let status: Bool
    let message: String
    let driver: DriverInfo?
}

struct DriverInfo: Codable {
    let name: String
    let username: String
    let imagePath: String

    enum CodingKeys: String, CodingKey {
        case name, username
        case imagePath = "image_path"
    }
}
struct Car: Identifiable, Codable {
    let id: Int
    let userID: Int
    let carName: String
    let imageURL: String
    let condition: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "userid"
        case carName = "car_name"
        case imageURL = "image_path"
        case condition
    }
}


struct Welcome: Codable {
    let status: String
    let data: [Datum]
}

// MARK: - Datum
struct Datum: Codable {
    let id, userid: Int
    let carName, imagePath, condition: String

    enum CodingKeys: String, CodingKey {
        case id, userid
        case carName = "car_name"
        case imagePath = "image_path"
        case condition
    }
}




// MARK: - Us
// MARK: - Us
