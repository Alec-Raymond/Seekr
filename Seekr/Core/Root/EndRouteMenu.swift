//
//  EndRoute.swift
//  Seekr
//
//  Created by Zander Dumont on 11/28/24.
//

import SwiftUI

struct EndRouteMenu: View {
    @Binding var isVisible: Bool
    var body: some View {
        VStack() {
            Button(action: {
                // End route
                NotificationCenter.default.post(name: .endRouteNotification, object: nil)
                
                withAnimation {
                    isVisible = false
                }
            }) {
            Text("End Route")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(8)
            }
            
            Button(action: {
                withAnimation {
                    isVisible = false
                }
            }) {
                Text("Cancel")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color("DarkBlue").opacity(0.9))
        .cornerRadius(12)
        .padding(.trailing)
    }
}

extension Notification.Name {
    static let endRouteNotification = Notification.Name("endRouteNotification")
}
