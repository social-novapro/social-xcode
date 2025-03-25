//
//  Files.swift
//  social-apple
//
//  Created by Daniel Kravec on 2025-03-25.
//

import Foundation

class FilesAPI: API_Base {
    func getFileType(selectedFileName: String) async throws -> FileTypeData {
        let APIUrl = baseAPIurl + "/cdn/fileType/" + selectedFileName;
        
        do {
            let data:FileTypeData = try await apiHelper.asyncRequestData(urlString: APIUrl, httpMethod: "GET");
            
            return data;
        } catch {
            throw ErrorData(code: "Z001", msg: "Uknown", error: true)
        }
    }
    
    func uploadMedia(selectedFile: URL) async throws -> FileUploadRes {
        let fileName = selectedFile.lastPathComponent;
        let fileType = try await self.getFileType(selectedFileName: fileName);
        let APIUrl = baseAPIurl + "/cdn/" + fileType.type + "/";

        do {
            let data:FileUploadRes = try await apiHelper.asyncRequestFileUpload(urlString: APIUrl, fileURL: selectedFile, httpMethod: "POST");
            return data;
        } catch {
            throw ErrorData(code: "Z001", msg: "Uknown", error: true)
        }
    }
}
