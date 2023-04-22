//
//  FeedPage.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-21.
//

import SwiftUI

struct FeedPage: View {
    @Binding var userTokenData: UserTokenData?
//^ turn to state when using init
    //    @Binding var userID: String?
    let api_requests = API_Rquests()

    @State var userData: UserData?
    @State var isLoading:Bool = true
    
    @State var allPosts: [AllPosts]? = []
    @State var originalPosts = [AllPosts]();
    var body: some View {
        VStack {
            if (!isLoading) {
//                `print ("AEFJINAEOFJNAOJNO")`
                
                childFeed(allPostsIn: $allPosts)
                
//                ForEach(originalPosts) { post in
//                    Text(post.postData.content!)
//                }
                /*
                 
                 List {
                     ForEach(allPosts!.indices, id: \.self) { index in
                         
 //                    ForEach($allPosts) { feedPost in
                         NavigationLink {
                             PostPreView(
                                 postData: $allPosts[index].postData,
                                 userData: $allPosts[index].userData
                             )
                         } label: {
                             PostPreView(
                                 postData: $allPosts[index].postData,
                                 userData: $allPosts[index].userData
                             )
                         }
                     }
                 }
                 */
            }
            else {
                Text("loading feed")
            }
        }
        .onAppear {
            api_requests.getAllPosts(userTokens: userTokenData ?? UserTokenData(accessToken: "", userToken: "", userID: "")) { result in
                print(result)
                switch result {
                case .success(let allPosts):
                    self.allPosts = allPosts
//                    print(loginData)
                    print("Done")
                    self.isLoading = false
//                    self.userLoginData = userLoginData
//                    self.shouldNavigate = true
//                    onDone(userLoginData)
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}


struct childFeed: View {
    @Binding var allPostsIn: [AllPosts]?
    @State var allPosts: [AllPosts]?
//    @State var postDatas: [AllPosts]
    @State var showData: Bool = false
//    let allPosts: [AllPosts] = // your array of AllPosts
   

//    init (allPostsIn: [AllPosts]) {
//        print ("FOAJNOJNEOJN")
//        print (allPostsIn[0] ?? "what2")
//
//        self.allPosts = allPostsIn
//        print (self.allPosts?[0] ?? "what")
//
//        //        print ()
//        if (self.allPosts != nil) {
//            print ("maybe")
//        }
//        else {
//            print ("eh")
//        }
//    }
//    let newPosts = originalPosts
    var body: some View {
        VStack {
            if showData {
                List {
                    ForEach(allPosts!) { post in
                        VStack {
                            Spacer()

                            HStack {
                                Spacer()

                                HStack {
                                    Text(post.userData?.displayName ?? "")
                                    Text("@\(post.userData?.username ?? "")")
                                }
                                .background(.blue)

                                Spacer()

                                HStack {
//                                    Spacer()
                                    Text(post.postData.content!)
                                    Spacer()
                                }
                                .background(.green)
                                .foregroundColor(.black)
                                Spacer()
                            }
                            Spacer()

                            
                        }
                        .background(.red)
                        Spacer()
                    }
                    
                }
            }
            else {
                Text("Loading")
            }
        }
        .onAppear {
            allPosts = self.allPostsIn
            if (allPosts != nil) {
                showData = true;
                print ("showing")
            }
//            $postDatas = self.allPosts!
//            let postDataArray = allPosts.map { $0 }
//            let postDatas = PostData(postDataArray)
        }
    /*
    var body: some View {
//        return
//        List {
            if let allPosts = allPosts {
                ForEach(originalPosts.indices) { index in
                    Text(originalPosts[index].postData.content ?? "content")
                    NavigationLink (
                        destination: {
//                            PostPreView(
////                                postData: originalPosts![index].postData,
////                                userData: originalPosts![index].userData
////                                postData: <#T##Binding<PostData?>#>, userData: <#T##Binding<UserData?>#>
//                            )
                        },
                        label: {
                            PostPreView(
                                postData: originalPosts[index].postData,
                                userData: originalPosts[index].userData
                            )
                        }
                    )
//                ForEach(originalPosts, id: \.self) { feedPost in
//                    NavigationLink (
//                        destination: {
//                            PostPreView(
//                                postData: feedPost.postData,
//                                userData: feedPost.userData
//                            )
//                        },
//                        label: {
//                            PostPreView(
//                                postData: feedPost.postData,
//                                userData: feedPost.userData
//                            )
//                        }
//                    )
                }
            } else {
                Text("No posts found.")
            }
//            ForEach(allPosts ?? []) { post in
//
////                    ForEach($allPosts) { feedPost in
//                NavigationLink {
//                    PostPreView(
//                        postData: post.postData,
//                        userData: post.userData
//                    )
//                } label: {
//                    PostPreView(
//                        postData: $allPosts[index].postData,
//                        userData: $allPosts[index].userData
//                    )
//                }
//            }
        }
     */
    }
}
