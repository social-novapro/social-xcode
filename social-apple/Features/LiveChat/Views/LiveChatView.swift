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
            TextField("Content", text: $content)
            Button("Send Message") {
                let liveChatSend = createLiveSendData(type: 2, mesType: 2, content: self.content, replyTo: nil, userTokenData: userTokenData)
                client.api.livechatWS.sendMessage(liveChatSendData: liveChatSend)
                self.writingPopover = false
            }
        }
        .navigationTitle("New Live Message")
    }
}

struct LiveChatView: View {
    @ObservedObject var client: Client
    @Environment(\.interactDesign) private var design
    @Environment(\.customTabBarReserveIsActive) private var customTabBarReserveIsActive

    @State private var messages: [LiveChatData] = []
    @State private var typers: [LiveChatTypers] = []
    @State private var isInitialized = false

    @State private var content: String = ""
    @State private var replyToMessage: LiveChatData?

    @State private var editingMessageID: String?
    @State private var editingContent: String = ""

    @State private var pendingDeleteMessage: LiveChatData?
    @State private var showDeleteConfirm = false
    @FocusState private var composerFocused: Bool

    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 8) {
                if !typers.isEmpty {
                    InteractStatusBanner {
                        Text(typingLabel())
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                }

                List {
                    if messages.isEmpty {
                        InteractEmptyStateView(
                            title: isInitialized ? "No messages yet" : "Connecting...",
                            systemImage: isInitialized ? "bubble.left.and.bubble.right" : "antenna.radiowaves.left.and.right",
                            message: isInitialized ? "Start the conversation when you're ready." : "Opening the live chat connection."
                        )
                        .interactPlainListRow()
                    } else {
                        ForEach(messages) { message in
                            ChatMessageRow(
                                client: client,
                                chatMessage: message,
                                isOwnMessage: isOwnMessage(message),
                                isEditing: editingMessageID == message._id,
                                editingContent: $editingContent,
                                replyPreview: replyPreview(for: message),
                                onReply: {
                                    beginReply(message)
                                },
                                onEdit: {
                                    beginEdit(message)
                                },
                                onDelete: {
                                    requestDelete(message)
                                },
                                onSaveEdit: {
                                    saveEdit()
                                },
                                onCancelEdit: {
                                    cancelEdit()
                                }
                            )
                            .id(messageRowID(message))
                            .interactPlainListRow(rowPadding: 5)
                        }
                    }

                    Color.clear
                        .frame(height: chatBottomAnchorHeight)
                        .interactPlainListRow(rowPadding: 0)
                        .id("chat-bottom-anchor")
                }
                .interactCardListScreen()
                #if os(iOS)
                .scrollDismissesKeyboard(.interactively)
                .simultaneousGesture(
                    TapGesture().onEnded {
                        composerFocused = false
                    }
                )
                #endif
                .onAppear {
                    scrollToBottom(proxy: proxy, animated: false)
                }
                .onChange(of: messages.count) { _ in
                    scrollToBottom(proxy: proxy, animated: true)
                }
            }
        }
        .interactAppBackground()
        .safeAreaInset(edge: .bottom, spacing: 0) {
            composerBar
        }
        .navigationTitle("Live Chat")
        #if os(iOS)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    composerFocused = false
                }
            }
        }
        #endif
        .onAppear {
            if self.isInitialized {
                return
            }
            client.api.livechatWS.connectWS()
            self.isInitialized = true
        }
        .onChange(of: client.userTokens.userID) { _ in
            client.api.livechatWS.connectWS()
            self.isInitialized = true
        }
        .onReceive(client.api.livechatWS.$receivedDataQueue) { newQueue in
            DispatchQueue.main.async {
                guard let newReceivedData = newQueue.first else {
                    return
                }
                handleIncomingMessage(newReceivedData)
            }
        }
        .alert("Delete Message", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                confirmDelete()
            }
            Button("Cancel", role: .cancel) {
                pendingDeleteMessage = nil
            }
        } message: {
            Text("Are you sure you want to delete this message?")
        }
    }

    private func handleIncomingMessage(_ newReceivedData: LiveChatData) {
        switch newReceivedData.type {
        case 10:
            if newReceivedData.mesType == 1 {
                let authSend = createLiveSendData(type: 10, mesType: 2, content: "tokens", replyTo: nil, userTokenData: client.userTokens)
                client.api.livechatWS.sendMessage(liveChatSendData: authSend)
            }
        case 2:
            upsertMessage(newReceivedData)
        case 3:
            removeDeletedMessage(newReceivedData)
        case 5:
            upsertMessage(newReceivedData)
        case 6, 7:
            upsertMessage(newReceivedData)
        case 8:
            handleTyping(newReceivedData, isTyping: true)
        case 9:
            handleTyping(newReceivedData, isTyping: false)
        default:
            break
        }
    }

    private var composerBar: some View {
        VStack(spacing: 8) {
            if let replyToMessage {
                HStack {
                    Image(systemName: "arrowshape.turn.up.left")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Replying to @\(replyToMessage.user?.username ?? "unknown")")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(replyToMessage.message?.content ?? "")
                            .font(.caption)
                            .lineLimit(1)
                    }
                    Spacer()
                    Button("Cancel") {
                        self.replyToMessage = nil
                    }
                    .font(.caption)
                    .buttonStyle(.plain)
                }
                .padding(8)
                .background(Color.secondary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            HStack {
                TextField(editingMessageID == nil ? "Content" : "Edit message", text: activeInputBinding(), axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .submitLabel(editingMessageID == nil ? .send : .done)
                    .focused($composerFocused)
                    .onSubmit {
                        if editingMessageID == nil {
                            sendCurrentMessage()
                        } else {
                            saveEdit()
                        }
                    }

                if editingMessageID == nil {
                    Button {
                        sendCurrentMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 34, height: 34)
                    }
                    .buttonStyle(.borderedProminent)
                    .clipShape(Circle())
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                } else {
                    Button("Save Edit") {
                        saveEdit()
                    }
                    .disabled(editingContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    Button("Cancel") {
                        cancelEdit()
                    }
                }
            }
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .frame(maxWidth: 620)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.bottom, composerBottomPadding)
    }

    private func upsertMessage(_ newMessage: LiveChatData) {
        if let messageID = newMessage._id,
           let existingIndex = messages.firstIndex(where: { $0._id == messageID }) {
            messages[existingIndex] = newMessage
        } else {
            messages.append(newMessage)
        }
    }

    private func removeDeletedMessage(_ data: LiveChatData) {
        let deletedID = data.messageToDelete ?? data._id
        guard let deletedID else {
            return
        }

        messages.removeAll(where: { $0._id == deletedID })

        if editingMessageID == deletedID {
            cancelEdit()
        }

        if replyToMessage?._id == deletedID {
            replyToMessage = nil
        }
    }

    private func handleTyping(_ data: LiveChatData, isTyping: Bool) {
        let username = data.user?.username ?? "unknown"

        if isTyping {
            if !typers.contains(where: { $0.username == username }) {
                typers.append(LiveChatTypers(username: username))
            }
        } else {
            typers.removeAll(where: { $0.username == username })
        }
    }

    private func typingLabel() -> String {
        if typers.count == 1 {
            return "\(typers[0].username) is typing"
        }
        return "\(typers.count) people are typing"
    }

    private func isOwnMessage(_ message: LiveChatData) -> Bool {
        return message.user?._id == client.userTokens.userID || message.message?.userID == client.userTokens.userID
    }

    private func beginReply(_ message: LiveChatData) {
        replyToMessage = message
        editingMessageID = nil
        editingContent = ""
        composerFocused = true
    }

    private func beginEdit(_ message: LiveChatData) {
        guard isOwnMessage(message), let messageID = message._id else {
            return
        }

        editingMessageID = messageID
        editingContent = message.message?.content ?? ""
        replyToMessage = nil
        composerFocused = true
    }

    private func cancelEdit() {
        editingMessageID = nil
        editingContent = ""
    }

    private func sendCurrentMessage() {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return
        }

        client.hapticPress()
        let liveChatSend = createLiveSendData(
            type: 2,
            mesType: 2,
            content: trimmed,
            replyTo: replyToMessage?._id,
            userTokenData: client.userTokens
        )
        client.api.livechatWS.sendMessage(liveChatSendData: liveChatSend)

        content = ""
        replyToMessage = nil
        composerFocused = true
    }

    private func saveEdit() {
        let trimmed = editingContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let editingMessageID, !trimmed.isEmpty else {
            return
        }

        client.hapticPress()
        let editSend = createLiveEditSendData(postID: editingMessageID, content: trimmed, userTokenData: client.userTokens)
        client.api.livechatWS.sendMessage(liveChatSendData: editSend)
        cancelEdit()
        composerFocused = true
    }

    private func requestDelete(_ message: LiveChatData) {
        guard isOwnMessage(message) else {
            return
        }

        pendingDeleteMessage = message
        showDeleteConfirm = true
    }

    private func confirmDelete() {
        guard let pendingDeleteMessage, let messageID = pendingDeleteMessage._id else {
            return
        }

        client.hapticPress()
        let deleteSend = createLiveDeleteSendData(messageToDelete: messageID, userTokenData: client.userTokens)
        client.api.livechatWS.sendMessage(liveChatSendData: deleteSend)
        messages.removeAll(where: { $0._id == messageID })

        if replyToMessage?._id == messageID {
            replyToMessage = nil
        }
        if editingMessageID == messageID {
            cancelEdit()
        }

        self.pendingDeleteMessage = nil
    }

    private func activeInputBinding() -> Binding<String> {
        if editingMessageID == nil {
            return $content
        }
        return $editingContent
    }

    private func messageRowID(_ message: LiveChatData) -> String {
        return message._id ?? message.id.uuidString
    }

    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool) {
        let action = {
            proxy.scrollTo("chat-bottom-anchor", anchor: .bottom)
        }

        DispatchQueue.main.async {
            if animated {
                withAnimation {
                    action()
                }
            } else {
                action()
            }
        }
    }

    private var composerBottomPadding: CGFloat {
        8 + customTabBarBottomReserve
    }

    private var chatBottomAnchorHeight: CGFloat {
        24 + customTabBarBottomReserve
    }

    private var customTabBarBottomReserve: CGFloat {
        customTabBarReserveIsActive ? design.customTabBarBottomContentInset : 0
    }

    private func replyPreview(for message: LiveChatData) -> String? {
        guard let replyID = message.message?.replyTo else {
            return nil
        }

        guard let repliedMessage = messages.first(where: { $0._id == replyID }) else {
            return "Replying to message"
        }

        let username = repliedMessage.user?.username ?? "unknown"
        let snippet = repliedMessage.message?.content ?? ""
        return "Reply to @\(username): \(snippet)"
    }
}

