//
//  PostData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import Foundation

struct PostData: Decodable, Encodable {
    var _id: String
    var userID: String? = nil
    var timePosted: String? = nil
    var content: String? = nil
    var totalLikes: Int64? = nil
    var totalReplies: Int64? = nil
    var edited: Bool? = nil
    var editedTimestamp: String? = nil
    var amountEdited: Int64? = nil
    var quoteReplyID: String? = nil
//    var quotedPost: PostData
    
    private enum CodingKeys: String, CodingKey {
        case _id
        case userID
        case timePosted
        case content
        case totalLikes
        case totalReplies
        case edited
        case editedTimestamp
        case amountEdited
        case quoteReplyID
    }
}

struct AllPosts: Decodable, Identifiable {
    var id = UUID()
    var typeData: TypeData
    var postData: PostData
    var userData: UserData? = nil
    
    private enum CodingKeys: String, CodingKey {
        case typeData = "type"
        case postData
        case userData
    }
}

struct TypeData: Decodable, Encodable{
    let type: String
    let post: String? = nil
    
    private enum CodingKeys: String, CodingKey {
        case type
        case post
    }
}
/*
 
 struct FeedPosts<AllPosts>: MutableCollection, RandomAccessCollection {
 //    subscript(position: Array<AllPosts>.Index) -> AllPosts {
 //        get {{ return elements[position]}
 //        }
 //        set(newValue) {
 //            <#code#>
 //        }
 //    }
     
     var startIndex: Array<AllPosts>.Index
     
     var endIndex: Array<AllPosts>.Index
     
     var elements: [AllPosts]
     
     typealias Index = Array<AllPosts>.Index
     typealias Element = AllPosts
     typealias SubSequence = ArraySlice<AllPosts>
     
     subscript(position: Index) -> AllPosts {
         get { return elements[position] }
         set { elements[position] = newValue }
     }
     subscript(bounds: Range<Index>) -> SubSequence {
         get { return elements[bounds] }
         set { elements[bounds] = Array(newValue) }
     }
 }

 */
