//
//  ApplePayHeaderView.swift
//  kronor-ios
//

import SwiftUI

struct ApplePayHeaderView: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "applelogo")
                .font(.system(size: 48))
            Text(verbatim: "Pay")
                .font(.system(size: 48, weight: .medium))
        }
        .frame(height: 350)
    }
}

struct ApplePayHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayHeaderView()
            .previewDisplayName("Logo")

        ApplePayHeaderView()
            .preferredColorScheme(.dark)
            .previewDisplayName("Logo Dark")
    }
}
