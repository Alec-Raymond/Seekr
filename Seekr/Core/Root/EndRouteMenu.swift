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
        VStack(alignment: .trailing, spacing: 16) {
            Text("Options")
                .font(.headline)
                .padding(.bottom, 8)
            
            Button(action: {
                // Logic to end the route goes here
                print("Route ended")
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

struct EndRouteMenu_Previews: PreviewProvider {
    static var previews: some View {
        EndRouteMenu(isVisible: .constant(true))
            .previewLayout(.sizeThatFits)
    }
}
