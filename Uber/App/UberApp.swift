//
//  UberApp.swift
//  Uber
//
//  Created by Nilay on 12/11/23.
//

import SwiftUI

@main
struct UberApp: App {
    
    @StateObject var locationViewModel = LocationSearchViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(locationViewModel)
        }
    }
}
