//
//  WrapperView.swift
//  
//
//  Created by lorenzo on 2023-01-24.
//

import SwiftUI

struct WrapperView: View {
    var header: any View
    var contents: () -> any View

    var body: some View {
        VStack {
            Spacer()
            AnyView(self.header)
            Spacer()
            AnyView(contents())
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
