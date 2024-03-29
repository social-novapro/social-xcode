//
//  LiveChatWebSocket.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-16.
//

// https://medium.com/@ios_guru/swiftui-and-websocket-connectivity-478aa5fddfc7
//https://chat.openai.com/c/585d2ab0-1d60-4721-a21d-5f57fe7bf285
import Foundation

class LiveChatWebSocket: ObservableObject {
    @Published var receivedDataQueue: [LiveChatData] = []

    private var webSocketTask: URLSessionWebSocketTask!
    var tokens:Bool = false
    var wsURL: String
    
    var userTokens: UserTokenData
    
    init(baseURL: String, userTokensProv: UserTokenData) {
        self.userTokens = userTokensProv
        
        self.wsURL = baseURL
        self.wsURL.replace("http", with: "ws")
        self.wsURL.replace("/v1", with: "/?userID=\(self.userTokens.userID)")
    }
    
    func connectWS() {
        let url = URL(string: wsURL)!
        let session = URLSession(configuration: .default)

        webSocketTask = session.webSocketTask(with: url)
        receiveData()
        webSocketTask.resume()
    }

    private func receiveData() {
        webSocketTask.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    do {
                        let decodedData = try JSONDecoder().decode(LiveChatData.self, from: data)
                        DispatchQueue.main.async {
                            self.addToQueue(decodedData)
                        }
                    } catch {
                        print("Error decoding JSON from data: \(error)")
                    }
                case .string(let text):
                    print("Received JSON string: \(text)")

                    do {
                        // Assuming LiveChatData can be decoded directly from the text
                        let decodedData = try JSONDecoder().decode(LiveChatData.self, from: text.data(using: .utf8)!)
                        DispatchQueue.main.async {
                            self.addToQueue(decodedData)
                        }
                    } catch {
                        print("Error decoding JSON from text: \(error)")
                    }
                @unknown default:
                    print("Unexpected receivent")
                }
                self.receiveData() // Continue to listen for more messages
            case .failure(let error):
                print("WebSocket receive error: \(error)")
            }
        }
    }

    private func addToQueue(_ newData: LiveChatData) {
        receivedDataQueue.append(newData)
        processQueue()
    }

    private func processQueue() {
        guard !receivedDataQueue.isEmpty else {
            return
        }

          // Process the first item in the queue
        let processedData = receivedDataQueue.removeFirst()

          // Handle the processed data as needed
        print("Processed data: \(processedData))")

          // Continue processing the queue
        processQueue()
      }

    func isTyping(userTokenData: UserTokenData) {
        
    }
    
    func stoppedTyping(userTokenData: UserTokenData) {
        
    }
    
    func sendMessage(liveChatSendData: LiveChatSendData) {
        do {
            self.tokens = true
            let encodedData = try JSONEncoder().encode(liveChatSendData)

            if let jsonString = String(data: encodedData, encoding: .utf8) {
                print("sending json : " + jsonString)
                guard webSocketTask.state == .running else {
                    print("WebSocket is not open. Cannot send data.")
                    return
                }

                webSocketTask.send(.string(jsonString)) { error in
                    if let error = error {
                        print("WebSocket send error: \(error)")
                        // Handle the error appropriately, e.g., reconnect or display a message to the user.
                    }
                }
            } else {
                print("Failed to convert JSON Data to String.")
            }
        } catch {
            print("Error encoding JSON: \(error)")
        }
    }
    
    // Handle cleanup on deinit if needed
    deinit {
        if (webSocketTask != nil) {
            webSocketTask.cancel(with: .goingAway, reason: nil)
        }
    }
    func killConnection() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }
}
