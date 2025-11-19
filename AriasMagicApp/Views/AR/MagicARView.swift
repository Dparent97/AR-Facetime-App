//
//  MagicARView.swift
//  Aria's Magic SharePlay App
//
//  AR view with character spawning and face tracking
//

import SwiftUI
import RealityKit
import ARKit

struct MagicARView: UIViewRepresentable {
    @ObservedObject var viewModel: CharacterViewModel
    var onError: ((AppError) -> Void)?
    var isActive: Bool = true  // Control AR session state

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Configure AR session with error handling
        do {
            try context.coordinator.configureARSession(arView)
        } catch let error as AppError {
            context.coordinator.handleError(error)
        } catch {
            context.coordinator.handleError(.arConfigurationFailed(error.localizedDescription))
        }

        // Set up gesture recognizers
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)

        let dragGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDrag(_:)))
        arView.addGestureRecognizer(dragGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        arView.addGestureRecognizer(pinchGesture)

        // Store arView in coordinator
        context.coordinator.arView = arView
        context.coordinator.viewModel = viewModel

        // Set up face tracking delegate
        arView.session.delegate = context.coordinator

        // Add initial anchor
        let anchor = AnchorEntity(plane: .horizontal)
        arView.scene.addAnchor(anchor)
        context.coordinator.mainAnchor = anchor

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // Update characters in scene based on view model
        context.coordinator.updateCharacters()

        // Handle AR session lifecycle based on isActive state
        if isActive {
            context.coordinator.resumeARSession()
        } else {
            context.coordinator.pauseARSession()
        }
    }

    static func dismantleUIView(_ uiView: ARView, coordinator: Coordinator) {
        // Stop AR session when view is removed
        coordinator.stopARSession()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel, onError: onError)
    }

    class Coordinator: NSObject, ARSessionDelegate {
        var viewModel: CharacterViewModel
        weak var arView: ARView?
        var mainAnchor: AnchorEntity?
        var selectedEntity: ModelEntity?
        var faceTrackingService: FaceTrackingService?
        var onError: ((AppError) -> Void)?
        var arCapabilities: ARCapabilities = .none

        init(viewModel: CharacterViewModel, onError: ((AppError) -> Void)? = nil) {
            self.viewModel = viewModel
            self.onError = onError
            super.init()
        }

        func configureARSession(_ arView: ARView) throws {
            // Check AR support
            guard ARWorldTrackingConfiguration.isSupported else {
                arCapabilities = .none
                let error = AppError.arNotSupported
                ErrorLoggingService.shared.logError(error)
                handleError(error)
                throw error
            }

            // Try face tracking first
            if ARFaceTrackingConfiguration.isSupported {
                let configuration = ARFaceTrackingConfiguration()
                configuration.isWorldTrackingEnabled = true

                do {
                    arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                    arCapabilities = .faceTracking

                    // Initialize face tracking service
                    self.faceTrackingService = FaceTrackingService(delegate: self)

                    ErrorLoggingService.shared.logger.info("AR session configured with face tracking")
                } catch {
                    // Face tracking failed, fallback to world tracking
                    ErrorLoggingService.shared.logSwiftError(error, context: "Face tracking configuration failed, falling back to world tracking")
                    try configureWorldTracking(arView)
                }
            } else {
                // Face tracking not supported, use world tracking
                let warning = AppError.faceTrackingNotAvailable
                ErrorLoggingService.shared.logError(warning)
                handleError(warning)
                try configureWorldTracking(arView)
            }
        }

        private func configureWorldTracking(_ arView: ARView) throws {
            let worldConfig = ARWorldTrackingConfiguration()
            worldConfig.planeDetection = [.horizontal, .vertical]
            worldConfig.environmentTexturing = .automatic

            do {
                arView.session.run(worldConfig, options: [.resetTracking, .removeExistingAnchors])
                arCapabilities = .worldTracking
                ErrorLoggingService.shared.logger.info("AR session configured with world tracking")
            } catch {
                arCapabilities = .none
                let appError = AppError.arSessionFailed(error.localizedDescription)
                ErrorLoggingService.shared.logError(appError)
                throw appError
            }
        }

        func handleError(_ error: AppError) {
            DispatchQueue.main.async {
                self.onError?(error)
                self.viewModel.handleError(error)
            }
        }

        deinit {
            // Clean up AR session and resources
            stopARSession()
            arView?.session.delegate = nil
            faceTrackingService = nil
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let location = gesture.location(in: arView)

            // Check if tapping on existing character
            if let entity = arView.entity(at: location) as? ModelEntity {
                selectedEntity = entity
                return
            }

            // Spawn new character at tap location
            if let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal).first {
                viewModel.spawnCharacter(at: result.worldTransform.position)
            }
        }

        @objc func handleDrag(_ gesture: UIPanGestureRecognizer) {
            guard let arView = arView, let selectedEntity = selectedEntity else { return }

            let location = gesture.location(in: arView)

            if let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal).first {
                selectedEntity.position = result.worldTransform.position
            }

            if gesture.state == .ended {
                self.selectedEntity = nil
            }
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let selectedEntity = selectedEntity else { return }

            if gesture.state == .changed {
                let scale = Float(gesture.scale)
                selectedEntity.scale = [scale, scale, scale]
            }

            if gesture.state == .ended {
                gesture.scale = 1.0
            }
        }

        func updateCharacters() {
            guard let anchor = mainAnchor else { return }

            // Remove old entities
            anchor.children.removeAll()

            // Add current characters
            for character in viewModel.characters {
                anchor.addChild(character.modelEntity)
            }
        }

        // MARK: - ARSessionDelegate

        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            for anchor in anchors {
                if let faceAnchor = anchor as? ARFaceAnchor {
                    faceTrackingService?.processFaceAnchor(faceAnchor)
                }
            }
        }

        func session(_ session: ARSession, didFailWithError error: Error) {
            let appError = AppError.arSessionFailed(error.localizedDescription)
            ErrorLoggingService.shared.logError(appError)
            handleError(appError)

            // Attempt to restart session
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self, let arView = self.arView else { return }
                do {
                    try self.configureARSession(arView)
                } catch {
                    ErrorLoggingService.shared.logSwiftError(error, context: "AR session restart failed")
                }
            }
        }

        func sessionWasInterrupted(_ session: ARSession) {
            ErrorLoggingService.shared.logger.warning("AR session was interrupted")
        }

        func sessionInterruptionEnded(_ session: ARSession) {
            ErrorLoggingService.shared.logger.info("AR session interruption ended, attempting to restart")

            guard let arView = arView else { return }
            do {
                try configureARSession(arView)
            } catch {
                ErrorLoggingService.shared.logSwiftError(error, context: "AR session restart after interruption failed")
            }
        }

        // MARK: - AR Session Lifecycle Management

        func pauseARSession() {
            guard let arView = arView else { return }
            // Pause the AR session to conserve battery
            arView.session.pause()
            // Pause face tracking
            faceTrackingService?.pauseTracking()
        }

        func resumeARSession() {
            guard let arView = arView else { return }
            // Configure and run AR session
            do {
                try configureARSession(arView)
            } catch {
                ErrorLoggingService.shared.logSwiftError(error, context: "AR session resume failed")
            }
            // Resume face tracking
            faceTrackingService?.resumeTracking()
        }

        func stopARSession() {
            guard let arView = arView else { return }
            // Completely stop the AR session
            arView.session.pause()
            // Stop face tracking
            faceTrackingService?.pauseTracking()
        }
    }
}

// MARK: - AR Capabilities

enum ARCapabilities {
    case none
    case worldTracking
    case faceTracking

    var displayName: String {
        switch self {
        case .none:
            return "No AR"
        case .worldTracking:
            return "AR (World Tracking)"
        case .faceTracking:
            return "AR (Face Tracking)"
        }
    }
}

// MARK: - Extensions

extension simd_float4x4 {
    var position: SIMD3<Float> {
        return SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }
}
