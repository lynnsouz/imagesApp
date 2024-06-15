//
//  ContentView.swift
//  ImagesApp
//
//  Created by Lynneker Souza on 15/06/24.
//

import SwiftUI
import Kingfisher

struct SearchImagesView<ViewModel>: View where ViewModel: SearchViewModel {
    @StateObject var viewModel: ViewModel
    
    private var loadingView: some View {
        VStack {
            Spacer()
            VStack {
                Text("Loading images...")
                    .font(.body)
                    .foregroundColor(.gray)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Spacer()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("No images found")
                .font(.title)
            Text("Please type another search term.")
                .font(.body)
        }
        .padding([.top], 32)
    }
    
    var body: some View {
        NavigationView {
            ScrollView([.vertical]) {
                switch viewModel.state {
                case .loading:
                    loadingView
                case let .ready(imagesSerach):
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 64, maximum: 64))],
                              spacing: 8,
                              content: { ForEach(imagesSerach.items) { ImageContentView(url: $0.link) }})
                case .empty, .error:
                    emptyStateView
                }
            }
            .searchable(text: $viewModel.search)
            .onChange(of: viewModel.search) {
                viewModel.serach()
            }
        }
        .navigationTitle("Images App")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SearchImagesView(viewModel: SearchImagesViewModel())
}
