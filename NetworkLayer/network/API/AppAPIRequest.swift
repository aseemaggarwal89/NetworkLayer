//
//  AppAPIRequest.swift
//  ConnectUp
//
//  Created by Aseem Aggarwal on 27/02/22.
//

import Foundation
import Alamofire

struct RequestConstants {
    static let RequestType = "X-Requested-With"
    static let RequestValue = "XMLHttpRequest"
    
    static let ContentType = "Content-Type"
    static let ContentValue = "application/json"
    static let ContentValuePlain = "text/plain"
    static let AcceptEncodingValue = "gzip, deflate, br"
    static let AcceptEncoding      = "Accept-Encoding"
    static let AcceptField         = "Accept"
    static let AcceptFieldValue    = "*/*"
    static let ConnectionField     = "Connection"
    static let ConnectionFieldValue     = "keep-alive"

    static let ContentLengthField = "Content-Length"
    
    static let Authorization = "Authorization"
    static let MultiPartValue = "multipart/form-data"
    static let Bearer = "Bearer"
    static let multiPartValue = "multipart/form-data"
    static let errorCode = "statusCode"
    static let requestTimeOut = "Request time out"
    static let sessionToken = "x-session-token"
}


struct APIRequest: APIRequestProtocol, ConfigurationInjection {
    private let requestType: APIRequestInfo
    var uploadMultipartFormData: ((MultipartFormData) -> Void)?
    private var param: Parameters? = nil
    private let queryParams: [CVarArg]
    
    init(requestType: APIRequestInfo, param: Parameters? = nil,
         uploadMultipartFormData: ((MultipartFormData) -> Void)? = nil,
         queryParams: [CVarArg]) {
        self.requestType = requestType
        self.uploadMultipartFormData = uploadMultipartFormData
        self.param = param
        self.queryParams = queryParams
    }
    
    init(requestType: APIRequestInfo, param: Parameters? = nil,uploadMultipartFormData: ((MultipartFormData) -> Void)? = nil) {
        self.requestType = requestType
        self.uploadMultipartFormData = uploadMultipartFormData
        self.param = param
        self.queryParams = []
    }
    
    func parameters() -> Parameters? {
        return param
    }
        
    func httpMethod() -> HTTPMethod {
        return requestType.httpMethod
    }
    
    func encoding() -> ParameterEncoding {
        return requestType.encoding
    }
    
    func httpHeaders() -> Alamofire.HTTPHeaders {
        var headers: HTTPHeaders = requestType.headers
        if let contentLengthHeader = getContentLengthHeader() {
            headers.add(contentLengthHeader)
        }
        
        return headers
    }
    
    func urlPath() -> String {
        let completePath = requestType.baseURL + String(format: requestType.endPoint, arguments: queryParams)
        print(completePath)
        return completePath
    }
    
    private func getContentLengthHeader() -> HTTPHeader? {
        guard let param = param else {
            return nil
        }
        
        guard let paramJson = String.stringify(json: param, prettyPrinted: true) else {
            return nil
        }
        
        guard requestType.isContentLengthHeaderRequired else {
            return nil
        }
        
        guard let data = paramJson.data(using: .utf8) else {
            return nil
        }
        
        return HTTPHeader(name: RequestConstants.ContentLengthField, value: "\(data.count)")
    }
    
    func isRefreshTokenRequired() -> Bool {
        return requestType.isRefreshTokenRequired
    }
}

struct APIRequestInfo {
    let httpMethod: HTTPMethod
    let baseURL: String
    let endPoint: String
    let headers: HTTPHeaders
    let encoding: ParameterEncoding
    let isRefreshTokenRequired: Bool
    let isContentLengthHeaderRequired: Bool
}

@propertyWrapper
struct APIRequestInfoType {
    let httpMethod: HTTPMethod
    let endPoint: String
    var encoding: ParameterEncoding = JSONEncoding.default
    var isContentLengthHeaderRequired: Bool = false
    var accessToken: Bool = false
    var headers: HTTPHeaders = defaultHeaders()
    var baseURL: String = AppDependencyInjection.appConfiguration.baseUrl
    
    var wrappedValue: APIRequestInfo {
        var requestHeaders = headers
        var isRefreshTokenRequired = false
        if accessToken {
            isRefreshTokenRequired = true
            requestHeaders[RequestConstants.Authorization] = RequestConstants.Bearer+" " + "{saved JWT Token}"
        }
        return APIRequestInfo(httpMethod: httpMethod, baseURL: baseURL, endPoint: endPoint, headers: requestHeaders, encoding: encoding, isRefreshTokenRequired: isRefreshTokenRequired, isContentLengthHeaderRequired: isContentLengthHeaderRequired)
    }
        
    static func defaultHeaders() -> HTTPHeaders {
        let headers: HTTPHeaders = [RequestConstants.ContentType: RequestConstants.ContentValue,
                                    RequestConstants.AcceptEncoding:RequestConstants.AcceptEncodingValue,
                                    RequestConstants.AcceptField: RequestConstants.AcceptFieldValue,
                                    RequestConstants.ConnectionField: RequestConstants.ConnectionFieldValue]
        
        return headers
    }
}
