//
//  SwishQRView.swift
//  kronor-ios
//
//  Created by lorenzo on 2023-01-05.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct SwishQRView: View {
    let qrGenerator = QrImageGenerator()
    var qrCode: String

    var body: some View {
        VStack {
            Spacer()
            Image(uiImage: qrGenerator.generateQRCode(from: qrCode))
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.all, 20)

            Text(
                "scan_with_swish",
                bundle: .module,
                comment: "The caption for a QR code image prompting the user to scan it with another device"
            )
                .font(.headline)
            Spacer()
        }
    }
}

struct SwishQRView_Previews: PreviewProvider {
    static var previews: some View {
        SwishWrapperView {
            SwishQRView(qrCode: "https://kronor.io")
        }
    }
}

struct QrImageGenerator {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    func generateQRCode(from text: String) -> UIImage {
        let data = Data(text.utf8)
        filter.setValue(data, forKey: "inputMessage")

        let transform = CGAffineTransform(scaleX: 20, y: 20)
        if let outputImage = filter.outputImage?.transformed(by: transform) {
            if let image = context.createCGImage(
                outputImage,
                from: outputImage.extent) {
                return UIImage(cgImage: image)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
