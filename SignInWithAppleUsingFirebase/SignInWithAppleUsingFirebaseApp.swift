//
//  SignInWithAppleUsingFirebaseApp.swift
//  SignInWithAppleUsingFirebase
//
//  Created by Fumiya Tanaka on 2020/09/20.
//

import SwiftUI
import FirebaseCore

@main
struct SignInWithAppleUsingFirebaseApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    private var window: UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let delegate = scene.delegate as? UIWindowSceneDelegate,
              let window = delegate.window else {
            return nil
        }
        return window
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.window, window)
        }
    }
}
