//
//  VippsHeaderView.swift
//  
//
//  Created by lorenzo on 2023-01-25.
//

import SwiftUI

struct VippsHeaderView: View {
    static let logoPath = Bundle.module.path(forResource: "vipps-logo", ofType: "png")!
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

struct VippsHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VippsHeaderView()
            .previewDisplayName("Logo")

        VippsHeaderView()
            .preferredColorScheme(.dark)
            .previewDisplayName("Logo Dark")
    }
}
