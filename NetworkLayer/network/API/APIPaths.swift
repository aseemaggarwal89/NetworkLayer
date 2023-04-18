//
//  APIPaths.swift
//  NetworkLayer
//
//  Created by Aseem Aggarwal on 10/04/23.
//

import Foundation

struct LoginAPI {
    static let signIn = "/api/login_v3"
    static let signUp = "/api/register"
    static let changePassword = "/api/change_password_using_otp"
}

struct ProfileAPI {
    static let profileImgUpload = "/api/user/upload_image"
}


struct GroupsAPI {
    static let createPost = "/api/group/%@/post"
    static let updatePost = "/api/group/%@/post/%@"
}
