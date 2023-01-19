//
//  MobilePayWrapperView.swift
//  
//
//  Created by Jose-JORO on 2023-01-18.
//

import SwiftUI

struct MobilePayWrapperView: View {
    var contents: () -> any View

    var body: some View {
        VStack {
            Spacer()
            MobilePayHeaderView()
            Spacer()
            AnyView(contents())
            Spacer()
        }
    }
}

struct MobilePayWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        MobilePayWrapperView {
            Text("Dummy Contents")
        }
    }
}
