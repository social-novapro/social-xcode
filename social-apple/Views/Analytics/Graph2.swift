//
//  Graph2.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-05-01.
//

import SwiftUI
import Charts

struct Graph2: View {
    @State var analytics: [AnalyticTrendDataPoint]?

    var body: some View {
        VStack {
            Text("Graph2")
            Chart {
                ForEach(analytics!) { analytic in
                    BarMark(
                        x: .value("erf", 3),
                        y: .value("ef", 4)
                    )
                }
            }
        }
    }
}

struct Graph2_Previews: PreviewProvider {
    static var previews: some View {
        Graph1()
    }
}
