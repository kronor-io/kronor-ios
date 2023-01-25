//
//  MobilePayWaitingView.swift
//  
//
//  Created by lorenzo on 2023-01-24.
//

import SwiftUI

struct MobilePayWaitingView: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "hourglass.circle")
            Text(
                "Creating secure MobilePay transaction",
                bundle: .module,
                comment:  "A waiting message that indicates the app is communicating with the server"
            )
                .font(.subheadline)
            Spacer()
        }
    }
}

struct MobilePayWaitingView_Previews: PreviewProvider {
    static var previews: some View {
        WrapperView(header: MobilePayHeaderView()) {
            MobilePayWaitingView()
        }
    }
}
