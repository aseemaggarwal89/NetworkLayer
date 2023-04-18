//
//  PostUseCase.swift
//  NetworkLayer
//
//  Created by Aseem Aggarwal on 10/04/23.
//

import Foundation
import Alamofire

protocol GroupsDetailsAPIRepositoryInjection {}
extension GroupsDetailsAPIRepositoryInjection {
    var groupsDetailsAPIRepository: GroupsDetailsAPIRepositoryProtocol {
        return AppDependencyInjection.groupsDetailsAPIRepository
    }
}
protocol GroupsDetailsAPIRepositoryProtocol {
    func createPost(groupId: String, parameter: Parameters, response: @escaping (Response<GroupCreatePostDTO?>) -> Void)
}

struct GroupsDetailsAPIRepository: GroupsDetailsAPIRepositoryProtocol {
    func createPost(groupId: String, parameter: Alamofire.Parameters, response: @escaping (Response<GroupCreatePostDTO?>) -> Void) {
        networkManager.loadRequest(requestType: AppPostRequestType.createPost, param: parameter, queryParams: [groupId], completion: response)
    }
    
    func updatePost(groupId: String, postId: String, parameter: Parameters, response: @escaping (Response<GroupsSuccessModel?>) -> Void) {
        
        networkManager.loadRequest(requestType: AppPostRequestType.updatePost, param: parameter, queryParams: [groupId, postId], completion: response)
    }
}

extension GroupsDetailsAPIRepository: NetworkManagerInjection {}
