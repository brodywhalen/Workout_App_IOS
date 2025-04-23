//
//  CameraViewWrapper.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 4/23/25.
//

import SwiftUI

struct CameraUIViewControllerWrapper: UIViewControllerRepresentable {
  @Binding var isCameraUnavailable: Bool
  @Binding var showResumeButton: Bool

  func makeCoordinator() -> CameraCoordinator {
    CameraCoordinator(
      isCameraUnavailable: $isCameraUnavailable,
      showResumeButton: $showResumeButton
    )
  }

  func makeUIViewController(context: Context) -> CameraUIViewController {
    let controller = CameraUIViewController()
    controller.coordinator = context.coordinator
    return controller
  }

  func updateUIViewController(_ uiViewController: CameraUIViewController, context: Context) {}
}
