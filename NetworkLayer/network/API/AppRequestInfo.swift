//
//  APIRequestInfo.swift
//  NetworkLayer
//
//  Created by Aseem Aggarwal on 18/04/23.
//

import Foundation
import Alamofire

protocol AppRequestType {
    var httpMethod: HTTPMethod { get }
    var baseURL: String { get }
    var endPoint: String { get }
    var headers: HTTPHeaders { get }
    var encoding: ParameterEncoding { get }
    var isRefreshTokenRequired: Bool { get }
    var isContentLengthHeaderRequired: Bool { get }
}

struct AppRequestInfo: AppRequestType {
    var httpMethod: Alamofire.HTTPMethod
    var baseURL: String
    var endPoint: String
    var headers: Alamofire.HTTPHeaders
    var encoding: Alamofire.ParameterEncoding
    var isRefreshTokenRequired: Bool
    var isContentLengthHeaderRequired: Bool
}

@propertyWrapper
struct AppRequestWrapper {
    let httpMethod: HTTPMethod
    let endPoint: String
    let encoding: ParameterEncoding
    var isContentLengthHeaderRequired: Bool = false
    var accessToken: Bool = false
    var headers: HTTPHeaders = defaultHeaders()
    var baseURL: String = AppDependencyInjection.appConfiguration.baseUrl
    
    var wrappedValue: AppRequestType {
        var requestHeaders = headers
        var isRefreshTokenRequired = false
        if accessToken {
            isRefreshTokenRequired = true
            requestHeaders[RequestConstants.Authorization] = RequestConstants.Bearer+" " + "{saved JWT Token}"
        }
        return AppRequestInfo(httpMethod: httpMethod, baseURL: baseURL, endPoint: endPoint, headers: requestHeaders, encoding: encoding, isRefreshTokenRequired: isRefreshTokenRequired, isContentLengthHeaderRequired: isContentLengthHeaderRequired)
    }
        
    static func defaultHeaders() -> HTTPHeaders {
        let headers: HTTPHeaders = [RequestConstants.ContentType: RequestConstants.ContentValue,
                                    RequestConstants.AcceptEncoding:RequestConstants.AcceptEncodingValue,
                                    RequestConstants.AcceptField: RequestConstants.AcceptFieldValue,
                                    RequestConstants.ConnectionField: RequestConstants.ConnectionFieldValue]
        
        return headers
    }
}
