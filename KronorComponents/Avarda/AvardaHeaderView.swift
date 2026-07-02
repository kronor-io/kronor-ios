//
//  AvardaHeaderView.swift
//  KronorComponents
//

import SwiftUI

struct AvardaHeaderView: View {
    var body: some View {
        Text(verbatim: "Avarda")
            .font(.system(size: 48, weight: .semibold))
            .frame(height: 350)
    }
}

struct AvardaHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        AvardaHeaderView()
            .previewDisplayName("Logo")

        AvardaHeaderView()
            .preferredColorScheme(.dark)
            .previewDisplayName("Logo Dark")
    }
}
