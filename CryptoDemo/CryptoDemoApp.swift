//
//  CryptoDemoApp.swift
//  CryptoDemo
//
//  Created by Philophobic on 30/10/24.
//

import SwiftUI

@main
struct CryptoDemoApp: App {
    
    @StateObject private var vm = HomeViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .navigationBarHidden(true)
            }
            .environmentObject(vm)
        }
    }
}
