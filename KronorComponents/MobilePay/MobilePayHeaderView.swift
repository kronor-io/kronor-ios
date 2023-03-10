//
//  MobilePayHeaderView.swift
//  
//
//  Created by lorenzo on 2023-01-18.
//


import SwiftUI

struct MobilePayHeaderView: View {
    static let logoPath = Bundle.module.path(forResource: "mobilepay-logo", ofType: "png")!
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

struct MobilePayHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        MobilePayHeaderView()
            .previewDisplayName("Logo")

        MobilePayHeaderView()
            .preferredColorScheme(.dark)
            .previewDisplayName("Logo Dark")
    }
}
