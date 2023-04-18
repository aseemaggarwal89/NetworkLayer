//
//  APIRequest.swift
//  ConnectUp
//
//  Created by Aseem Aggarwal on 27/02/22.
//

import Foundation
import Alamofire

protocol APIRequestProtocol {
    func urlPath() -> String
    func httpHeaders() -> HTTPHeaders
    func encoding() -> ParameterEncoding
    func parameters() -> Parameters?
    func httpMethod() -> HTTPMethod
    var uploadMultipartFormData: ((MultipartFormData) -> Void)? { get }
}
