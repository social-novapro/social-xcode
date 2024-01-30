//
//  PollView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-13.
//

import SwiftUI

struct PollView: View {
    @ObservedObject var client: ApiClient
    @State var pollData: PollData
    @State var voteOption: String?
    @State var failedVote: Bool = false
    @State var voting:Bool = false

    var body: some View {
        VStack {
            Text(pollData.pollName ?? "")
            if (client.devMode?.isEnabled==true) {
                Text("Vote: \(voteOption ?? "xx")")
            }
            if (failedVote==true) {
                Text("Something went wrong while voting...")
            }
            ForEach (pollData.pollOptions ?? []) { option in
                Button(action: {
                    if (voting == true) {
                        return
                    }
                    
                    client.hapticPress()
                    voting = true
                    if (option._id == voteOption) {
                        client.polls.removeVote(pollID: pollData._id, optionID: option._id) { result in
                            switch result {
                            case .success(let unvoted):
                                if (voteOption == unvoted) {
                                    voteOption = nil
                                }
                                client.hapticPress()
                                voting = false
                            case .failure(let error):
                                voting = false
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                    } else {
                        client.polls.createVote(pollID: pollData._id, optionID: option._id) { result in
                            switch result {
                            case .success(let newVoteData):
                                voteOption = newVoteData.pollOptionID
                                client.hapticPress()
                                voting = false
                            case .failure(let error):
                                failedVote=true
                                voting = false
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                }) {
                    VStack {
                        Text(option.optionTitle ?? "unknown title")
                        HStack {
                            if (client.devMode?.isEnabled==true) {
                                Text("OptionID: \(option._id)")
                            }
                            Spacer()
                        }
                    }
                }
                .buttonStyle(.plain)
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

struct PollCreatorView: View {
    @ObservedObject var client: ApiClient
    @Binding var tempPollCreator: TempPollCreator
    
    var body: some View {
        VStack {
            TextField("Poll Question", text: $tempPollCreator.pollQuestion)
            Divider()
            
            if (tempPollCreator.pollQuestion != "") {
                HStack {
                    Button(action: {
                        if (tempPollCreator.minMaxHit==1) {
                            tempPollCreator.minMaxHit=0
                        }
                        if tempPollCreator.amountOptions < 9 {
                            tempPollCreator.amountOptions+=1
                            tempPollCreator.options.append("")
                        } else {
                            tempPollCreator.minMaxHit=2
                        }
                    }) {
                        Text("Add Option")
                    }
                    Button(action: {
                        if (tempPollCreator.minMaxHit==2) {
                            tempPollCreator.minMaxHit=0
                        }
                        if tempPollCreator.amountOptions > 1 {
                            tempPollCreator.amountOptions -= 1
                            tempPollCreator.options.removeLast()
                        } else {
                            tempPollCreator.minMaxHit=1
                        }
                    }) {
                        Text("Remove Option")
                    }
                }
                
                ScrollView {
                    ForEach(0...tempPollCreator.amountOptions,  id: \.self) { index in
                        TextField("Option \(index+1)", text: $tempPollCreator.options[Array<String>.Index(index)])
                    }
                    if (tempPollCreator.minMaxHit==1) {
                        Text("Can't have less than 2 options in a poll.")

                    } else if (tempPollCreator.minMaxHit==2) {
                        Text("Can't have more than 10 options in a poll.")
                    }
                }
                Spacer()
            }
        }
        .padding(15)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor, lineWidth: 3)
        )
    }
}
