//
//  SwishHeaderView.swift
//  kronor-ios
//
//  Created by lorenzo on 2023-01-09.
//

import SwiftUI

struct SwishHeaderView: View {
    static let swishLogoPath = Bundle.module.path(forResource: "swish-logo", ofType: "png")!
    static let swishLogo = UIImage(contentsOfFile: swishLogoPath)!

    static let swishLogoDarkPath = Bundle.module.path(forResource: "swish-logo-dark", ofType: "png")!
    static let swishLogoDark = UIImage(contentsOfFile: swishLogoDarkPath)!
    @Environment(\.colorScheme) var currentMode

    var body: some View {
        VStack {
            Image(uiImage: currentMode == .dark ? Self.swishLogoDark : Self.swishLogo)
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
            .previewDisplayName("Logo")

        SwishHeaderView()
            .preferredColorScheme(.dark)
            .previewDisplayName("Logo Dark")
    }
}
