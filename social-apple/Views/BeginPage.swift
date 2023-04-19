//
//  Begin.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI

struct BeginPage: View {
    var body: some View {
        NavigationView {

            VStack {
                Text("Hello, world!")
                NavigationLink(destination: LoginPage()) {
                    Text("Go to another view")
                }
            }
            .navigationTitle("Begin")
        }
    }

}

struct Begin_Previews: PreviewProvider {
    static var previews: some View {
        BeginPage()
    }
}
