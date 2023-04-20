//
//  API_Requests.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import Foundation


class API_Rquests {
    let baseAPIurl = "https://interact-api.novapro.net/v1";
    
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
        
        // request.httpBody = try? JSONEncoder().encode(userLogin)
        
        request.addValue("token", forHTTPHeaderField: "apptoken")
        request.addValue("token", forHTTPHeaderField: "devtoken")
                
        request.addValue(userLogin.username, forHTTPHeaderField: "username")
        request.addValue(userLogin.password, forHTTPHeaderField: "password")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print ("ERROR ")
                print(error)
                // Handle error here
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,

                  (200...299).contains(httpResponse.statusCode) else {
                print ("NOT 2XX result ")

                // Handle non-2xx status code here
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
                print ("DO AREWA")
                print (dataModel)
                  completion(.success(dataModel))
              } catch {
                  completion(.failure(error))
              }
        }
        
        task.resume()
        /*
         
         */
    }
}
