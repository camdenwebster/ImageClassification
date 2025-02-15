//
//  ContentViewModel.swift
//  ImageClassificationApp
//
//  Created by Camden Webster on 2/12/25.
//

import AVKit
import Vision
import Combine

class ContentViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var prediction: String = "--"
    @Published var confidence: String = "--"
    
    let session = AVCaptureSession()
    
    func setupSession() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        session.sessionPreset = .hd1280x720
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        session.addInput(input)
        session.addOutput(output)
        session.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model = try? VNCoreMLModel(for: DogBreedClassifier().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            DispatchQueue.main.async {
                self.processResults(for: finishedReq)
            }
        }
        
        do {
            try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        } catch {
            print("Error performing vision request: \(error)")
        }
    }
    
    private func processResults(for request: VNRequest) {
        guard let results = request.results as? [VNClassificationObservation], let firstResult = results.first else {
            prediction = "--"
            confidence = "--"
            return
        }
        
        if firstResult.confidence * 100 >= 20 {
            prediction = firstResult.identifier.capitalized
            confidence = String(format: "%.2f%", firstResult.confidence * 100)
        } else {
            prediction = "--"
            confidence = "--"
        }
        
    }
    
}
