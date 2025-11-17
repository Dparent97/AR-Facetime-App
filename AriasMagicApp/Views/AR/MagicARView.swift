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
    var isActive: Bool = true  // Control AR session state

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Configure AR session for face tracking
        let configuration = ARFaceTrackingConfiguration()
        if ARFaceTrackingConfiguration.isSupported {
            configuration.isWorldTrackingEnabled = true
            arView.session.run(configuration)
        } else {
            // Fallback to world tracking without face tracking
            let worldConfig = ARWorldTrackingConfiguration()
            worldConfig.planeDetection = [.horizontal]
            arView.session.run(worldConfig)
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
        Coordinator(viewModel: viewModel)
    }

    class Coordinator: NSObject, ARSessionDelegate {
        var viewModel: CharacterViewModel
        weak var arView: ARView?
        var mainAnchor: AnchorEntity?
        var selectedEntity: ModelEntity?
        var faceTrackingService: FaceTrackingService?

        init(viewModel: CharacterViewModel) {
            self.viewModel = viewModel
            super.init()
            self.faceTrackingService = FaceTrackingService(delegate: self)
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
                if let entity = character.entity {
                    anchor.addChild(entity)
                }
            }
        }

        // ARSessionDelegate
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            for anchor in anchors {
                if let faceAnchor = anchor as? ARFaceAnchor {
                    faceTrackingService?.processFaceAnchor(faceAnchor)
                }
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
            let configuration = ARFaceTrackingConfiguration()
            if ARFaceTrackingConfiguration.isSupported {
                configuration.isWorldTrackingEnabled = true
                arView.session.run(configuration)
            } else {
                // Fallback to world tracking without face tracking
                let worldConfig = ARWorldTrackingConfiguration()
                worldConfig.planeDetection = [.horizontal]
                arView.session.run(worldConfig)
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

// Extension to extract position from transform
extension simd_float4x4 {
    var position: SIMD3<Float> {
        return SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }
}
