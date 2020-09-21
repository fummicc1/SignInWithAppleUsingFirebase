//
//  Environment.swift
//  SignInWithAppleUsingFirebase
//
//  Created by Fumiya Tanaka on 2020/09/21.
//

import Foundation
import SwiftUI

final class WindowKey: EnvironmentKey {
    static var defaultValue: UIWindow? = nil
}

extension EnvironmentValues {
    var window: UIWindow? {
        get {
            self[WindowKey.self]
        }
        set {
            self[WindowKey.self] = newValue
        }
    }
}
