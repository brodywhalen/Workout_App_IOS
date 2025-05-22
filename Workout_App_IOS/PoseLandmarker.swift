//
//  PoseLandmarker.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 5/10/25.
//

//import MediaPipeTasksVision


import MediaPipeTasksVision
import AVFoundation

/**
 This protocol must be adopted by any class that wants to get the detection results of the pose landmarker in live stream mode.
 */
protocol PoseLandmarkerServiceLiveStreamDelegate: AnyObject {
  func poseLandmarkerService(_ poseLandmarkerService: PoseLandmarkerService,
                             didFinishDetection result: ResultBundle?,
                             error: Error?)
}

// Delegate Call back
class PoseLandmarkerResultProcessor: NSObject, PoseLandmarkerLiveStreamDelegate {

  func poseLandmarker(
    _ poseLandmarker: PoseLandmarker,
    didFinishDetection result: PoseLandmarkerResult?,
    timestampInMilliseconds: Int,
    error: Error?) {
        
    // Process the pose landmarker result or errors here.

  }
}


// Initializes and calls the MediaPipe APIs for detection.
class PoseLandmarkerService: NSObject {

  weak var liveStreamDelegate: PoseLandmarkerServiceLiveStreamDelegate?
//  weak var videoDelegate: PoseLandmarkerServiceVideoDelegate?

  var poseLandmarker: PoseLandmarker?
  private(set) var runningMode = RunningMode.image
  private var numPoses: Int
  private var minPoseDetectionConfidence: Float
  private var minPosePresenceConfidence: Float
  private var minTrackingConfidence: Float
  private var modelPath: String
  private var delegate: PoseLandmarkerDelegate

  // MARK: - Custom Initializer
  private init?(modelPath: String?,
                runningMode:RunningMode,
                numPoses: Int,
                minPoseDetectionConfidence: Float,
                minPosePresenceConfidence: Float,
                minTrackingConfidence: Float,
                delegate: PoseLandmarkerDelegate) {
    guard let modelPath = modelPath else { return nil }
    self.modelPath = modelPath
    self.runningMode = runningMode
    self.numPoses = numPoses
    self.minPoseDetectionConfidence = minPoseDetectionConfidence
    self.minPosePresenceConfidence = minPosePresenceConfidence
    self.minTrackingConfidence = minTrackingConfidence
    self.delegate = delegate
    super.init()

    createPoseLandmarker()
  }

  private func createPoseLandmarker() {
    let poseLandmarkerOptions = PoseLandmarkerOptions()
    poseLandmarkerOptions.runningMode = runningMode
    poseLandmarkerOptions.numPoses = numPoses
    poseLandmarkerOptions.minPoseDetectionConfidence = minPoseDetectionConfidence
    poseLandmarkerOptions.minPosePresenceConfidence = minPosePresenceConfidence
    poseLandmarkerOptions.minTrackingConfidence = minTrackingConfidence
    poseLandmarkerOptions.baseOptions.modelAssetPath = modelPath
    poseLandmarkerOptions.baseOptions.delegate = delegate.delegate
    if runningMode == .liveStream {
      poseLandmarkerOptions.poseLandmarkerLiveStreamDelegate = self
    }
    do {
      poseLandmarker = try PoseLandmarker(options: poseLandmarkerOptions)
    }
    catch {
      print(error)
    }
  }

  // MARK: - Static Initializers

  static func liveStreamPoseLandmarkerService(
    modelPath: String?,
    numPoses: Int,
    minPoseDetectionConfidence: Float,
    minPosePresenceConfidence: Float,
    minTrackingConfidence: Float,
    liveStreamDelegate: PoseLandmarkerServiceLiveStreamDelegate?,
    delegate: PoseLandmarkerDelegate) -> PoseLandmarkerService? {
    let poseLandmarkerService = PoseLandmarkerService(
      modelPath: modelPath,
      runningMode: RunningMode.liveStream,
      numPoses: numPoses,
      minPoseDetectionConfidence: minPoseDetectionConfidence,
      minPosePresenceConfidence: minPosePresenceConfidence,
      minTrackingConfidence: minTrackingConfidence,
      delegate: delegate)
    poseLandmarkerService?.liveStreamDelegate = liveStreamDelegate

    return poseLandmarkerService
  }


  // MARK: - Detection Methods for Different Modes
  /**
   This method return PoseLandmarkerResult and infrenceTime when receive an image
   **/
  func detect(image: UIImage) -> ResultBundle? {
    guard let mpImage = try? MPImage(uiImage: image) else {
      return nil
    }
    do {
      let startDate = Date()
      let result = try poseLandmarker?.detect(image: mpImage)
      let inferenceTime = Date().timeIntervalSince(startDate) * 1000
      return ResultBundle(inferenceTime: inferenceTime, poseLandmarkerResults: [result])
    } catch {
        print(error)
        return nil
    }
  }

  func detectAsync(
    sampleBuffer: CMSampleBuffer,
    orientation: UIImage.Orientation,
    timeStamps: Int) {
    guard let image = try? MPImage(sampleBuffer: sampleBuffer, orientation: orientation) else {
      return
    }
    do {
      try poseLandmarker?.detectAsync(image: image, timestampInMilliseconds: timeStamps)
    } catch {
      print(error)
    }
  }

  private func imageGenerator(with videoAsset: AVAsset) -> AVAssetImageGenerator {
    let generator = AVAssetImageGenerator(asset: videoAsset)
    generator.requestedTimeToleranceBefore = CMTimeMake(value: 1, timescale: 25)
    generator.requestedTimeToleranceAfter = CMTimeMake(value: 1, timescale: 25)
    generator.appliesPreferredTrackTransform = true

    return generator
  }


}

// MARK: - PoseLandmarkerLiveStreamDelegate Methods
extension PoseLandmarkerService: PoseLandmarkerLiveStreamDelegate {
    func poseLandmarker(_ poseLandmarker: PoseLandmarker, didFinishDetection result: PoseLandmarkerResult?, timestampInMilliseconds: Int, error: (any Error)?) {
        let resultBundle = ResultBundle(
          inferenceTime: Date().timeIntervalSince1970 * 1000 - Double(timestampInMilliseconds),
          poseLandmarkerResults: [result])
        liveStreamDelegate?.poseLandmarkerService(
          self,
          didFinishDetection: resultBundle,
          error: error)
    }
}

/// A result from the `PoseLandmarkerService`.
struct ResultBundle {
  let inferenceTime: Double
  let poseLandmarkerResults: [PoseLandmarkerResult?]
  var size: CGSize = .zero
}


    
