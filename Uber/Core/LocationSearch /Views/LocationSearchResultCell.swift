//
//  LocationSearchResultCell.swift
//  Uber
//
//  Created by Nilay on 12/11/23.
//

import SwiftUI

struct LocationSearchResultCell: View {
    
    var title: String
    var subTitle: String
    
    var body: some View {
        HStack {
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .foregroundColor(.blue)
                .accentColor(.white)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                
                Text(subTitle)
                    .font(.system(size: 15))
                    .foregroundStyle(.gray)
                
                Divider()
                
            }
            .padding(.leading, 8)
            .padding(.vertical, 8)
            
        }
        .padding(.leading)
    }
}

//#Preview {
//    LocationSearchResultCell()
//}
