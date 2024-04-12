//
//  Admin.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-04-11.
//

import Foundation

class AdminApi: API_Helper {
    var errors: AdminErrorsApi
    
    override init(userTokensProv: UserTokenData) {
        self.errors = AdminErrorsApi(userTokensProv: userTokensProv)
        super .init(userTokensProv: userTokensProv)
    }
}
