//
//  LiveChatView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-16.
//

import SwiftUI

struct SendLiveChatView: View {
    @ObservedObject var webSocketManager: LiveChatWebSocket

    @Binding var userTokenData: UserTokenData?
    @Binding var writingPopover: Bool
    @State private var content: String = ""

    var body: some View {
        VStack {
            Form {
                TextField("Content", text: $content)
                
                Button("Send Message") {
                    print(webSocketManager.tokens)
                    let liveChatSend = createLiveSendData(type: 2, mesType: 2, content: self.content, replyTo: nil, userTokenData: userTokenData)
                    webSocketManager.sendMessage(liveChatSendData: liveChatSend)
                    self.writingPopover = false
                }
            }
        }
        .onAppear {
            print("YourView: webSocketManager initialized")
        }
        .navigationTitle("New Live Message")
    }
}

struct LiveChatView: View {
    @Binding var userTokenData: UserTokenData?
    @State var verifiedConnection: Bool = false
    @State var messages: [LiveChatData] = []
    @State var typers: [LiveChatTypers] = []
//    @State var writingPopover:Bool = false
    @State private var isInitialized = false
    @State private var content: String = ""

    @StateObject private var webSocketManager = LiveChatWebSocket()

    var body: some View {
        VStack {
            HStack {
                ForEach(typers) { typer in
                    Text(typer.username)
                }
                if (typers.count > 0) {
                    Text(" is typing")
                }
                
            }
            ScrollView {
                ForEach(messages) { message in
                    ChatMessageView(chatMessage: message)
                }
            }
            Spacer()
            Form {
                TextField("Content", text: $content)
                if (content != "") {
                    Button("Send Message") {
                        print(webSocketManager.tokens)
                        let liveChatSend = createLiveSendData(type: 2, mesType: 2, content: self.content, replyTo: nil, userTokenData: userTokenData)
                        webSocketManager.sendMessage(liveChatSendData: liveChatSend)
                        self.content = ""
                    }
                }
            }
//            Button("Write a message") {
//                print(webSocketManager.tokens)
//                self.writingPopover = true
//            }
//            Button("Send Message") {
//                let liveChatSend = createLiveSendData(type: 2, mesType: 2, content: "New message", replyTo: nil, userTokenData: userTokenData)
//                webSocketManager.sendMessage(liveChatSendData: liveChatSend)
        }
        .navigationTitle("Live Chat")
//        .popover(isPresented: $writingPopover) {
//            
//            SendLiveChatView(webSocketManager: webSocketManager, userTokenData: $userTokenData, writingPopover: $writingPopover)
//        }
        .onAppear {
            if self.isInitialized == true {
                return
            }
            
            webSocketManager.connectWS(userID: userTokenData?.userID ?? "")
            self.isInitialized = true
//            webSocketManager = LiveChatWebSocket(userID: userTokenData.userID)
            // Perform any additional setup or send initial messages when the view appears
        }
        .onReceive(webSocketManager.$receivedDataQueue) { newQueue in
            DispatchQueue.main.async {
                print("Received data queue count: \(newQueue.count)")
                print("--- 1")
                print("---")

                if let newReceivedData = newQueue.first {
                    print("new message, " + String(describing: newReceivedData))

                    switch (newReceivedData.type) {
                    case 10:
                        print("incoming auth request")
                        if (newReceivedData.mesType==1) {
                            let authSend:LiveChatSendData = createLiveSendData(type: 10, mesType: 2, content: "tokens", replyTo: nil, userTokenData: userTokenData ?? nil)
                            webSocketManager.sendMessage(liveChatSendData: authSend)
                            print(webSocketManager.tokens)

                        }
                        break;
                    case 2:
                        print("incoming message")
                        messages.append(newReceivedData)
                        break;
                    case 6:
                        print("user joined")
                        messages.append(newReceivedData)
                        break;
                    case 7:
                        print("user left")
                        messages.append(newReceivedData)
                        break;
                    case 8:
                        print("user typing")
                        if (typers.count > 0) {
                            if (newReceivedData.userTyping == true) {
                                print("Typing")
                                var foundUser = false
                                for typer in typers {
                                    if ((typer.username) == (newReceivedData.user?.username ?? "unknown")) {
                                        foundUser = true
                                    }
                                }
                                if (foundUser == false) {
                                    typers.append(LiveChatTypers(username: newReceivedData.user?.username ?? "unknown"))
                                }
                            }
                        }
                    case 9:
                        print("user stop typing")
                        if (newReceivedData.userTyping == false) {
                            print("removing typer")
                            var i = 0
                                
                            for typer in typers {
                                if ((typer.username) == (newReceivedData.user?.username ?? "unknown")) {
                                    typers.remove(at: i)
                                }
                                i=i+1
                            }
                        }
                        break;
                    default:
                        break;
                    }
                }
            }
        }
    }
}

struct ChatMessageView: View {
    @State var chatMessage: LiveChatData
    
    var body: some View {
        VStack {
            HStack {
                Text(chatMessage.user?.displayName ?? "unknown displayname")
                Text("@"+(chatMessage.user?.username ?? "unknown username"))
            }
            HStack {
                if (chatMessage.type == 6) {
                    Text(chatMessage.userJoin?.content ?? "userjoin")
                }
                if (chatMessage.type == 7) {
                    Text(chatMessage.userJoin?.content ?? "userleft")
                }
                if (chatMessage.type == 2) {
                    Button("debug") {
                        print(chatMessage)
                    }
                    Text(chatMessage.message?.content ?? "no content")
                }
            }
            Text(chatMessage._id ?? "no id")
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor, lineWidth: 3)
        )
        .padding(5)
    }
}
