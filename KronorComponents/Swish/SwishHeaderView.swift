//
//  SwishHeaderView.swift
//  kronor-test-app
//
//  Created by Jose-JORO on 2023-01-09.
//

import SwiftUI

struct SwishHeaderView: View {
    static let swishLogoPath = Bundle.module.path(forResource: "swish-logo", ofType: "png")!
    static let swishLogo = UIImage(contentsOfFile: swishLogoPath)!

    var body: some View {
        VStack {
            Image(uiImage: Self.swishLogo)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }.frame(width: 150,
                height: 250,
                alignment: .leading)
    }
}

struct SwishHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SwishHeaderView()
    }
}
