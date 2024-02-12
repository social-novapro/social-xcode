//
//  Analytics.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-02-11.
//

import Foundation

class AnalyticsApi: API_Helper {
    func getAnalyticTrend(completion: @escaping (Result<[AnalyticTrendDataPoint], Error>) -> Void) {
        print("Request analytic trend")
        let APIUrl = baseAPIurl + "/get/analyticTrend"
        
        self.requestData(urlString: APIUrl) { (result: Result<[AnalyticTrendDataPoint], Error>) in
            switch result {
            case .success(let analytic):
                completion(.success(analytic))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func getAnalyticFunction(graphType: Int64, completion: @escaping (Result<AnalyticFunctionDataPoint, Error>) -> Void) {
        print("Request analytic trend")
        let APIUrl = baseAPIurl + "/get/analyticTrend/\(graphType)"
        
        self.requestData(urlString: APIUrl) { (result: Result<AnalyticFunctionDataPoint, Error>) in
            switch result {
            case .success(let analytic):
                completion(.success(analytic))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
