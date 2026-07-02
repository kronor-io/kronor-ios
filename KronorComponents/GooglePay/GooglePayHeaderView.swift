//
//  GooglePayHeaderView.swift
//  KronorComponents
//

import SwiftUI

struct GooglePayHeaderView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "creditcard")
                .font(.system(size: 40))
            Text(verbatim: "Google Pay")
                .font(.system(size: 40, weight: .medium))
        }
        .frame(height: 350)
    }
}

struct GooglePayHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        GooglePayHeaderView()
            .previewDisplayName("Logo")

        GooglePayHeaderView()
            .preferredColorScheme(.dark)
            .previewDisplayName("Logo Dark")
    }
}
