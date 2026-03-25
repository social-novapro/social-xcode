//
//  PollView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-13.
//

import SwiftUI

struct PollView: View {
    @ObservedObject var client: Client
    @Binding var feedData: AllPosts
    
    @State var pollData: PollData
    @State var voteOption: String?
    @State var failedVote: Bool = false
    @State var voting:Bool = false
    @State var removeVote: String?

    var body: some View {
        VStack {
            HStack {
                Text(feedData.pollData?.pollName ?? "")
                Spacer()
            }
            if (client.devMode?.isEnabled==true) {
                Text("Vote: \(voteOption ?? "xx")")
            }
            if (failedVote==true) {
                Text("Something went wrong while voting...")
            }
            ForEach (feedData.pollData?.pollOptions ?? []) { option in
                PollOptionView(client: client, feedData: $feedData, pollData: $pollData, voteOption: $voteOption, failedVote: $failedVote, voting: $voting, option: option, removeVote: $removeVote)
            }
            HStack {
                Text(int64TimeUntilFormatter(timestamp: pollData.timestampEnding ?? 0))
                Spacer()
            }
        }
    }
}

struct PollOptionView: View {
    @ObservedObject var client: Client
    @Binding var feedData: AllPosts
    @Binding var pollData: PollData
    @Binding var voteOption: String?
    @Binding var failedVote: Bool
    @Binding var voting:Bool
    
    @State var option: PollOptions
    @Binding var removeVote: String?
    
    var body: some View {
        VStack {
            Button(action: {
                if (voting == true) {
                    return
                }
                
                client.hapticPress()
                voting = true
                
                if (option._id == voteOption) {
                    client.api.polls.removeVote(pollID: feedData.pollData?._id ?? "XX", optionID: option._id) { result in
                        switch result {
                        case .success(let unvoted):
                            if (voteOption == unvoted) {
                                voteOption = nil
                                feedData.voteData = nil
                            }
                            client.hapticPress()
                            voting = false
                        case .failure(let error):
                            voting = false
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                } else {
                    client.api.polls.createVote(pollID: feedData.pollData?._id ?? "XX", optionID: option._id) { result in
                        switch result {
                        case .success(let newVoteData):
                            voteOption = newVoteData.pollOptionID
                            DispatchQueue.main.async {
                                feedData.voteData = newVoteData
                            }
                            
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
                    HStack {
                        Text(option.optionTitle ?? "unknown title")
                        Spacer()
                        Text("\(option.amountVoted ?? 0)")
                    }
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
            .background(option._id == feedData.voteData?.pollOptionID ? Color.accentColor : Color.clear)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 3)
            )
        }
    }
}

struct PollCreatorView: View {
    @ObservedObject var client: Client
    @Binding var tempPollCreator: TempPollCreator
    
    var body: some View {
        VStack {
            ScrollView {
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
                    
                    VStack {
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
        }
        .padding(15)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor, lineWidth: 3)
        )
    }
}
