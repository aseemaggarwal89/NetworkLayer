//
//  UploadImageDTO.swift
//  NetworkLayer
//
//  Created by Aseem Aggarwal on 10/04/23.
//

import Foundation

enum UploadFileType: String {
    case audio = "audio"
    case document = "document"
    case image = "images"
    case video = "video"
    
    func fileExtentions() -> String {
        switch self {
        case .image:
            return ".jpeg"
        case .video:
            return ".mp4"
        case .document:
            return ".pdf"
        case .audio:
            return ".mp3"
        }
    }
    
    func uploadLimit() -> Int {
        switch self {
        case .image:
            return 5
        case .video:
            return 1
        case .document:
            return 5
        case .audio:
            return 1
        }
    }
}

// MARK: - UploadImage
struct UploadImageDTO: Codable {
    let file: Data?
    let uploadBinaryType: String
    let type: String
    let fileName: String
    
    enum CodingKeys: String, CodingKey {
        case file, type, fileName
        case uploadBinaryType = "upload_binary_type"
    }

    init(file: Data?, uploadBinaryType: UploadFileType, type: String) {
        self.init(file: file, uploadBinaryType: uploadBinaryType, type: type, fileName: "\(Date().toString(formatType: .ddmmyyhhmmss))\(uploadBinaryType.fileExtentions())")
    }
    
    init(file: Data?, uploadBinaryType: UploadFileType, type: String, fileType: String) {
        let fileName = Date().toString(formatType: .ddmmyyhhmmss)
        self.init(file: file, uploadBinaryType: uploadBinaryType, type: type, fileName:"\(fileName).\(fileType)")
    }

    init(file: Data?, uploadBinaryType: UploadFileType, type: String, fileName: String) {
        self.file = file
        self.uploadBinaryType = uploadBinaryType.rawValue
        self.type = type
        self.fileName = fileName
    }

    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        file = try container.decodeIfPresent(Data.self, forKey: .file)
        uploadBinaryType = try container.decodeIfPresent(String.self, forKey: .uploadBinaryType) ?? ""
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
        fileName = try container.decodeIfPresent(String.self, forKey: .fileName) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(file, forKey: .file)
        try container.encode(uploadBinaryType, forKey: .uploadBinaryType)
        try container.encode(type, forKey: .type)
    }
}

// MARK: - UploadImage Response
struct UploadImageResponseDTO: Codable {
    let id: Int
    let imageUID: String
    let url: String
    let thumbnailUrl: String?
    enum CodingKeys: String, CodingKey {
        case id, imageUID, url, thumbnailUrl
    }
}
