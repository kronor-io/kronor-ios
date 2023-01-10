//
//  SwishHeaderView.swift
//  kronor-test-app
//
//  Created by Jose-JORO on 2023-01-09.
//

import SwiftUI

struct SwishHeaderView: View {
    var body: some View {
        VStack {
            Image("swish-logo")
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
