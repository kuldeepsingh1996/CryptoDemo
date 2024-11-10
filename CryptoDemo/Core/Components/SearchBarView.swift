//
//  SearchBarView.swift
//  CryptoDemo
//
//  Created by Philophobic on 09/11/24.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText : String
    var body: some View {
        HStack {
            
            Image(systemName: "magnifyingglass")
                .foregroundStyle(
                    searchText.isEmpty ?  Color.theme.secondaryText : Color.theme.accent
                )
                .padding(.leading)
            
            TextField("Search by name or symbol.....", text: $searchText)
                .foregroundStyle(Color.theme.accent)
                .overlay(alignment: .trailing) {
                    Image(systemName: "xmark.circle.fill")
                        .padding()
                        .offset(x:10)
                        .foregroundStyle(Color.theme.accent)
                        .opacity(searchText.isEmpty ? 0 : 1.0)
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                            searchText = ""
                        }
                }
                .font(.headline)
                .padding()

        }

        .background {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.accent.opacity(0.2),radius: 10)
            
        }
        .padding()

    }
}

#Preview {
    SearchBarView(searchText: .constant(""))
}