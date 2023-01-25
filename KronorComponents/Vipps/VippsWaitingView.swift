//
//  VippsWaitingView.swift
//  
//
//  Created by lorenzo on 2023-01-25.
//

import SwiftUI

struct VippsWaitingView: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "hourglass.circle")
            Text(
                "Creating secure Vipps transaction",
                bundle: .module,
                comment:  "A waiting message that indicates the app is communicating with the server"
            )
                .font(.subheadline)
            Spacer()
        }
    }
}

struct VippsWaitingView_Previews: PreviewProvider {
    static var previews: some View {
        WrapperView(header: VippsHeaderView()) {
            VippsWaitingView()
        }
    }
}
