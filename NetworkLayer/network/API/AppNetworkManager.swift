//
//  AppNetworkManager.swift
//  ConnectUp
//
//  Created by Aseem Aggarwal on 27/02/22.
//

import Foundation
import Alamofire
import Combine

enum Response<T> {
    case success(T)
    case successJson(String)
    case failure(APIError)
}

protocol NetworkManagerInjection {}
extension NetworkManagerInjection {
    var networkManager: AppNetworkProtocol {
        return AppDependencyInjection.networkManager
    }
}

public typealias AppParameters = [String: Any]

protocol AppNetworkProtocol {
    func loadRequest<T>(requestType: APIRequestInfo, param: AppParameters?, queryParams: [CVarArg], completion: @escaping (Response<T>) -> Void) where T: Codable
    func loadRequestMultiForm<T>(uploadAPIRequest: APIRequest, completion: @escaping (Response<T>) -> Void) where T: Codable
    func requestCancelUploadedItem()
}

extension AppNetworkProtocol {
    func loadRequest<T>(requestType: APIRequestInfo, completion: @escaping (Response<T>) -> Void) where T: Codable {
        loadRequest(requestType: requestType, param: nil, queryParams: [], completion: completion)
    }
}

class AppNetworkManager: BaseAPIClient, AppNetworkProtocol {
    private let networkQueue = DispatchQueue(label: "App API requests", qos: .userInteractive, attributes: .concurrent)
    static let shared = AppNetworkManager()
    
    init() {
        super.init(queue: networkQueue)
    }
    
    func loadRequest<T>(requestType: APIRequestInfo, param: AppParameters?, queryParams: [CVarArg], completion: @escaping (Response<T>) -> Void) {
        guard Connectivity.isConnectedToInternet() else {
            completion(.failure(APIError.internetNotAvailable))
            return
        }
        
        let loadRequestBlock = { [weak self] in
            let apiRequest = APIRequest(requestType: requestType, param: param, queryParams: queryParams)
            self?.loadRequest(apiRequest) { (response: APIResponse<T>) in
                switch response {
                case .decodedData(let apiData):
                    completion(.success(apiData.body))
                case .responeData(let data):
                    if (200 ... 299).contains(data.statusCode) {
                        print("Success")
                        let json = String(data: data.body, encoding: .utf8)
                        completion(.successJson(json ?? ""))
                    } else {
                        let apiError: APIError
                        if let serverError = try? data.decode(to: ServerErrorDTO.self) {
                            print("Error: \(serverError)")
                            if serverError.body.statusCode == 401 {
                                apiError = APIError.sessionExpired(serverError.body.messageToUser, serverError.body.statusCode)
                            } else if serverError.body.statusCode == 403 {
                                apiError = APIError.serverDown
                            } else {
                                apiError = APIError.serverError(serverError.body.messageToUser, serverError.body.statusCode)
                            }
                        } else {
                            apiError = APIError.serverError("Unknow server error", data.statusCode)
                        }
                        completion(.failure(apiError))
                    }
                    break
                case .failure(let apiError):
                    completion(.failure(apiError))
                }
            }
        }
        
        if requestType.isRefreshTokenRequired {
            // Update token from firebase
            FirebaseManager.shared.getRefreshToken { tokenResult in
                switch tokenResult {
                case .success(let token):
                    AppUserDefaults.token = token
                    loadRequestBlock()
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            loadRequestBlock()
        }
    }
    
    func loadRequestMultiForm<T>(uploadAPIRequest: APIRequest, completion: @escaping (Response<T>) -> Void) {
        let loadRequestBlock = { [weak self] in
            self?.loadRequestMultiForm(uploadAPIRequest) { (response: APIResponse<T>) in
                switch response {
                case .decodedData(let apiData):
                    completion(.success(apiData.body))
                case .responeData(let data):
                    if (200 ... 299).contains(data.statusCode) {
                        print("Success")
                        let json = String(data: data.body, encoding: .utf8)
                        completion(.successJson(json ?? ""))
                    } else {
                        let apiError: APIError
                        if let serverError = try? data.decode(to: ServerErrorDTO.self) {
                            print("Error: \(serverError)")
                            apiError = APIError.serverError(serverError.body.messageToUser, serverError.body.statusCode)
                        } else {
                            apiError = APIError.serverError("Unknow server error", data.statusCode)
                        }
                        completion(.failure(apiError))
                    }
                    break
                case .failure(let apiError):
                    completion(.failure(apiError))
                }
            }
        }
        
        if uploadAPIRequest.isRefreshTokenRequired() {
            // Update token from firebase
            FirebaseManager.shared.getRefreshToken { tokenResult in
                switch tokenResult {
                case .success(let token):
                    AppUserDefaults.token = token
                    loadRequestBlock()
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            loadRequestBlock()
        }
    }
    
    func requestCancelUploadedItem() {
        cancelUpload()
    }
}

struct ServerErrorDTO: Codable {
    let id, messageToUser, error: String
    let statusCode: Int
}
