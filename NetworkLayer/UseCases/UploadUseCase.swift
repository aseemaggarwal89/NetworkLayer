//
//  UploadUseCase.swift
//  NetworkLayer
//
//  Created by Aseem Aggarwal on 10/04/23.
//

import Foundation

protocol UploadAPIRepositoryInjection {}
extension UploadAPIRepositoryInjection {
    var uploadAPIRepository: UploadAPIRepositoryProtocol {
        return AppDependencyInjection.uploadAPIRepository
    }
}
protocol UploadAPIRepositoryProtocol {
    func uploadImage(image: UploadImageDTO?, response: @escaping (Response<UploadImageResponseDTO>) -> Void)
}

struct UploadUseCase: UploadAPIRepositoryProtocol {
    func uploadImage(image: UploadImageDTO?, response: @escaping (Response<UploadImageResponseDTO>) -> Void) {
        var param = image?.dictionary
        param = param.map({
            var dict = $0
            dict["file"] = image?.file
            return dict
        })
        
        let apiRequest = APIRequest(requestType: AppLoginRequestType.uploadImage, param: nil) { formData in
            for (key,value) in  param ?? [:] {
                if ((value as? Data) != nil) {
                    formData.append(value as! Data, withName: key, fileName: image?.fileName, mimeType: "multipart/form-data")
                }else {
                    formData.append(("\(value)").data(using: .utf8)!, withName: key)
                }
            }
        }
        
        networkManager.loadRequestMultiForm(uploadAPIRequest: apiRequest, completion: response)
    }
}
extension UploadUseCase: NetworkManagerInjection {}
