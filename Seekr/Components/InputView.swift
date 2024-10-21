//
//  InputView.swift
//  Seekr
//
//  Created by Taya Ambrose on 10/18/24.
//

// This file contains the struture for text input fields
// like emails, names, passwords, etc. It is not displayed,
// this file is referenced to keep code clean without
// duplicating the textbox.

// Please comment the changes you make and leave your name.

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            
            if isSecureField {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
            }
            Divider()
        }
    }
}

#Preview {
    InputView(text: .constant(""), title: "Email Address", placeholder: "Enter your email address")
}
