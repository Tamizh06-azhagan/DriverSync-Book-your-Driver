//
//  ServiceApi.swift
//  Match Makeover
//
//  Created by SAIL on 18/06/25.
//

import UIKit

struct ServiceAPI {
    
   // static let baseURL = "http://180.235.121.245/driver_sync_api/"
   static let baseURL = "http://localhost/Driver/"

    static let login = baseURL+"userlogin.php"
    static let signup = baseURL+"signup.php"
    static let driverinfo = baseURL+"driverinfo.php"
    static let price = baseURL+"price.php"
    static let fetchCars = baseURL + "fetchcars.php"
    static let fetchuserprofile = baseURL + "fetchprofile.php"
    static let driveravailability = baseURL + "insertavailability.php"
    // For User Dashboard - to fetch drivers available for a selected date
    static let userAvailability = baseURL + "touchavailability.php"
    static let getdriver = baseURL + "touchavailability.php"
    static let insertbooking = baseURL + "insertbookingdetails.php"
    static let fetchbooking = baseURL + "fetch_booking_details.php"
    static let fetchbookings = baseURL + "bookindetails.php"

    static let addcars = baseURL + "cars.php"
    static let updateBookingStatus = baseURL + "update_booking_status.php"
    static let fetchBookingStatus = baseURL + "bookindetails.php"
    static let fetchdriverprofile = baseURL + "fetchdriverprofile.php"
  
    
   
}

