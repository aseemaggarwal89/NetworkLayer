//
//  APIRequestType.swift
//  NetworkLayer
//
//  Created by Aseem Aggarwal on 10/04/23.
//
import Foundation
import Alamofire

struct AppLoginRequestType {
    @AppRequestWrapper(httpMethod: .post, endPoint: LoginAPI.signIn, encoding: JSONEncoding.default, isContentLengthHeaderRequired: true)
    static var signIn: AppRequestType
    @AppRequestWrapper(httpMethod: .post, endPoint: LoginAPI.signUp, encoding: JSONEncoding.default, isContentLengthHeaderRequired: true)
    static var signUp: AppRequestType
    @AppRequestWrapper(httpMethod: .post, endPoint: LoginAPI.changePassword, encoding: JSONEncoding.default)
    static var resetPassword: AppRequestType
    @AppRequestWrapper(httpMethod: .post, endPoint: ProfileAPI.profileImgUpload, encoding: JSONEncoding.default, accessToken: false)
    static var uploadImage: AppRequestType
}

struct AppPostRequestType {
    @AppRequestWrapper(httpMethod: .post, endPoint: GroupsAPI.createPost, encoding: JSONEncoding.default, isContentLengthHeaderRequired: true, accessToken: false)
    static var createPost: AppRequestType
    @AppRequestWrapper(httpMethod: .put, endPoint: GroupsAPI.updatePost, encoding: JSONEncoding.default, isContentLengthHeaderRequired: true, accessToken: false)
    static var updatePost: AppRequestType
    
    @AppRequestWrapper(httpMethod: .get, endPoint: GroupsAPI.groupPost, encoding: URLEncoding.queryString, isContentLengthHeaderRequired: false, accessToken: true)
    static var getGroupPosts: AppRequestType
}
