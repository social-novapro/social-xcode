//
//  Graph.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-05-01.
//

import SwiftUI
import Charts

@available(macOS 14.0, *)
struct Graph: View {
    @ObservedObject var client: Client
    @State var graphType:Int64? = nil
    @State var analytics: [AnalyticTrendDataPoint]?
    @State var functionData: AnalyticFunctionDataPoint?
    @State var dataLoaded: Bool = false
        
    var body: some View {
        VStack {
            if (dataLoaded == true) {
                Text("\(functionData?.title ?? "Unknown Title")")
                if #available(iOS 17, *) {
                    Chart {
                        ForEach((functionData?.points) ?? []) { point in
                            BarMark(
                                x: .value("Amounts", point.y ?? 0),
                                y: .value("Days", point.x ?? "Unknown")
                            )
                        }
                    }
#if !os(tvOS)
                    .chartScrollableAxes(.vertical)
#endif
                }
            }
            else {
                Text("loading")
            }
        }
        .onAppear {
            client.api.anaytics.getAnalyticFunction(graphType: graphType ?? 1) { result in
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
