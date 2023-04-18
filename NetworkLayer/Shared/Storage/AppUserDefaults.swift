//
//  AppUserDefaults.swift
//  NetworkLayer
//
//  Created by Aseem Aggarwal on 10/04/23.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key : String
    let defaultValue : T
    init(_ key : String , defaultValue : T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue : T {
        get{
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }set{
           UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
  
struct AppUserDefaults {
    @UserDefault(UserDefaults.key.token, defaultValue: "")
    static var token : String
}

extension UserDefaults {
    public enum key {
        static let token = "token"
    }
}
