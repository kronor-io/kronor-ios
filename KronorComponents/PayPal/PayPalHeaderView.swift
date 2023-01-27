//
//  PayPalHeaderView.swift
//  
//
//  Created by lorenzo on 2023-01-27.
//

import SwiftUI

struct PayPalHeaderView: View {
    static let logoPath = Bundle.module.path(forResource: "paypal-logo", ofType: "png")!
    static let logo = UIImage(contentsOfFile: logoPath)!

    var body: some View {
        VStack {
            Image(uiImage: Self.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }.frame(width: 350,
                height: 350,
                alignment: .leading)
    }
}

struct PayPalHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        PayPalHeaderView()
            .previewDisplayName("Logo")

        PayPalHeaderView()
            .preferredColorScheme(.dark)
            .previewDisplayName("Logo Dark")
    }
}
