//
//  FilesData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2025-03-25.
//


struct FileTypeData: Decodable {
    var error: Bool
    var type: String
}

struct FileUploadRes: Decodable {
    var success: Bool
    var fileID: String
    var cdnURL: String
    var thumbnailURL: String
}