struct ChatMessageRow: View {
    @ObservedObject var client: Client
    let chatMessage: LiveChatData
    let isOwnMessage: Bool
    let isEditing: Bool
    @Binding var editingContent: String
    let replyPreview: String?

    let onReply: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSaveEdit: () -> Void
    let onCancelEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(chatMessage.user?.displayName ?? "Unknown")
                        .font(.subheadline.weight(.semibold))
                    Text("@\(chatMessage.user?.username ?? "unknown")")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                if let timestampText {
                    Text(timestampText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            if let replyPreview {
                Label(replyPreview, systemImage: "arrowshape.turn.up.left")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.secondary.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if isEditing {
                TextField("Edit message", text: $editingContent)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button("Save") {
                        onSaveEdit()
                    }
                    .disabled(editingContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    Button("Cancel") {
                        onCancelEdit()
                    }
                    .buttonStyle(.plain)
                }
            } else {
                if chatMessage.type == 6 {
                    Text(chatMessage.userJoin?.content ?? "user joined")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if chatMessage.type == 7 {
                    Text(chatMessage.userLeave?.content ?? "user left")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text(chatMessage.message?.content ?? "")
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if chatMessage.message?.edited == true {
                    Text("edited")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            if client.devMode?.isEnabled == true {
                Text(chatMessage._id ?? "no id")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 11)
        .padding(.leading, isOwnMessage ? 18 : 12)
        .padding(.trailing, 12)
        .interactCardSurface(
            tone: isOwnMessage ? .owner : .normal,
            cornerRadius: 14,
            lineWidth: 1,
            originalBackground: client.themeData.mainBackground,
            originalBorder: .gray
        )
        .overlay(alignment: .leading) {
            if isOwnMessage {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.20))
                    .frame(width: 4)
                    .padding(.vertical, 8)
                    .padding(.leading, 6)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                onReply()
            } label: {
                Label("Reply", systemImage: "arrowshape.turn.up.left")
            }
            .tint(.blue)

            if isOwnMessage {
                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(.orange)
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            if isOwnMessage {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .contextMenu {
            Button {
                onReply()
            } label: {
                Label("Reply", systemImage: "arrowshape.turn.up.left")
            }

            if isOwnMessage {
                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }

    private var timestampText: String? {
        guard let timestamp = chatMessage.message?.timeStamp else {
            return nil
        }

        return int64TimeFormatter(timestamp: timestamp)
    }
}
