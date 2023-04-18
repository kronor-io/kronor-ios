//
//  FallbackWaitingView.swift
//
//
//  Created by lorenzo on 2023-04-18.
//

import SwiftUI

struct FallbackWaitingView: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "hourglass.circle")
            Text(
                "Creating secure transaction",
                bundle: .module,
                comment:  "A waiting message that indicates the app is communicating with the server"
            )
                .font(.subheadline)
            Spacer()
        }
    }
}

struct FallbackWaitingView_Previews: PreviewProvider {
    static var previews: some View {
        WrapperView(header: FallbackHeaderView()) {
            FallbackWaitingView()
        }
    }
}
