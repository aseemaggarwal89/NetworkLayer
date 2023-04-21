//
//  BaseAPIClient.swift
//  ConnectUp
//
//  Created by Aseem Aggarwal on 27/02/22.
//

import Foundation
import Alamofire

enum APIResponse<T> {
    case decodedData(APIData<T>)
    case responeData(APIData<Data>)
    case failure(APIError)
}

protocol APIClient {
    func loadRequest<T>(_ request: APIRequestProtocol, completion: @escaping (APIResponse<T>) -> Void) where T: Decodable
    func loadRequestMultiForm<T>(_ request: APIRequestProtocol, completion: @escaping (APIResponse<T>) -> Void) where T: Decodable
}

class BaseAPIClient: APIClient {
    var sessionManager: Session
    private let networkConnectivity: NetworkConnectivity

    init(queue: DispatchQueue) {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60
        sessionConfig.timeoutIntervalForResource = 60
        self.sessionManager = Session(configuration: sessionConfig, rootQueue: queue)
        self.networkConnectivity = NetworkConnectivity()
        self.networkConnectivity.startNetworkReachabilityObserver()
    }
    
    deinit {
        self.networkConnectivity.stopListening()
    }
    
    func loadRequest<T>(_ request: APIRequestProtocol, completion: @escaping (APIResponse<T>) -> Void) {
        fetch(request) { success, error in
            guard let success = success else {
                completion(APIResponse.failure(error ?? APIError.requestFailed(error: "Unknown server error")))
                return
            }

            do {
                let response = try success.decode(model: T.self)
                completion(.decodedData(response))
            } catch let error {
                print("Decoded Error: \(error)")
                completion(.responeData(success))
            }
        }
    }
    
    func loadRequestMultiForm<T>(_ request: APIRequestProtocol, completion: @escaping (APIResponse<T>) -> Void) {
        uploadFile(request) { success, error in
            guard let success = success else {
                completion(APIResponse.failure(error ?? APIError.requestFailed(error: "Unknown server error")))
                return
            }

            do {
                let response = try success.decode(model: T.self)
                completion(.decodedData(response))
            } catch let error {
                print("Decoded Error: \(error)")
                completion(.responeData(success))
            }
        }
    }
    
    private func fetch(_ request: APIRequestProtocol, _ completion: @escaping (_ success: APIData<Data>?, _ error: APIError?) -> Void) {
        guard networkConnectivity.isConnectedToInternet() else {
            completion(nil, APIError.internetNotAvailable)
            return
        }
        sessionManager.request(request.urlPath(),
                               method: request.httpMethod(),
                               parameters: request.parameters(),
                               encoding: request.encoding(),
                               headers: request.httpHeaders())
            .responseData(completionHandler: { (response: AFDataResponse<Data>) in
                guard let httpResponse = response.response else {
                    completion(nil, APIError.requestFailed(error: response.error?.localizedDescription ?? "Unknown server error"))
                    return
                }
                switch response.result {
                    case let .success(value):
                    completion(APIData(statusCode: httpResponse.statusCode, body: value), nil)
                case let .failure(error):
                    completion(nil, APIError.serverError(error.localizedDescription, httpResponse.statusCode))
                }
            })
    }
    
    func uploadFile(_ request: APIRequestProtocol,
                _ completion: @escaping (_ success: APIData<Data>?, _ error: APIError?) -> Void) {
        guard networkConnectivity.isConnectedToInternet() else {
            completion(nil, APIError.internetNotAvailable)
            return
        }
        
        sessionManager.upload(multipartFormData: { (formData) in
            request.uploadMultipartFormData?(formData)
        }, to: request.urlPath(), method: request.httpMethod(), headers: request.httpHeaders()).responseData { (response: AFDataResponse<Data>) in
                guard let httpResponse = response.response else {
                    completion(nil, APIError.requestFailed(error: response.error?.localizedDescription ?? "Unknown server error"))
                    return
                }
                switch response.result {
                    case let .success(value):
                    completion(APIData(statusCode: httpResponse.statusCode, body: value), nil)
                case let .failure(error):
                    completion(nil, APIError.serverError(error.localizedDescription, httpResponse.statusCode))
                }
            }
    }
    
    func cancelUpload() {
        sessionManager.session.getTasksWithCompletionHandler { (_, uploadTasks, _) in
                uploadTasks.forEach { $0.cancel() }
        }
    }
}

struct AppErrorCode {
    static let firebaseLoginError = 1010
    static let googleAuthSignError = 1011

}

enum APIError: Error, LocalizedError {
    case networkError(String, Int)
    case internetNotAvailable
    case requestFailed(error: String)
    case serverError(String, Int)
    case decodingFailure(error: String)
    case sessionExpired(String, Int)
    case serverDown
    case currentUserNotavailable
    case signInError(String)
    case refreshTokenError(String)

    public var errorDescription: String? {
        switch self {
        case let .networkError(error, _):
            return error
        case let .serverError(error, _):
            return error
        case let .requestFailed(error: error):
            return error
        case .internetNotAvailable:
            return "Your internet connection in not connected"
        case let .decodingFailure(error: error):
            return error
        case let .sessionExpired(error, code):
            return "Server Error: \(error) code: \(code)"
        case .serverDown:
            return "Server Down"
        case let .signInError(error):
            return error
        case .currentUserNotavailable:
            return "User is not authenticated. Please login"
        case let .refreshTokenError(error):
            return "Error: \(error)"
        }
    }
}

