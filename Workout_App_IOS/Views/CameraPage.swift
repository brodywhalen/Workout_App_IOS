//
//  CameraPage.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 4/29/25.
//

import SwiftUI
import AVFoundation
import CoreImage
import MediaPipeTasksVision




struct CameraPage: View {
    
    @StateObject private var model = FrameHandler()
    
    var body: some View {
        FrameView(image:model.frame)
            .ignoresSafeArea()
        
    }
}


// SwiftUI View that presents the image
struct FrameView:  View {
    var image: CGImage?
    private let label = Text("Frame")
    
    var body: some View {
        if let image = image {
            Image(image, scale: 1.0, orientation: .up, label: label)
        } else {
            Color.black
        }
    }
    
}
// reads frames from the AVCapture Session
class FrameHandler: NSObject, ObservableObject {
    @Published var frame:CGImage?
    private var permissionGranted = false
    private let captureSession = AVCaptureSession()
//    private var videoResolution: CGSize
    
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let backgroundQueue = DispatchQueue(label: "com.google.mediapipe.cameraController.backgroundQueue")

    private var _poseLandmarkerService: PoseLandmarkerService?
    private var poseLandmarkerService: PoseLandmarkerService? {
      get {
        sessionQueue.sync {
          return self._poseLandmarkerService
        }
      }
      set {
        sessionQueue.async(flags: .barrier) {
          self._poseLandmarkerService = newValue
        }
      }
    }
    
    
    private let context = CIContext()
    
    override init() {
        super.init()
        checkPermission()
        sessionQueue.async{ [unowned self] in
            self.setupCaptureSession()
            self.captureSession.startRunning()
            self.clearAndInitializePoseLandmarkerService()
            
        }
    }
    
    @objc private func clearAndInitializePoseLandmarkerService() {
      poseLandmarkerService = nil
      poseLandmarkerService = PoseLandmarkerService
        .liveStreamPoseLandmarkerService(
          modelPath: InferenceConfigurationManager.sharedInstance.model.modelPath,
          numPoses: InferenceConfigurationManager.sharedInstance.numPoses,
          minPoseDetectionConfidence: InferenceConfigurationManager.sharedInstance.minPoseDetectionConfidence,
          minPosePresenceConfidence: InferenceConfigurationManager.sharedInstance.minPosePresenceConfidence,
          minTrackingConfidence: InferenceConfigurationManager.sharedInstance.minTrackingConfidence,
          liveStreamDelegate: self,
          delegate: InferenceConfigurationManager.sharedInstance.delegate)
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
    }
    
    func requestPermission(){
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
            
        }
    }
    
    func setupCaptureSession() {
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        guard permissionGranted else {return} // cancels if permission not granted, maybe update as state since it did not on load
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position:.back) else {return}
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {return}
        guard captureSession.canAddInput(videoDeviceInput) else {return}
        captureSession.addInput(videoDeviceInput)
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(videoOutput)
        videoOutput.connection(with: .video)?.videoRotationAngle = 90
    }
}

extension FrameHandler: AVCaptureVideoDataOutputSampleBufferDelegate {

    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
//        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
//             let width = CVPixelBufferGetWidth(imageBuffer)
//             let height = CVPixelBufferGetHeight(imageBuffer)
////             print("Resolution: \(width)x\(height)")
////             videoResolution = CGSize(width: width, height: height)
//         }
        
       
        
        guard let cgImage = ImageFromSampleBuffer(sampleBuffer: sampleBuffer) else {return}
       
        DispatchQueue.main.async { [unowned self] in
            self.frame = cgImage
            
        }
     
        // pass pixel buffer
        let currentTimeMs = Date().timeIntervalSince1970 * 1000
        backgroundQueue.async { [weak self] in
          self?.poseLandmarkerService?.detectAsync(
            sampleBuffer: sampleBuffer,
            orientation: .up,
            timeStamps: Int(currentTimeMs))
        }
        
        //all UI updates should/must be preformed on the main queue

    }
    private func ImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return nil}
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {return nil}
        return cgImage
    }
}

  
 

// MARK: PoseLandmarkerServiceLiveStreamDelegate
extension FrameHandler: PoseLandmarkerServiceLiveStreamDelegate {

  func poseLandmarkerService(
    _ poseLandmarkerService: PoseLandmarkerService,
    didFinishDetection result: ResultBundle?,
    error: Error?) {
        
      DispatchQueue.main.async { [weak self] in
//        guard let weakSelf = self else { return }
        guard let poseLandmarkerResult = result?.poseLandmarkerResults.first as? PoseLandmarkerResult else { return }
//        let imageSize = weakSelf.videoResolution
          //no drawing just print
          poseLandmarkerResult.landmarks.forEach { NormalizedLandmark in
              print("x: ",NormalizedLandmark[0].x, " y: ", NormalizedLandmark[0].y)
          }
 
      }
    }
}


