//
//  API_Helper.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-19.
//

import Foundation
//import Combine/

class API_Helper {
    var userTokenManager = UserTokenHandler()
    var apiData = API_Data()
    var userTokens:UserTokenData
    
    var baseAPIurl:String = "https://interact-api.novapro.net/v1"

    var appToken:String
    var devToken:String

    init(userTokensProv: UserTokenData) {
        self.userTokens = userTokensProv
        self.baseAPIurl = apiData.getURL()
        self.appToken = apiData.getAppToken()
        self.devToken = apiData.getDevToken()
        print ("dev \(devToken), app \(appToken), env \(baseAPIurl)")
        print("userTokens: init API_Helper")
    }
    
    func decodeData() {
        
    }
    
    func asyncRequestDataBody<T: Codable, B: Encodable>(
        urlString: String,
        errorType: String = "normal",
        httpHeaders: [ApiHeader]=[],
        httpMethod: String = "GET",
        httpBody: B
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
        let (data, response) = try await URLSession.shared.data(for: request)
           
        // Check HTTP status code
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw ErrorData(code: "Z001", msg: "Invalid response status", error: true)
        }
           
        // Decode the response
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            print("Error: \(error)")
            throw ErrorData(code: "Z001", msg: "Failed to decode response", error: true)
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
