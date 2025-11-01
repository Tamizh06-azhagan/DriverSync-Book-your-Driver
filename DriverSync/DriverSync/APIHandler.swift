import Foundation
import UIKit

class APIHandler {
    static let shared = APIHandler()
    var dynamicId = ""

    private init() {}

    // MARK: - GET API
    func getAPIValues<T: Codable>(type: T.Type, apiUrl: String, method: String, onCompletion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: apiUrl) else {
            onCompletion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                onCompletion(.failure(error))
                return
            }

            guard let data = data else {
                onCompletion(.failure(NSError(domain: "No data received", code: 1)))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(type, from: data)
                onCompletion(.success(decodedData))
            } catch {
                onCompletion(.failure(error))
            }
        }.resume()
    }

    // MARK: - POST API (Form-Encoded)
    func postAPIValues<T: Codable>(
        type: T.Type,
        apiUrl: String,
        method: String,
        formData: [String: Any],
        onCompletion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: apiUrl) else {
            onCompletion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let formString = formData.map {
            "\($0.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")=\($0.value)"
        }.joined(separator: "&")

        request.httpBody = formString.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                onCompletion(.failure(error))
                return
            }

            guard let data = data else {
                onCompletion(.failure(NSError(domain: "No data", code: 1)))
                return
            }

            print("Response: \(String(data: data, encoding: .utf8) ?? "nil")")

            do {
                let decodedData = try JSONDecoder().decode(type, from: data)
                onCompletion(.success(decodedData))
            } catch {
                onCompletion(.failure(error))
            }
        }.resume()
    }

    // MARK: - POST API (Raw JSON)
    func postAPIRawJSON<T: Codable>(
        type: T.Type,
        apiUrl: String,
        method: String,
        jsonData: Data,
        onCompletion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: apiUrl) else {
            onCompletion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                onCompletion(.failure(error))
                return
            }

            guard let data = data else {
                onCompletion(.failure(NSError(domain: "No data", code: 1)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(type, from: data)
                onCompletion(.success(decoded))
            } catch {
                onCompletion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Upload Image API (Multipart)
    func PostUIImageToAPI(apiUrl: URL, id: String, requestBody: [String: Any], onCompletion: @escaping (Result<Any, Error>) -> Void) {
        let boundary = UUID().uuidString
        dynamicId = id

        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let body = createMultipartFormData(parameters: requestBody, boundary: boundary)
        request.httpBody = body

        let session = URLSession(configuration: .default)

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                onCompletion(.failure(error))
                return
            }

            guard let data = data else {
                onCompletion(.failure(NSError(domain: "Upload Error", code: -1)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
                print("Response Body: \(String(data: data, encoding: .utf8) ?? "nil")")
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    onCompletion(.success(jsonResponse))
                } catch {
                    onCompletion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Upload Image with Multipart Form Data
    func uploadImageWithFormData(
        apiUrl: URL,
        image: UIImage,
        parameters: [String: String],
        onCompletion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        let boundary = UUID().uuidString
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        let imageData = image.jpegData(compressionQuality: 0.7)!
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"car.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                onCompletion(.failure(error))
                return
            }

            guard let data = data else {
                onCompletion(.failure(NSError(domain: "No data", code: -1)))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    onCompletion(.success(json))
                } else {
                    onCompletion(.failure(NSError(domain: "Invalid JSON", code: -2)))
                }
            } catch {
                onCompletion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Multipart FormData Helper
    func createMultipartFormData(parameters: [String: Any], boundary: String) -> Data {
        var body = Data()

        for (key, value) in parameters {
            if let image = value as? UIImage, let imageData = image.jpegData(compressionQuality: 0.3) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(dynamicId)-\(key).jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            } else if let stringValue = value as? String {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append(stringValue.data(using: .utf8)!)
                body.append("\r\n".data(using: .utf8)!)
            }
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }

    // MARK: - Fetch Price
    func fetchPriceDetails(origin: String, destination: String, days: Int, completion: @escaping (Result<PriceResponse, Error>) -> Void) {
        guard let url = URL(string: ServiceAPI.price) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyParams = "origin=\(origin)&destination=\(destination)&days=\(days)"
        request.httpBody = bodyParams.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: 500)))
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(PriceResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decoded))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Car Struct Response
    struct CarResponse: Codable {
        let status: String
        let message: String?
        let data: [Car]?
    }

    func fetchCars(for userID: Int, completion: @escaping (Result<[Car], Error>) -> Void) {
        guard let url = URL(string: "http://localhost/Driver/fetchcars.php") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "userid=\(userID)"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned"])))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(CarResponse.self, from: data)
                if decoded.status.lowercased() == "success", let cars = decoded.data {
                    completion(.success(cars))
                } else {
                    let message = decoded.message ?? "Unknown error"
                    completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: message])))
                }
            } catch {
                print("Decoding error:", error)
                print("Raw JSON:", String(data: data, encoding: .utf8) ?? "nil")
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Fetch User Profile
    func fetchUserProfile(id: Int, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let url = URL(string: ServiceAPI.fetchuserprofile) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "id=\(id)".data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: 500)))
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(ProfileResponse.self, from: data)
                if decoded.status, let user = decoded.data {
                    DispatchQueue.main.async {
                        completion(.success(user))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: decoded.message ?? "Failed", code: 404)))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
