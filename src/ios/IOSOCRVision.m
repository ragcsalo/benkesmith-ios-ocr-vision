#import "IOSOCRVision.h"
#import <Vision/Vision.h>
#import <UIKit/UIKit.h>

@implementation IOSOCRVision

- (void)recognizeText:(CDVInvokedUrlCommand *)command
{
    // 1. Get Base64 string
    NSString* base64String = [command.arguments objectAtIndex:0];
    if (!base64String) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No image data provided."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    // 2. Convert Base64 to UIImage
    NSData* imageData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    UIImage* uiImage = [UIImage imageWithData:imageData];
    if (!uiImage) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid image data."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    // 3. Check for cgImage
    CGImageRef cgImage = uiImage.CGImage;
    if (!cgImage) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Failed to retrieve CGImage from UIImage."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    // 4. Create a VNRecognizeTextRequest
    VNRecognizeTextRequest* textRequest = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        if (error) {
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }
        
        NSMutableString *recognizedText = [NSMutableString string];
        for (VNRecognizedTextObservation* observation in request.results) {
            if (![observation isKindOfClass:[VNRecognizedTextObservation class]]) { continue; }
            VNRecognizedText* topCandidate = [[observation topCandidates:1] firstObject];
            if (topCandidate) {
                [recognizedText appendString:topCandidate.string];
                [recognizedText appendString:@"\n"];
            }
        }
        
        CDVPluginResult* successResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:recognizedText];
        [self.commandDelegate sendPluginResult:successResult callbackId:command.callbackId];
    }];
    textRequest.recognitionLevel = VNRequestTextRecognitionLevelAccurate;
    
    // (Optionally set languages if iOS >= 13)
    if (@available(iOS 13.0, *)) {
        textRequest.recognitionLanguages = @[@"en-US"];
    }
    
    // 5. Perform the request
    VNImageRequestHandler* requestHandler = [[VNImageRequestHandler alloc] initWithCGImage:cgImage options:@{}];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError *requestError = nil;
        [requestHandler performRequests:@[textRequest] error:&requestError];
        if (requestError) {
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:requestError.localizedDescription];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    });
}

@end
