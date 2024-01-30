//
//  PollsData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-30.
//

import Foundation

struct PollData: Decodable, Encodable {
    var _id: String
    var _version: Int64?
    var timestamp: Int64?
    var userID: String?
    var postID: String?
    var timestampEnding: Int64?
    var lastEdited: Int64?
    var pollName: String?
    var pollOptions: [PollOptions]?
}

struct VoteData: Decodable, Encodable {
    var _id: String
    var _version: Int16?
    var pollID: String?
    var userID: String?
    var lastEdited: Int64?
    var timestamp: Int64?
    var pollIndexID: String?
    var pollOptionID: String?
}

struct TempPollCreator {
     var amountOptions: Int32 = 1 // +1
     var minMaxHit: Int32 = 0 /* 0=false, 1=min, 2=max */
     var options: [String] = ["", ""]
     var pollQuestion: String = ""
}

struct CreatePollReq: Encodable {
    var pollName: String
    var timeLive: Int64? = nil
    var optionAmount: Int32
    var option_1: String
    var option_2: String
    var option_3: String?
    var option_4: String?
    var option_5: String?
    var option_6: String?
    var option_7: String?
    var option_8: String?
    var option_9: String?
    var option_10: String?
}

struct CreatePollRes: Decodable {
    var pollData: PollData
//    foundErrors
}


struct CreateVoteReq: Encodable {
    var pollID:String
    var pollOptionID:String
}

struct CreateVoteRes: Decodable {
    var newVote:VoteData?
    var oldVote:VoteData?
    var _id: String?
    var _version: Int16?
    var pollID: String?
    var userID: String?
    var lastEdited: Int64?
    var timestamp: Int64?
    var pollIndexID: String?
    var pollOptionID: String?
}

struct RemoveVoteRes: Decodable {
    var voted: Bool?
    var error: ErrorData?
    var removedVote: DeleteUserVote?
}

struct DeleteUserVote: Decodable {
    var deleteUserVote: VoteData?
}
