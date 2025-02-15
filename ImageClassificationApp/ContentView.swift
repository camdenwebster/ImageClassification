//
//  ContentView.swift
//  ImageClassificationApp
//
//  Created by Camden Webster on 2/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        Spacer()
        VStack {
            HStack {
                Text("Prediction: ")
                Text(viewModel.prediction)
            }
            
            HStack {
                Text("Confidence: ")
                Text(viewModel.confidence)
            }
            .frame(minHeight: 50)
            
            CameraPreview(session: viewModel.session)
                .onAppear {
                    DispatchQueue.global().async {
                        self.viewModel.setupSession()
                    }
                }
        }
        .background(
            Image(.bluBD)
                .resizable()
                .scaledToFit()
        )
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
