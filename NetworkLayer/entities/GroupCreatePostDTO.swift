//
//  GroupCreatePostDTO.swift
//  NetworkLayer
//
//  Created by Aseem Aggarwal on 10/04/23.
//

import Foundation

struct GroupCreatePostDTO: Codable {
    let postId: String
}

struct GroupsSuccessModel: Codable {
    var message: String?
    
    enum CodingKeys: String, CodingKey {
        case message
    }
}
