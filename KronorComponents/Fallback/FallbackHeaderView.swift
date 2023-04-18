//
//  FallbackHeaderView.swift
//
//
//  Created by lorenzo on 2023-04-18.
//


import SwiftUI

struct FallbackHeaderView: View {
    var body: some View {
        VStack {
            Image(systemName: "cart")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }.frame(width: 200,
                height: 200,
                alignment: .leading)
    }
}

struct FallbackHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        FallbackHeaderView()
            .previewDisplayName("Logo")

        FallbackHeaderView()
            .preferredColorScheme(.dark)
            .previewDisplayName("Logo Dark")
    }
}
