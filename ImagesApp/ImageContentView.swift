//
//  ImageContentView.swift
//  ImagesApp
//
//  Created by Lynneker Souza on 15/06/24.
//

import SwiftUI
import Kingfisher

struct ImageContentView: View {
    private let size: Double = 64
    let url: String

    var body: some View {
        VStack {
            KFImage.url(URL(string: url))
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size, alignment: .center)
                .background(.gray)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, 
                                                               height: 8)))
        }
    }
}

#Preview {
    ImageContentView(url: "")
}
