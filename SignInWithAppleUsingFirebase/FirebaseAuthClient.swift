//
//  FirebaseAuthClient.swift
//  SignInWithAppleUsingFirebase
//
//  Created by Fumiya Tanaka on 2020/09/21.
//

import Foundation
import FirebaseAuth
import Combine

public enum FirebaseAuthClientError: Error {
    case noUser
}

public protocol FirebaseAuthClientType {
    func signIn(with credential: AuthCredential) -> AnyPublisher<FirebaseAuth.User, Error>
}

class FirebaseAuthClient: FirebaseAuthClientType {
    
    private let auth: Auth
    
    init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }
    
    public func signIn(with credential: AuthCredential) -> AnyPublisher<User, Error> {
        Future<User, Error> { [weak self] promise in
            self?.auth.signIn(with: credential, completion: { (result, error) in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let result = result else {
                    promise(.failure(FirebaseAuthClientError.noUser))
                    return
                }
                promise(.success(result.user))
            })
        }.eraseToAnyPublisher()
    }
}
