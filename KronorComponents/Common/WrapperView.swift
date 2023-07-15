//
//  WrapperView.swift
//  
//
//  Created by lorenzo on 2023-01-24.
//

import SwiftUI

struct WrapperView<Header: View, Content: View>: View {
    let header: Header
    let content: Content

    init(
        header: Header,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header
        self.content = content()
    }

    var body: some View {
        VStack {
            Spacer()
            header
            Spacer()
            content
            Spacer()
        }
    }
}

struct WrapperView_Previews: PreviewProvider {
    static var previews: some View {
        WrapperView(header: MobilePayHeaderView()) {
            Text("Dummy Contents")
        }
    }
}
