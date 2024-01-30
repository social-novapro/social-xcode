//
//  Polls.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-30.
//

import Foundation

class PollsApi: API_Helper {
    func create(pollInput: TempPollCreator, completion: @escaping (Result<CreatePollRes, Error>) -> Void) {
                
        var goodOptions:Int32 = 0
        var foundOptions: [String] = []
        
        for option in pollInput.options {
            if (option != "") {
                goodOptions+=1
                foundOptions.append(option)
            }
        }
        if (goodOptions < 1) {
            return
        }
        
        var createPollReq = CreatePollReq(pollName: pollInput.pollQuestion, optionAmount: goodOptions, option_1: foundOptions[0], option_2: foundOptions[1])

        var amount:Int32 = 0
        
        // this is horrible code - need to update the api to work better
        for optionFound in foundOptions {
            amount+=1
            if (amount==3) {
                createPollReq.option_3 = optionFound
            } else if (amount==4) {
                createPollReq.option_4 = optionFound
            } else if (amount==5) {
                createPollReq.option_5 = optionFound
            } else if (amount==6) {
                createPollReq.option_6 = optionFound
            } else if (amount==7) {
                createPollReq.option_7 = optionFound
            } else if (amount==8) {
                createPollReq.option_8 = optionFound
            } else if (amount==9) {
                createPollReq.option_9 = optionFound
            } else if (amount==10) {
                createPollReq.option_10 = optionFound
            }
        }
        
        let APIUrl = baseAPIurl + "/polls/create"
        
        print("procededing")
        self.requestDataWithBody(urlString: APIUrl, httpMethod: "POST", httpBody: createPollReq) { (result: Result<CreatePollRes, Error>) in
            switch result {
            case .success(let pollData):
                completion(.success(pollData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func get(pollID: String, completion: @escaping (Result<UserLoginResponse, Error>) -> Void) {
        let APIUrl = baseAPIurl + "/polls/get/\(pollID)"
        self.requestData(urlString: APIUrl) { (result: Result<UserLoginResponse, Error>) in
            switch result {
            case .success(let pollData):
                completion(.success(pollData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func createVote(pollID: String, optionID: String, completion: @escaping (Result<VoteData, Error>) -> Void) {
        let APIUrl = baseAPIurl + "/polls/createVote/"
        self.requestDataWithBody(urlString: APIUrl, httpMethod: "PUT", httpBody: CreateVoteReq(pollID: pollID, pollOptionID: optionID)) { (result: Result<CreateVoteRes, Error>) in
            switch result {
            case .success(let voteData):
                var returningData:VoteData = VoteData(_id: "")
                
                if (voteData.newVote != nil) {
                    returningData = voteData.newVote ?? VoteData(_id: "")
                } else {
                    returningData = VoteData(
                        _id: voteData._id ?? "",
                        _version: voteData._version,
                        pollID: voteData.pollID,
                        userID: voteData.userID,
                        lastEdited: voteData.lastEdited,
                        timestamp: voteData.timestamp,
                        pollIndexID: voteData.pollIndexID,
                        pollOptionID: voteData.pollOptionID
                    )
                }
                completion(.success(returningData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func removeVote(pollID: String, optionID: String, completion: @escaping (Result<String, Error>) -> Void) {
        let APIUrl = baseAPIurl + "/polls/removeVote/"
        
        self.requestDataWithBody(urlString: APIUrl, httpMethod: "PUT", httpBody: CreateVoteReq(pollID: pollID, pollOptionID: optionID)) { (result: Result<RemoveVoteRes, Error>) in
            switch result {
            case .success(let voteData):
                var returningData:String = ""
                print(voteData)
                if (voteData.removedVote?.deleteUserVote?.pollOptionID != nil) {
                    returningData = voteData.removedVote?.deleteUserVote?.pollOptionID ?? ""
                }
                completion(.success(returningData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

    /*
     router.use('/create', create);
     router.use('/get', get);
     router.use('/createVote', createVote);
     router.use('/removeVote' , removeVote);
     router.use('/edit', edit);
     router.use('/delete', deleteRoute);
     router.use('/addOptions', appOptions);
     router.use('/userVote', userVote)
     */
}
