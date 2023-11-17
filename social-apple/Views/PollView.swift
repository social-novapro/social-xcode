//
//  PollView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-13.
//

import SwiftUI

struct PollView: View {
    @State var pollData: PollData
    @State var voteOption: String?

    var body: some View {
        VStack {
            Text(pollData.pollName ?? "")
            ForEach (pollData.pollOptions ?? []) { option in
                Text(option.optionTitle ?? "unknown title")
                    .padding(15)
                    .background(option._id == voteOption ? Color.accentColor : Color.clear)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.accentColor, lineWidth: 3)
                    )
            }
        }
    }
}
