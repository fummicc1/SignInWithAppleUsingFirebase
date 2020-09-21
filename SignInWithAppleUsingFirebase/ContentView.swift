//
//  ContentView.swift
//  SignInWithAppleUsingFirebase
//
//  Created by Fumiya Tanaka on 2020/09/20.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct ContentView: View {
    @Environment(\.window) var window
    @State private var loginState: LoginState = .idle
    @StateObject var controller: SignInWithAppleController = SignInWithAppleController()
    private let authClient: FirebaseAuthClientType = FirebaseAuthClient()
    
    @ViewBuilder
    var body: some View {
        if let credential = controller.credential {
            authClient.signIn(with: credential)
            return ProgressView("Loading")
        }
        Section {
            Text("Hello")
        }
        SignInWithAppleButton(
            onRequest: { request in
                loginState = .progress
                controller.startSignInWithAppleFlow(with: request)
            }, onCompletion: { _ in }
        ).onAppear {
            controller.window = window
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
