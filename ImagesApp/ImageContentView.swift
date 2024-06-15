//
//  ImageContentView.swift
//  ImagesApp
//
//  Created by Lynneker Souza on 15/06/24.
//

import SwiftUI

struct ImageContentView: View {
    private let size: Double = 64
    let url: String

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
            } placeholder: {
                ProgressView()
                    .frame(width: size, height: size)
            }
            .background(.thickMaterial)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
        }
    }
}

#Preview {
    ImageContentView(url: "")
}
