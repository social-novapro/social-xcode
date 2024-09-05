//
//  Admin.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-04-11.
//

import Foundation

class AdminApi: API_Base {
    var errors: AdminErrorsApi
    
    override init(apiHelper: API_Helper) {
        self.errors = AdminErrorsApi(apiHelper: apiHelper)
        super .init(apiHelper: apiHelper)
    }
}
