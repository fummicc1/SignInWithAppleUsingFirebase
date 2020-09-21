//
//  SignInWithApple.swift
//  SignInWithAppleUsingFirebase
//
//  Created by Fumiya Tanaka on 2020/09/20.
//

import Foundation
import Combine
import CryptoKit
import AuthenticationServices
import FirebaseAuth

enum LoginState {
    case idle
    case progress
    case successful
    case fail(Error)
}

final class SignInWithAppleController: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    var window: UIWindow?
    // Unhashed nonce.
    private var currentNonce: String?
    
    var credential: AuthCredential? {
        willSet {
            objectWillChange.send()
        }
    }
    var error: Error? {
        willSet {
            objectWillChange.send()
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        window ?? UIWindow()
    }
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow(with authRequest: ASAuthorizationAppleIDRequest? = nil) {
        let request: ASAuthorizationAppleIDRequest
        if let authRequest = authRequest {
            request = authRequest
        } else {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            request = appleIDProvider.createRequest()
        }
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let nonce = currentNonce else {
            return
        }
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        guard let tokenData = credential.identityToken, let token = String(data: tokenData, encoding: .utf8) else {
            return
        }
        let authCredential = OAuthProvider.credential(withProviderID: "com.apple", idToken: token, rawNonce: nonce)
        self.credential = authCredential
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.error = error
    }
}
