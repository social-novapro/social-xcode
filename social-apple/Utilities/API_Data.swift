//
//  API_Data.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-28.
//

import Foundation

class API_Data {
    private let prodMode:Bool = true;
    
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
            return "235e9cce-88c0-44e8-94c5-76bc615659a6"
        }
        else {
            return "efb5cadc-45e2-4ba9-943f-0a24c2c88124"
        }
    }
    func getDevToken() -> String {
        if (prodMode != true) {
            return "65475af9-3af8-4d54-b66b-1a32118b13fe"
        }
        else {
            return "872d2652-992b-49f5-906a-afffab3fa7b1"
        }
    }
}
