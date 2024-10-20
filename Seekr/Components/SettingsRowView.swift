//
//  SettingsRowView.swift
//  FirebaseTest
//
//  Created by Taya Ambrose on 10/18/24.
//

import SwiftUI

struct SettingsRowView: View {
    let imageName: String
    let title: String
    let tintColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            Text(title)
                .font(.footnote)
                .accentColor(tintColor)
                
        }
    }
}

#Preview {
    SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.blue.opacity(0.7)))
}
