//
//  AboutView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-22.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            VStack {
                Text("Interact is developed by Nova Productions")
                    .fontWeight(.heavy)
                Text("https://novapro.net")
                    .underline()
            }
            .padding(20)
            
            VStack {
                Text("About Interact")
                    .fontWeight(.heavy)
                Text("Interact is a social network, started in July 2021")
                Text("Interact has an open API, letting anyone develop for it")
                
            }
        }
        .padding(20)
        .navigationTitle("About Interact")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
