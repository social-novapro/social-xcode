//
//  Graph.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-05-01.
//

import SwiftUI
import Charts

struct Graph: View {
    @State var graphType:Int64? = nil
    @State var analytics: [AnalyticTrendDataPoint]?
    @State var functionData: AnalyticFunctionDataPoint?
    @State var dataLoaded: Bool = false
    
    let api_requests = API_Rquests()

    var body: some View {
        VStack {
            if (dataLoaded == true) {
                Text("\(functionData?.title ?? "Unknown Title")")

                Chart {
                    ForEach((functionData?.points!)!) { point in
                        BarMark(
                            x: .value("Amounts", point.y ?? 0),
                            y: .value("Days", point.x ?? "Unknown")
                        )
                    }
                }
            }
            else {
                Text("loading")
            }
        }
        .onAppear {
            api_requests.getAnalyticFunction(graphType: graphType ?? 1) { result in
                print("analytic request")
                print (result)
                switch result {
                case .success(let analytics):
                    self.functionData = analytics
                    print("Done")
                    self.dataLoaded = true
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
