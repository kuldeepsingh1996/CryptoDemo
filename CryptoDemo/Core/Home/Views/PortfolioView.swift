//
//  PortfolioView.swift
//  CryptoDemo
//
//  Created by Philophobic on 11/11/24.
//

import SwiftUI

struct PortfolioView: View {
    
    @EnvironmentObject var vm : HomeViewModel
    @State private var selectedCoin : CoinModel? = nil
    @State private var quantityText = ""
    @State private var showCheckmark = false
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading,spacing: 0) {
                    SearchBarView(searchText: $vm.searchText)
                    coinLogoList
                    if selectedCoin != nil {
                        portfolioInputSection
                    }
                }
                .navigationTitle("Edit Portfolio")
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        XMarkButtonView()
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        trailingNavBarButton
                    }
                })
                .onChange(of: vm.searchText) {
                    removeSelectedCoin()
                }
            }
        }
    }
}

#Preview {
    PortfolioView()
        .environmentObject(DeveloperPreview.instance.homeVM)
}


extension PortfolioView {
    
    private var coinLogoList : some View {
        ScrollView(.horizontal,showsIndicators: false) {
            LazyHStack(spacing:10) {
                ForEach(vm.searchText.isEmpty ? vm.portfolioCoins : vm.allCoins) { coin in
                   CoinLogoView(coin: coin)
                        .frame(width:75)
                        .padding(4)
                        .onTapGesture {
                            updateSelectedCoin(coin: coin)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(selectedCoin?.id == coin.id ? Color.theme.green : Color.clear, lineWidth: 1)
                        )
                }
            }
            .frame(height:120)
            .padding(.leading)
        }
    }
    
    private func updateSelectedCoin(coin:CoinModel) {
        selectedCoin = coin
        if let portfolioCoin = vm.portfolioCoins.first(where: {$0.id == coin.id}) , let amount = portfolioCoin.currentHoldings {
            quantityText = "\(amount)"
        }else {
            quantityText = ""
        }
    }
    
    private func getCurrnetValue() -> Double {
        if let quantity = Double(quantityText) {
            return quantity * (selectedCoin?.currentPrice ?? 0)
        }else {
            return 0
        }
    }
    
    private var portfolioInputSection : some View {
        VStack(spacing:20) {
            HStack {
                Text("Current Price of \(selectedCoin?.symbol.uppercased() ?? "") : ")
                Spacer()
                Text(selectedCoin?.currentPrice.asCurrencyWith6Decimals() ?? "")
            }
            
            Divider()
            
            HStack {
                Text("Amount holding")
                Spacer()
                TextField("EX:1.4", text: $quantityText)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
            Divider()
            HStack {
                Text("Current Value")
                Spacer()
                Text(getCurrnetValue().asCurrencyWith2Decimals())
            }
        }
        .animation(.none)
        .padding()

    }
    
    private var trailingNavBarButton : some View {
        HStack(spacing:10){
            Image(systemName: "checkmark")
                .opacity(showCheckmark ? 1.0 : 0)

            Button(action: {
                saveButtonPressed()
            }, label: {
                Text("Save".uppercased())
                
            })
            .opacity((selectedCoin != nil && selectedCoin?.currentHoldings != Double(quantityText)) ? 1.0 : 0)
        }
        .font(.headline)

    }
    
    private func saveButtonPressed() {
        guard let coin = selectedCoin, let amount = Double(quantityText) else{
            return
        }
        
        //Save to portfolio
        vm.updatePortfolio(coin: coin, amount: amount)
        //show checkmark
        withAnimation(.easeIn) {
            showCheckmark = true
            removeSelectedCoin()
            vm.searchText = ""
        }
        
        //hide keyboard
        UIApplication.shared.endEditing()
        
        //hide checkmark
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut) {
                showCheckmark = false
            }
        }
        
        
        
    }
    
    func removeSelectedCoin(){
        selectedCoin = nil
    }
}
