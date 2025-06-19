//
//  PeoPlingApp.swift
//  PeoPling
//
//  Created by 맥14 on 6/19/25.
//

import SwiftUI
import FirebaseCore

@main
struct PeoplingApp: App {
    @StateObject private var authVM = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authVM.isLoggedIn {
                MainTabView()
                    .environmentObject(authVM)
            } else {
                LoginView()
                    .environmentObject(authVM)
            }
        }
    }
}

