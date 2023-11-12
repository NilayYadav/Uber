//
//  HomeView.swift
//  Uber
//
//  Created by Nilay on 12/11/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        UberMapViewRepresentable()
            .ignoresSafeArea()
    }
}

#Preview {
    HomeView()
}
