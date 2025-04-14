import UIKit
import Vision
import Cordova

@objc(IOSOCRVision) class IOSOCRVision: CDVPlugin {
    @objc(recognizeText:)
    func recognizeText(command: CDVInvokedUrlCommand) {
        // Get the Base64 image string from the Cordova call
        guard let base64Image = command.argument(at: 0) as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "No image provided.")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        // Decode Base64 to Data and then to UIImage
        guard let imageData = Data(base64Encoded: base64Image),
              let uiImage = UIImage(data: imageData) else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid image data.")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        // Ensure the UIImage can provide a CGImage
        guard let cgImage = uiImage.cgImage else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Failed to get CGImage from UIImage.")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        // Create a Vision request handler
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                let pluginResult = CDVPluginResult(status: .error, messageAs: error.localizedDescription)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }
            
            // Process the results from the Vision request
            var recognizedText = ""
            for observation in request.results as? [VNRecognizedTextObservation] ?? [] {
                guard let candidate = observation.topCandidates(1).first else { continue }
                recognizedText += candidate.string + "\n"
            }
            
            // Return the recognized text to the Cordova layer
            let pluginResult = CDVPluginResult(status: .ok, messageAs: recognizedText)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
        
        // Configure the request as needed
        request.recognitionLevel = .accurate
        if #available(iOS 13.0, *) {
            request.recognitionLanguages = ["en-US"]
        }
        
        // Perform the Vision request asynchronously
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch let error {
                let pluginResult = CDVPluginResult(status: .error, messageAs: error.localizedDescription)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
        }
    }
}
