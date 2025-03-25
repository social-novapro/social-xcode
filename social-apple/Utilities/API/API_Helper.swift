//
//  API_Helper.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-19.
//

import Foundation
//import Combine/

class API_Helper: ObservableObject {
    var userTokenManager = UserTokenHandler()
    var apiData = API_Data()
    var userTokens:UserTokenData
    
    var baseAPIurl:String = "https://interact-api.novapro.net/v1"
    
    var appToken:String
    var devToken:String
    
    @Published var errorShow:Bool = false
    @Published var errorFound:ErrorData = ErrorData(code: "Z003", msg: "None", error: false)
    var errorTime:Date = Date()
    
    init(userTokensProv: UserTokenData) {
        self.userTokens = userTokensProv
        self.baseAPIurl = apiData.getURL()
        self.appToken = apiData.getAppToken()
        self.devToken = apiData.getDevToken()
        print ("dev \(devToken), app \(appToken), env \(baseAPIurl)")
        print("userTokens: init API_Helper")
        
    }
    
    func provideError(error: ErrorData) {
        DispatchQueue.main.async {
            print("error providing")
            self.errorShow = true
            self.errorFound = error
            self.errorTime = Date()
        }
        /*
         DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
         self.errorShow = false
         }
         */
    }
    
    func dismissError() {
        DispatchQueue.main.async {
            print("error dismising")
            self.errorShow = false
            self.errorFound = ErrorData(code: "Z000", msg: "None", error: false)
        }
    }
    
    func decodeData() {
        
    }
    
    func asyncRequestData<T: Decodable> (
        urlString: String,
        errorType: String = "normal",
        httpHeaders: [ApiHeader]=[],
        httpMethod: String = "GET"
    ) async throws -> T {
        //create the new url
        let url = URL(string: urlString)
        
        //create a new urlRequest passing the url
        var request = URLRequest(url: url!)
        request.httpMethod = httpMethod
        
        // headers
        request.addValue(appToken, forHTTPHeaderField: "apptoken")
        request.addValue(devToken, forHTTPHeaderField: "devtoken")
        request.addValue(self.userTokens.accessToken, forHTTPHeaderField: "accesstoken")
        request.addValue(self.userTokens.userToken, forHTTPHeaderField: "usertoken")
        request.addValue(self.userTokens.userID, forHTTPHeaderField: "userid")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        for header in httpHeaders {
            request.addValue(header.value, forHTTPHeaderField: header.field)
        }
        
        //        provideError(error: ErrorData(code: "Z005", msg: "This is a test", error: true))
        
        // Execute the request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ErrorData(code: "Z003", msg: "Invalid response", error: true)
            }
            
