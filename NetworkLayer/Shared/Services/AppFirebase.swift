//
//  AppFirebase.swift
//  NetworkLayer
//
//  Created by Aseem Aggarwal on 10/04/23.
//

import Foundation
import Firebase

class FirebaseManager {
    static let shared = FirebaseManager()
    
    func loginUser(customToken: String, completion: @escaping (User?, APIError?) -> Void) {
        Auth.auth().signIn(withCustomToken: customToken) { dataResult, error in
            if let dataResult = dataResult {
                completion(dataResult.user, nil)
            } else if let error = error {
                completion(nil, APIError.signInError(error.localizedDescription))
            } else {
                completion(nil, APIError.signInError("Unknown firebase error"))
            }
        }
    }

    func getRefreshToken() async throws -> String {
      return try await withUnsafeThrowingContinuation { continuation in
          getRefreshToken { result in
              switch result {
              case .success(let token):
                  continuation.resume(returning: token)
              case .failure(let error):
                  continuation.resume(throwing: error)
              }
          }
      }
    }

    func getRefreshToken(completionBlock: @escaping (Result<String, APIError>) -> Void) {
        guard let currentUser = getUser() else {
            completionBlock(.failure(.currentUserNotavailable))
            return
        }
        
        currentUser.getIDTokenResult(forcingRefresh: false, completion: { tokenResult, error in
            guard let tokenResult = tokenResult else {
                completionBlock(.failure(APIError.refreshTokenError(error?.localizedDescription ?? "Unknown error while fetching refresh token")))
              return
            }
            
            completionBlock(.success(tokenResult.token))
        })
    }
    
    func isUserSigned() -> Bool {
        return getUser() != nil
    }
    
    func logOutUser() {
       do {
         try Auth.auth().signOut()
       } catch let signOutError as NSError {
         print("Error signing out: %@", signOutError)
       }
    }
    
    func getUser() -> User? {
        return Auth.auth().currentUser
    }
}
