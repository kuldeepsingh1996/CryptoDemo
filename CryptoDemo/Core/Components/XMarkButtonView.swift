//
//  XMarkButtonView.swift
//  CryptoDemo
//
//  Created by Philophobic on 11/11/24.
//

import SwiftUI

struct XMarkButtonView: View {
    @Environment(\.presentationMode) var presentionMode

    var body: some View {
        
        Button(action: {
            presentionMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "xmark")
                .font(.headline)
        })
    }
}

#Preview {
    XMarkButtonView()
}
