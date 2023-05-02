//
//  AnalyticsView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-05-01.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    let api_requests = API_Rquests()
    @State var doneLoading: Bool = false
    @State var analytics: [AnalyticTrendDataPoint]?
    @State var graphIsShown:Bool = false
    @State var graphNumber:Int64? = nil
    
    var body: some View {
        VStack {
            if (!doneLoading) {
                Text("Please wait")
            } else {
                VStack {
                    Button(action: {
                        graphNumber = 1
                        graphIsShown = true
                        print("button1 button")
                    }) {
                        Text("Open graph1")
                    }
                    Button(action: {
                        graphNumber = 0
                        graphIsShown = true
                        print("button2 button")
                    }) {
                        Text("Open graph0")
                    }
                }
            }
        }
        .sheet(isPresented: $graphIsShown, onDismiss: didDismiss) {
            ZStack() {
                Spacer()
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        if (graphNumber == nil) {
                            Text("not loaded ")
                        }
                        else {
//                            if let graphNumber = graphNumber {
//                                switch graphNumber {
//                                case 1:
//                                    Graph1(analytics: self.analytics)
//                                case 2:
//                                    Graph2(analytics: self.analytics)
//                                default:
//                                    Text("Unknown graph")
//                                }
//                            }
                            switch graphNumber {
                            case 1:
                                Graph1(analytics: self.analytics)
                            case 2:
                                Graph1(analytics: self.analytics)
                            case .none:
                                Text("None set")
                            case .some(_):
                                Text("Unknown setting")
                            }
                        }
                        Spacer()
                    }
                    Button("Dismiss", action: { graphIsShown.toggle() })
                    Spacer()
                }
                Spacer()

            }
        }
        .onAppear {
            api_requests.getAnalyticTrend() { result in
                print("analytic request")
//                print(result)
                switch result {
                case .success(let analytics):
//                    print (analytics)
                    self.analytics = analytics
                    print("Done")
                    self.doneLoading = true
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        .navigationTitle("Analytics")
    }
    func didDismiss() {
        self.graphIsShown = false
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
    }
}
