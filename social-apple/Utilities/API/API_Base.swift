//
//  API_Base.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-09-04.
//

import Foundation

class API_Base {
    var apiHelper: API_Helper
    
    var apiData = API_Data()
    var baseAPIurl:String = "https://interact-api.novapro.net/v1"

    init(apiHelper: API_Helper) {
        self.apiHelper = apiHelper
        self.baseAPIurl = apiData.getURL()
    }
}
