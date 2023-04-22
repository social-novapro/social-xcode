//
//  API_Requests.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import Foundation


class API_Rquests {
    var userTokenManager = UserTokenHandler()
    var userTokens:UserTokenData?
    
    let baseAPIurl = "https://interact-api.novapro.net/v1";
//    let baseAPIurl = "http://localhost:5002/v1";

    let appToken = "token"
    let devToken = "token"
    
    init() {
        userTokens = userTokenManager.getUserTokens()
        print("userTokens: init API_Request")
    }
    
    func getDataFromAPI(route: String, bodyData: Any, completion: @escaping (Result<Data, Error>) -> Void) {
        let url = URL(string: baseAPIurl + route)!
        var request = URLRequest(url: url)
        request.addValue("Bearer YOUR_ACCESS_TOKEN_HERE", forHTTPHeaderField: "Authorization")
                
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "com.example.error", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }

    func userLoginRequest(userLogin: UserLoginData, completion: @escaping (Result<UserLoginResponse, Error>) -> Void) {
        let url = URL(string: baseAPIurl + "/auth/userLogin")!
        var request = URLRequest(url: url)
        
        request.addValue(appToken, forHTTPHeaderField: "apptoken")
        request.addValue(devToken, forHTTPHeaderField: "devtoken")
                
        request.addValue(userLogin.username, forHTTPHeaderField: "username")
        request.addValue(userLogin.password, forHTTPHeaderField: "password")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print ("ERROR ")
                print(error)
                // Handle error here
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                // Handle non-2xx status code here
                do {
                    let error = try JSONDecoder().decode(ErrorDataWithAuth.self, from: data!)
                    print("API error: \(error.error.msg), code: \(error.error.code)")
                } catch {
                    print("Error decoding API error: \(error.localizedDescription)")
                }
                print ("NOT 2XX result ")
                print (response!)
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "com.example.error", code: 0, userInfo: nil)))
                print ("data=data line ")

                return
            }
            do {
                let decoder = JSONDecoder()
                let dataModel = try decoder.decode(UserLoginResponse.self, from: data)
                print ("Data is valid, userLoginRquest")
                  completion(.success(dataModel))
              } catch {
                  completion(.failure(error))
              }
        }
        
        task.resume()
    }

    func getAllPosts(userTokens: UserTokenData, completion: @escaping (Result<[AllPosts], Error>) -> Void) {
        let url = URL(string: baseAPIurl + "/get/AllPosts")!
        var request = URLRequest(url: url)
        
        request.addValue(appToken, forHTTPHeaderField: "apptoken")
        request.addValue(devToken, forHTTPHeaderField: "devtoken")
        request.addValue(userTokens.accessToken, forHTTPHeaderField: "accesstoken")
        request.addValue(userTokens.userToken, forHTTPHeaderField: "usertoken")

        request.addValue(userTokens.userID, forHTTPHeaderField: "userid")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print ("ERROR ")
                print(error)
                // Handle error here
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print(response!)
                print(data!)
                do {
                    let error = try JSONDecoder().decode(ErrorDataWithAuth.self, from: data!)
                    print("API error: \(error.error.msg), code: \(error.error.code)")
                } catch {
                    print("Error decoding API error: \(error.localizedDescription)")
                }
                print ("NOT 2XX result ")

                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "com.example.error", code: 0, userInfo: nil)))
                print ("data=data line ")

                return
            }
            do {
                let decoder = JSONDecoder()
                let dataModel = try decoder.decode([AllPosts].self, from: data)
                print ("Data is valid, getAllPosts")
                completion(.success(dataModel.reversed()))
              } catch {
                completion(.failure(error))
              }
        }
        
        task.resume()
    }
    
    func handleError() {
        
    }
    func getUserData(userID: String?, completion: @escaping (Result<UserData, Error>) -> Void) {
        if ((userID == nil)) {
            return 
        }
        
        let url = URL(string: baseAPIurl + "/get/userByID/\(userID!)")!
        var request = URLRequest(url: url)
                
        request.addValue(appToken, forHTTPHeaderField: "apptoken")
        request.addValue(devToken, forHTTPHeaderField: "devtoken")
        request.addValue(self.userTokens!.accessToken, forHTTPHeaderField: "accesstoken")
        request.addValue(self.userTokens!.userToken, forHTTPHeaderField: "usertoken")
        request.addValue(self.userTokens!.userID, forHTTPHeaderField: "userid")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print ("ERROR ")
                print(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print(response!)
                print(data!)
                do {
                    let error = try JSONDecoder().decode(ErrorDataWithAuth.self, from: data!)
                    print("API error: \(error.error.msg), code: \(error.error.code)")
                } catch {
                    print("Error decoding API error: \(error.localizedDescription)")
                }
                print ("NOT 2XX result ")

                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "com.example.error", code: 0, userInfo: nil)))
                print ("data=data line ")

                return
            }
            do {
                let decoder = JSONDecoder()
                let dataModel = try decoder.decode(UserData.self, from: data)
                print ("Data is valid, getUserData")
                completion(.success(dataModel))
              } catch {
                completion(.failure(error))
              }
        }
        
        task.resume()
    }
}
