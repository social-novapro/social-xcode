//
//  API_Data.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-28.
//

import Foundation

class API_Data {
    private let prodMode:Bool = false;
    
    func getURL() -> String {
        if (prodMode != true) {
            return "http://localhost:5002/v1"
        }
        else {
            return "https://interact-api.novapro.net/v1"
        }
    }
    
    func getAppToken() -> String {
        if (prodMode != true) {
            return "appToken"
        }
        else {
            return "appToken"
        }
    }
    
    func getDevToken() -> String {
        if (prodMode != true) {
            return "devToken"
        }
        else {
            return "devToken"
        }
    }
}
