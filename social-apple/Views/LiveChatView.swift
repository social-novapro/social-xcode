//
//  LiveChatView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-16.
//

import SwiftUI

struct SendLiveChatView: View {
    @ObservedObject var client: Client

    @Binding var userTokenData: UserTokenData?
    @Binding var writingPopover: Bool
    @State private var content: String = ""

    var body: some View {
        VStack {
//            Form {
                TextField("Content", text: $content)
                Button("Send Message") {
                    print(client.api.livechatWS.tokens)
                    let liveChatSend = createLiveSendData(type: 2, mesType: 2, content: self.content, replyTo: nil, userTokenData: userTokenData)
                    client.api.livechatWS.sendMessage(liveChatSendData: liveChatSend)
                    self.writingPopover = false
                }
//            }
        }
        .onAppear {
            print("YourView: webSocketManager initialized")
        }
        .navigationTitle("New Live Message")
    }
}

struct LiveChatView: View {
    @ObservedObject var client: Client
//    @Binding var userTokenData: UserTokenData?
    @State var verifiedConnection: Bool = false
    @State var messages: [LiveChatData] = []
    @State var typers: [LiveChatTypers] = []
//    @State var writingPopover:Bool = false
    @State private var isInitialized = false
    @State private var content: String = ""

//    @StateObject private var webSocketManager = LiveChatWebSocket()

    var body: some View {
        VStack {
            HStack {
                HStack {
                    ForEach(typers) { typer in
                        Text(typer.username)
                    }
                    if (typers.count > 0) {
                        Text(" is typing")
                    }
                }
            }
            VStack {
                ScrollView {
//                    ScrollViewReader { proxy in
                        ForEach(messages) { message in
                            ChatMessageView(client: client, chatMessage: message)
                        }
                        Spacer()
                        /*
                         
                         .onChange(of: messages.count) { _ in
                             
                             DispatchQueue.main.async {
                                 withAnimation {
                                     proxy.scrollTo(messages.count - 1, anchor: .bottom)
                                 }
                             }
                         }
                    }
                     */
                }

            }
            VStack {
                TextField("Content", text: $content)
                if (content != "") {
                    Button("Send Message") {
                        client.hapticPress()
                        print(client.api.livechatWS.tokens)
                        let liveChatSend = createLiveSendData(type: 2, mesType: 2, content: self.content, replyTo: nil, userTokenData: client.userTokens)
                        client.api.livechatWS.sendMessage(liveChatSendData: liveChatSend)
                        self.content = ""
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
        .padding(.bottom, 120)
        .padding(10)
        .navigationTitle("Live Chat")
        .onAppear {
            if self.isInitialized == true {
                return
            }
            
            client.api.livechatWS.connectWS()
            self.isInitialized = true
        }
        .onReceive(client.api.livechatWS.$receivedDataQueue) { newQueue in
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
                            let authSend:LiveChatSendData = createLiveSendData(type: 10, mesType: 2, content: "tokens", replyTo: nil, userTokenData: client.userTokens)
                            client.api.livechatWS.sendMessage(liveChatSendData: authSend)
                            print(client.api.livechatWS.tokens)
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
    @ObservedObject var client: Client
    @State var chatMessage: LiveChatData
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text(chatMessage.user?.displayName ?? "unknown displayname")
                    Text("@"+(chatMessage.user?.username ?? "unknown username"))
                    Spacer()
                }
                HStack {
                    if ((chatMessage.message?.timeStamp) != nil) {
                        Text(int64TimeFormatter(timestamp: chatMessage.message?.timeStamp ?? 0))
                        Spacer()
                    }
                }
                HStack {
                    if (chatMessage.type == 6) {
                        Text(chatMessage.userJoin?.content ?? "userjoin")
                    }
                    if (chatMessage.type == 7) {
                        Text(chatMessage.userJoin?.content ?? "userleft")
                    }
                    if (chatMessage.type == 2) {
                        Text(chatMessage.message?.content ?? "no content")
                    }
                    Spacer()
                }
                if (client.devMode?.isEnabled == true) {
                    Button("debug") {
                        print(chatMessage)
                    }

                    Text(chatMessage._id ?? "no id")
                }
            }
            .padding(10)
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor, lineWidth: 3)
        )
        .padding(5)
    }
}
