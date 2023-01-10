//
//  SwishWrapperView.swift
//  kronor-ios
//
//  Created by lorenzo on 2023-01-09.
//

import SwiftUI

struct SwishWrapperView: View {
    var contents: () -> any View

    var body: some View {
        VStack {
            Spacer()
            SwishHeaderView()
            Spacer()
            AnyView(contents())
            Spacer()
        }
    }
}

struct SwishWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        SwishWrapperView {
            Text("Dummy Contents")
        }
    }
}
