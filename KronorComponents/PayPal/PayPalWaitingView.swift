//
//  PayPalWaitingView.swift
//  
//
//  Created by lorenzo on 2023-01-27.
//

import SwiftUI

struct PayPalWaitingView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack {
            Spacer()
            ProgressView()
                .padding(.trailing, 10.0)
            content
            Spacer()
        }
    }
}

struct PayPalWaitingView_Previews: PreviewProvider {
    static var previews: some View {
        WrapperView(header: PayPalHeaderView()) {
            PayPalWaitingView{
                Text("Dummy contents")
            }
        }
    }
}
