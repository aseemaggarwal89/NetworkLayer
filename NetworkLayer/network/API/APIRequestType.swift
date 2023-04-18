//
//  APIRequestType.swift
//  NetworkLayer
//
//  Created by Aseem Aggarwal on 10/04/23.
//
import Foundation
import Alamofire

struct AppLoginRequestType {
    @APIRequestInfoType(httpMethod: .post, endPoint: LoginAPI.signIn, isContentLengthHeaderRequired: true)
    static var signIn: APIRequestInfo
    @APIRequestInfoType(httpMethod: .post, endPoint: LoginAPI.signUp, isContentLengthHeaderRequired: true)
    static var signUp: APIRequestInfo
    @APIRequestInfoType(httpMethod: .post, endPoint: LoginAPI.changePassword)
    static var resetPassword: APIRequestInfo
    @APIRequestInfoType(httpMethod: .post, endPoint: ProfileAPI.profileImgUpload, accessToken: false)
    static var uploadImage: APIRequestInfo
}

struct AppPostRequestType {
    @APIRequestInfoType(httpMethod: .post, endPoint: GroupsAPI.createPost, isContentLengthHeaderRequired: true, accessToken: false)
    static var createPost: APIRequestInfo
    
    @APIRequestInfoType(httpMethod: .put, endPoint: GroupsAPI.updatePost, isContentLengthHeaderRequired: true, accessToken: false)
    static var updatePost: APIRequestInfo
}
