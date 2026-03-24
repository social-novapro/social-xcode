//
//  MediaUploadView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2025-03-25.
//
import SwiftUI
import UniformTypeIdentifiers
import PhotosUI
import AVKit

struct AttachmentView: View {
    @ObservedObject var client: Client
    @Binding var attachments: [AttachmentData]?
    
    var body: some View {
        VStack {
            ForEach($attachments ?? []) {attachment in
                HStack {
                    if attachment.type.wrappedValue == "image" {
                        VStack {
                            AsyncImage(url: URL(string: attachment.url.wrappedValue)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 30, height: 30)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 300, height: 300)
                                case .failure:
                                    Image(systemName: "photo")
                                        .frame(width: 30, height: 30)
                                @unknown default:
                                    EmptyView()
                                }
                            }                        }
                    } else if attachment.type.wrappedValue == "video"  {
                        VideoPlayerView(attachmentUrl: attachment.url)
                   }
               }

            }
        }
    }
}
struct VideoPlayerView: View {
    @Binding public var attachmentUrl: String
    @State private var player = AVPlayer()

    var body: some View {
        VideoPlayer(player: player)
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden()
            .onAppear {
                let url = URL(string: attachmentUrl)!
               
               player = AVPlayer(url: url)
               player.play()
                print("Play video")
               
            }
            .onDisappear {
               player.pause()
            }
   }
}

struct MediaUploadView: View {
    @ObservedObject var client: Client
    @ObservedObject var postCreation: PostCreation
    
    @State private var selectedItem: PhotosPickerItem?
#if !os(macOS)

    @State private var selectedImage: UIImage?
#endif
    @State private var selectedVideoURL: URL?
    @State private var selectedFileURL: URL?

    @State private var isUploading = false
    @State private var uploadStatus: String = ""

    
    var body: some View {
        VStack(spacing: 20) {
            
            PhotosPicker("Pick Photo",
                         selection: $selectedItem,
                         matching: .any(of: [.images, .videos])) // <- combine filters
            
            if selectedItem != nil {
                Button("Upload File") {
                    isUploading = true // Start uploading
                    getURL(item: selectedItem!) { result in
                        switch result {
                        case .success(let url):
                            Task {
                                do {
                                    let response = try await client.api.media.uploadMedia(selectedFile: url)
                                    if response.success {
                                        uploadStatus = "Media uploaded successfully! Media ID: \(response.fileID)"
                                        self.postCreation.addToPostContent(text: client.api.apiHelper.baseAPIurl + "/cdn\(response.cdnURL)")
                                    } else {
                                        uploadStatus = "Failed to upload media."
                                    }
                                } catch {
                                    uploadStatus = "Failed to upload media."
                                }
                                isUploading = false // End uploading
                            }
                        case .failure(_):
                            uploadStatus = "Failed to upload media."
                        }
                    }
                }
                .disabled(isUploading)

            }
            
            if isUploading {
                ProgressView()
            }
            
            Text(uploadStatus)
                .foregroundColor(.gray)
        }
        .padding()
    }
}


func getURL(item: PhotosPickerItem, completionHandler: @escaping (_ result: Result<URL, Error>) -> Void) {
    // Step 1: Load as Data object.
    item.loadTransferable(type: Data.self) { result in
        switch result {
        case .success(let data):
            if let contentType = item.supportedContentTypes.first {
                // Step 2: make the URL file name and a get a file extention.
                let url = getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).\(contentType.preferredFilenameExtension ?? "")")
                if let data = data {
                    do {
                        // Step 3: write to temp App file directory and return in completionHandler
                        try data.write(to: url)
                        completionHandler(.success(url))
                    } catch {
                        completionHandler(.failure(error))
                    }
                }
            }
        case .failure(let failure):
            completionHandler(.failure(failure))
        }
    }
}

/// from: https://www.hackingwithswift.com/books/ios-swiftui/writing-data-to-the-documents-directory
func getDocumentsDirectory() -> URL {
    // find all possible documents directories for this user
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    // just send back the first one, which ought to be the only one
    return paths[0]
}


