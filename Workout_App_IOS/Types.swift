//
//  Types.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 5/10/25.
//

import CoreFoundation
import SwiftUICore
import MediaPipeTasksVision

enum PoseLandmarkerDelegate: CaseIterable {
    case GPU
    case CPU
    
    var name: String {
        switch self {
        case .GPU:
            return "GPU"
        case .CPU:
            return "CPU"
        }
    }
    
    var delegate: Delegate {
        switch self {
        case .GPU:
            return .GPU
        case .CPU:
            return .CPU
        }
    }
    
    init?(name: String) {
        switch name {
        case PoseLandmarkerDelegate.CPU.name:
            self = PoseLandmarkerDelegate.CPU
        case PoseLandmarkerDelegate.GPU.name:
            self = PoseLandmarkerDelegate.GPU
        default:
            return nil
        }
    }
}

struct DefaultConstants {
    
    static let lineWidth: CGFloat = 2
    static let pointRadius: CGFloat = 2
    static let pointColor = Color.yellow
    static let pointFillColor = Color.red
    
    static let lineColor = Color(red: 0, green: 127/255.0, blue: 139/255.0)
    
    static var numPoses: Int = 1
    static var minPoseDetectionConfidence: Float = 0.5
    static var minPosePresenceConfidence: Float = 0.5
    static var minTrackingConfidence: Float = 0.5
    static let model: Model = .pose_landmarker_lite
    static let delegate: PoseLandmarkerDelegate = .CPU
}

class InferenceConfigurationManager: NSObject {
    
    var model: Model = DefaultConstants.model {
        didSet { postConfigChangedNotification() }
    }
    
    var delegate: PoseLandmarkerDelegate = DefaultConstants.delegate {
        didSet { postConfigChangedNotification() }
    }
    
    var numPoses: Int = DefaultConstants.numPoses {
        didSet { postConfigChangedNotification() }
    }
    
    var minPoseDetectionConfidence: Float = DefaultConstants.minPoseDetectionConfidence {
        didSet { postConfigChangedNotification() }
    }
    
    var minPosePresenceConfidence: Float = DefaultConstants.minPosePresenceConfidence {
        didSet { postConfigChangedNotification() }
    }
    
    var minTrackingConfidence: Float = DefaultConstants.minTrackingConfidence {
        didSet { postConfigChangedNotification() }
    }
    
    static let sharedInstance = InferenceConfigurationManager()
    
    static let notificationName = Notification.Name.init(rawValue: "com.google.mediapipe.inferenceConfigChanged")
    
    private func postConfigChangedNotification() {
        NotificationCenter.default
            .post(name: InferenceConfigurationManager.notificationName, object: nil)
    }
    
}

enum Model: Int, CaseIterable {
    case pose_landmarker_lite
    //    case pose_landmarker_full
    //    case pose_landmarker_heavy
    //
    var name: String {
        switch self {
        case .pose_landmarker_lite:
            return "Pose landmarker (lite)"
            //        case .pose_landmarker_full:
            //            return "Pose landmarker (Full)"
            //        case .pose_landmarker_heavy:
            //            return "Pose landmarker (Heavy)"
        }
    }
    var modelPath: String? {
        switch self {
        case .pose_landmarker_lite:
            return Bundle.main.path(
                forResource: "pose_landmarker_lite", ofType: "task")
            //        case .pose_landmarker_full:
            //          return Bundle.main.path(
            //            forResource: "pose_landmarker_full", ofType: "task")
            //        case .pose_landmarker_heavy:
            //          return Bundle.main.path(
            //            forResource: "pose_landmarker_heavy", ofType: "task")
        }
    }
}
protocol CameraFeedServiceDelegate: AnyObject {
    
    /**
     This method delivers the pixel buffer of the current frame seen by the device's camera.
     */
    func didOutput(sampleBuffer: CMSampleBuffer, orientation: UIImage.Orientation)
    
    /**
     This method initimates that a session runtime error occured.
     */
    func didEncounterSessionRuntimeError()
    
    /**
     This method initimates that the session was interrupted.
     */
    func sessionWasInterrupted(canResumeManually resumeManually: Bool)
    
    /**
     This method initimates that the session interruption has ended.
     */
    func sessionInterruptionEnded()
    
}
