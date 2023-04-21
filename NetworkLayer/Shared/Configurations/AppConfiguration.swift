//
//  AppConfiguration.swift
//  NetworkLayer
//
//  Created by Aseem Aggarwal on 10/04/23.
//

import Foundation

enum Environment: String {
    case Dev
    case Staging
}

protocol AppConfigurationProtocol {
    var baseUrl: String { get }
}

struct AppConfiguration: AppConfigurationProtocol {
    private let appEnv: Environment
    static let environmentProcessInfoKey = "appConfigration"

    var baseUrl: String {
        switch appEnv {
        case .Dev:
            return Bundle.main.infoDictionary?["BASE_URL_Dev"] as! String
        case .Staging:
            return Bundle.main.infoDictionary?["BASE_URL_Staging"] as! String
        }
    }

    init(appEnv: Environment) {
        self.appEnv = appEnv
    }
}

protocol ConfigurationInjection {}
extension ConfigurationInjection {
  var appConfiguration: AppConfigurationProtocol {
    return AppDependencyInjection.appConfiguration
  }
}

class AppSingletonInstance {
    static let shared = AppSingletonInstance()
    let networkService = AppNetworkManager()
}

struct AppDependencyInjection {
    static var appConfiguration: AppConfigurationProtocol {
        let environment = ProcessInfo.processInfo.environment[AppConfiguration.environmentProcessInfoKey] ?? Environment.Staging.rawValue
        return AppConfiguration(appEnv: Environment.init(rawValue: environment) ?? .Staging)
    }

    static var networkManager: AppNetworkProtocol {
        AppSingletonInstance.shared.networkService
    }
    
    static var uploadAPIRepository: UploadAPIRepositoryProtocol {
        UploadUseCase()
    }
    
    static var groupsDetailsAPIRepository: GroupsDetailsAPIRepositoryProtocol {
        GroupsDetailsAPIRepository()
    }
}
