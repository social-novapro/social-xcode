//
//  AnalyticsView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-05-01.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @ObservedObject var client: ApiClient
    @State var doneLoading: Bool = false
    @State var analytics: [AnalyticTrendDataPoint]?
    @State var graphIsShown:Bool = false
    @State var graphNumber:Int64? = nil
    @State var isGraphShown: Bool = false
    
    var body: some View {
        VStack {
            if (!doneLoading) {
                Text("Please wait")
            } else {
                VStack {
                    if (graphNumber != nil) {
                        EmptyView()
                    }
                    Text("\(graphNumber ?? 0)")
                    Button(action: {
                        self.graphNumber = 1
                        self.graphIsShown = true
                        print("button1 button")
                    }) {
                        Text("Open graph1")
                    }
                    Button(action: {
                        self.graphNumber = 2
                        self.graphIsShown = true
                        print("button2 button")
                    }) {
                        Text("Open graph2")
                    }
                    Button(action: {
                        self.graphNumber = 3
                        self.graphIsShown = true
                        print("button2 button")
                    }) {
                        Text("Open graph3")
                    }
                    Button(action: {
                        self.graphNumber = 4
                        self.graphIsShown = true
                        print("button2 button")
                    }) {
                        Text("Open graph4")
                    }
                }
                .padding(20)
            }
        }
        .sheet(isPresented: $graphIsShown, onDismiss: didDismiss) {
            VStack {
                Spacer()
                VStack {
                    Spacer()
                    VStack {
                        Spacer()
                        if ((graphNumber ?? 0 ) > 0 && (graphNumber ?? 0) < 5) {
                            if #available(macOS 14.0, *) {
                                Graph(client: client, graphType: graphNumber, analytics: self.analytics)
                            } else {
                                Text("requires newer macOS")
                            }

                        } else {
                            Text("Something went wrong with the graph number. \(graphNumber ?? 0)")
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
            client.anaytics.getAnalyticTrend() { result in
                print("analytic request")
                switch result {
                case .success(let analytics):
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
        self.graphNumber = nil
    }
}

// testing
struct secondaryAnalyticView: View {
    @State var openSheet: Bool = false
    @State var numberGraph: Int? = nil

    var body: some View {
        VStack {
            Text("Button \(String(numberGraph ?? 0))")
            Button(action: {
                self.numberGraph = 1
                self.openSheet = true
            }) {
                Text("Open Graph 1")
            }
            
            Button(action: {
                self.numberGraph = 2
                self.openSheet = true
            }) {
                Text("Open Graph 2")
            }
        }
        .sheet(isPresented: $openSheet) {
           if let numberGraph = self.numberGraph {
               VStack {
                   Text("Sheet opened")
                   Text("My number is \(numberGraph)")
               }
           } else {
               Text("Not loaded")
           }
       }
    }
}