            if 200..<300 ~= httpResponse.statusCode {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                return decodedData
            } else {
                // Log the raw error response for debugging
                if let errorString = String(data: data, encoding: .utf8) {
                    print("Error response string: \(errorString)")
                }
                
                // Decode the error response
                let errorData = try JSONDecoder().decode(ErrorData.self, from: data)
                provideError(error: errorData)
                throw errorData
            }
        } catch {
            throw error
        }
    }
    
    func asyncRequestFileUpload<T: Decodable>(
        urlString: String,
        fileURL: URL,
        fileFieldName: String = "file",
        errorType: String = "normal",
        httpHeaders: [ApiHeader] = [],
        httpMethod: String = "POST"
    ) async throws -> T {
        // Create the new URL
        guard let url = URL(string: urlString) else {
            throw ErrorData(code: "Z001", msg: "Invalid URL", error: true)
        }

        // Generate a unique boundary
        let boundary = UUID().uuidString

        // Create the URLRequest and set the HTTP method
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod

        // Headers
        request.addValue(appToken, forHTTPHeaderField: "apptoken")
        request.addValue(devToken, forHTTPHeaderField: "devtoken")
        request.addValue(self.userTokens.accessToken, forHTTPHeaderField: "accesstoken")
        request.addValue(self.userTokens.userToken, forHTTPHeaderField: "usertoken")
        request.addValue(self.userTokens.userID, forHTTPHeaderField: "userid")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Add custom headers
        for header in httpHeaders {
            request.addValue(header.value, forHTTPHeaderField: header.field)
        }

        // Prepare multipart form data
        var body = Data()
        let lineBreak = "\r\n"

        do {
            // Try to read the file data
            let fileData = try Data(contentsOf: fileURL)
            
            // Append the file data to the request body
            body.append("--\(boundary)\(lineBreak)".data(using: .utf8)!) // Boundary header
            body.append("Content-Disposition: form-data; name=\"\(fileFieldName)\"; filename=\"\(fileURL.lastPathComponent)\"\(lineBreak)".data(using: .utf8)!)
            body.append("Content-Type: application/octet-stream\(lineBreak)\(lineBreak)".data(using: .utf8)!)
            body.append(fileData) // Append the actual file data
            body.append(lineBreak.data(using: .utf8)!) // Add line break after file data

            // Close the boundary properly
            body.append("--\(boundary)--\(lineBreak)".data(using: .utf8)!)
        } catch {
            throw ErrorData(code: "Z002", msg: "File error: \(error.localizedDescription)", error: true)
        }

        // Set the body
        request.httpBody = body

        // Add content-length header (optional, but can help with some servers)
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")

        // Execute the request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ErrorData(code: "Z003", msg: "Invalid response", error: true)
            }

            if 200..<300 ~= httpResponse.statusCode {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                return decodedData
            } else {
                // Log the raw error response for debugging
                if let errorString = String(data: data, encoding: .utf8) {
                    print("Error response string: \(errorString)")
                }

                // Decode the error response
                let errorData = try JSONDecoder().decode(ErrorData.self, from: data)
                provideError(error: errorData)
                throw errorData
            }
        } catch {
            throw error
        }
    }


    
    func asyncRequestDataKeyMap<T: Codable>(
        urlString: String,
        errorType: String = "normal",
        httpHeaders: [ApiHeader]=[],
        httpMethod: String = "GET",
        httpKeyMap: [HttpReqKeyValue] = []
    ) async throws -> T {
        //create the new url
        let url = URL(string: urlString)
        
        //create a new urlRequest passing the url
        var request = URLRequest(url: url!)
        request.httpMethod = httpMethod

        // headers
        request.addValue(appToken, forHTTPHeaderField: "apptoken")
        request.addValue(devToken, forHTTPHeaderField: "devtoken")
        request.addValue(self.userTokens.accessToken, forHTTPHeaderField: "accesstoken")
        request.addValue(self.userTokens.userToken, forHTTPHeaderField: "usertoken")
        request.addValue(self.userTokens.userID, forHTTPHeaderField: "userid")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        for header in httpHeaders {
            request.addValue(header.value, forHTTPHeaderField: header.field)
        }
        
        // Encode the body dynamically
        var keyMap: [String: Any] = [:]

        for data in httpKeyMap {
            keyMap[data.key] = data.value
        }
//        let bodyComponents = keyMap.map { key, value in
//            "\(key)=\(value)"
//        }

//        let bodyString = bodyComponents.joined(separator: "&")
//        request.httpBody = bodyString.data(using: .utf8)
        
        request.httpBody = try JSONSerialization.data(withJSONObject: keyMap, options: .prettyPrinted)

//        print(request.httpBody)

        
             
        // Execute the request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check HTTP status code
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ErrorData(code: "Z003", msg: "Invalid response", error: true)
            }

            if 200..<300 ~= httpResponse.statusCode {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                return decodedData
            } else {
                // Log the raw error response for debugging
                if let errorString = String(data: data, encoding: .utf8) {
                    print("Error response string: \(errorString)")
                }

                // Decode the error response
                let errorData = try JSONDecoder().decode(ErrorData.self, from: data)
                provideError(error: errorData)
                throw errorData
            }
        } catch {
            throw error
        }
    }
    
    func asyncRequestDataBody<T: Codable, B: Encodable>(
        urlString: String,
        errorType: String = "normal",
        httpHeaders: [ApiHeader]=[],
        httpMethod: String = "GET",
        httpBody: B?
    ) async throws -> T {
        //create the new url
        let url = URL(string: urlString)
        
        //create a new urlRequest passing the url
        var request = URLRequest(url: url!)
        request.httpMethod = httpMethod

        // headers
        request.addValue(appToken, forHTTPHeaderField: "apptoken")
        request.addValue(devToken, forHTTPHeaderField: "devtoken")
        request.addValue(self.userTokens.accessToken, forHTTPHeaderField: "accesstoken")
        request.addValue(self.userTokens.userToken, forHTTPHeaderField: "usertoken")
        request.addValue(self.userTokens.userID, forHTTPHeaderField: "userid")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        for header in httpHeaders {
            request.addValue(header.value, forHTTPHeaderField: header.field)
        }
        
        // encode body
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            request.httpBody = try encoder.encode(httpBody)
        } catch {
            throw ErrorData(code: "Z001", msg: "Uknown", error: true)
        }

        // Execute the request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check HTTP status code
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ErrorData(code: "Z003", msg: "Invalid response", error: true)
            }

            if 200..<300 ~= httpResponse.statusCode {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                return decodedData
            } else {
                // Log the raw error response for debugging
                if let errorString = String(data: data, encoding: .utf8) {
                    print("Error response string: \(errorString)")
                }

                // Decode the error response
                let errorData = try JSONDecoder().decode(ErrorData.self, from: data)
                provideError(error: errorData)
                throw errorData
            }
        } catch {
            throw error
        }
    }
    
    func requestDataWithBody<T: Decodable, B: Encodable>(
        urlString: String,
        errorType: String = "normal",
        httpHeaders: [ApiHeader]=[],
        httpMethod: String = "GET",
        httpBody: B,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "com.example.error", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod

        request.addValue(appToken, forHTTPHeaderField: "apptoken")
        request.addValue(devToken, forHTTPHeaderField: "devtoken")
        request.addValue(self.userTokens.accessToken, forHTTPHeaderField: "accesstoken")
        request.addValue(self.userTokens.userToken, forHTTPHeaderField: "usertoken")
        request.addValue(self.userTokens.userID, forHTTPHeaderField: "userid")
        
        for header in httpHeaders {
            request.addValue(header.value, forHTTPHeaderField: header.field)
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            request.httpBody = try encoder.encode(httpBody)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
        } catch {
            completion(.failure(error))
            return
        }
        
        taskRequest(request: request, errorType: errorType) { (result: Result<T, Error>) in
            switch result {
            case .success(let apiData):
                print("Received api data")
                completion(.success(apiData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        
    }
        
    func requestData<T: Decodable>(
        urlString: String,
        errorType: String = "normal",
        httpHeaders: [ApiHeader]=[],
        httpMethod: String = "GET",
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "com.example.error", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod

        request.addValue(appToken, forHTTPHeaderField: "apptoken")
        request.addValue(devToken, forHTTPHeaderField: "devtoken")
        request.addValue(self.userTokens.accessToken, forHTTPHeaderField: "accesstoken")
        request.addValue(self.userTokens.userToken, forHTTPHeaderField: "usertoken")
        request.addValue(self.userTokens.userID, forHTTPHeaderField: "userid")
        
        for header in httpHeaders {
            print("adding header \(header)")
            request.addValue(header.value, forHTTPHeaderField: header.field)
        }
        
        taskRequest(request: request, errorType: errorType) { (result: Result<T, Error>) in
            switch result {
            case .success(let apiData):
                print("Received api data")
                completion(.success(apiData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func taskRequest<T: Decodable>(
        request: URLRequest,
        errorType: String,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("ERROR")
                print(error)
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                do {
                    switch errorType {
                    case "normal":
                        let error = try JSONDecoder().decode(ErrorData.self, from: data!)
                        print("API error: \(error.msg), code: \(error.code)")
                    case "withAuth":
                        let error = try JSONDecoder().decode(ErrorDataWithAuth.self, from: data!)
                        print("API error: \(error.error.msg), code: \(error.error.code)")
                    default:
                        print("Invalid errorType")
                        completion(.failure(NSError(domain: "com.example.error", code: 0, userInfo: nil)))
                        
                    }
                } catch {
                    print("Error decoding API error: \(error.localizedDescription)")
                }
                
                print("NOT 2XX result ")
                print(response!)
                return
            }
            
            guard let data = data else {
                print("Data is nil")
                completion(.failure(NSError(domain: "com.example.error", code: 0, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let dataModel = try decoder.decode(T.self, from: data)
                print("Data is valid")
                completion(.success(dataModel))
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
