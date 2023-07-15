//
//  SwishWrapperView.swift
//  kronor-ios
//
//  Created by lorenzo on 2023-01-09.
//

import SwiftUI

struct SwishWrapperView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            Spacer()
            SwishHeaderView()
            Spacer()
            content
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
