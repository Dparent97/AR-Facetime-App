//
//  PerformanceMonitor.swift
//  Aria's Magic SharePlay App
//
//  Monitors app performance metrics (FPS, memory, character count)
//

import Foundation
import SwiftUI
import os.log

/// Performance report structure
struct PerformanceReport: Codable {
    let timestamp: Date
    let avgFPS: Double
    let minFPS: Double
    let maxFPS: Double
    let avgMemoryMB: Double
    let maxMemoryMB: Double
    let droppedFrames: Int
    let characterCountAtPeak: Int
    let duration: TimeInterval

    var summary: String {
        """
        Performance Report (\(timestamp.formatted()))
        =====================================
        Duration: \(String(format: "%.1f", duration))s
        FPS: avg=\(String(format: "%.1f", avgFPS)) min=\(String(format: "%.1f", minFPS)) max=\(String(format: "%.1f", maxFPS))
        Memory: avg=\(String(format: "%.1f", avgMemoryMB))MB max=\(String(format: "%.1f", maxMemoryMB))MB
        Dropped Frames: \(droppedFrames)
        Peak Characters: \(characterCountAtPeak)
        """
    }
}

/// Performance monitoring service
class PerformanceMonitor: ObservableObject {

    // MARK: - Singleton

    static let shared = PerformanceMonitor()

    // MARK: - Published Properties

    @Published var currentFPS: Double = 60.0
    @Published var memoryUsageMB: Double = 0.0
    @Published var characterCount: Int = 0
    @Published var isPerformanceWarning: Bool = false
    @Published var isMonitoring: Bool = false

    // MARK: - Performance Thresholds

    private let fpsWarningThreshold: Double = 45.0
    private let memoryWarningThresholdMB: Double = 250.0
    private let targetFPS: Double = 60.0

    // MARK: - Tracking Data

    private var fpsHistory: [Double] = []
    private var memoryHistory: [Double] = []
    private var droppedFrameCount: Int = 0
    private var peakCharacterCount: Int = 0

    private var lastFrameTime: Date?
    private var monitoringStartTime: Date?

    private var monitoringTimer: Timer?
    private let monitoringInterval: TimeInterval = 0.5  // Update every 0.5s

    // MARK: - Initialization

    private init() {
        // Private initializer for singleton
    }

    // MARK: - Monitoring Control

    /// Start performance monitoring
    func startMonitoring() {
        guard !isMonitoring else { return }

        isMonitoring = true
        monitoringStartTime = Date()
        fpsHistory.removeAll()
        memoryHistory.removeAll()
        droppedFrameCount = 0
        peakCharacterCount = 0

        // Start monitoring timer
        monitoringTimer = Timer.scheduledTimer(
            withTimeInterval: monitoringInterval,
            repeats: true
        ) { [weak self] _ in
            self?.updateMetrics()
        }

        os_log("PerformanceMonitor: Started monitoring", log: .default, type: .info)
    }

    /// Stop performance monitoring
    func stopMonitoring() {
        guard isMonitoring else { return }

        isMonitoring = false
        monitoringTimer?.invalidate()
        monitoringTimer = nil

        os_log("PerformanceMonitor: Stopped monitoring", log: .default, type: .info)
    }

    // MARK: - Metrics Update

    private func updateMetrics() {
        updateFPS()
        updateMemoryUsage()
        checkPerformanceWarnings()
    }

    /// Update FPS calculation
    func updateFPS() {
        let now = Date()

        if let lastTime = lastFrameTime {
            let delta = now.timeIntervalSince(lastTime)
            if delta > 0 {
                let fps = 1.0 / delta
                currentFPS = fps

                // Track in history
                fpsHistory.append(fps)

                // Detect dropped frames (FPS significantly below target)
                if fps < targetFPS * 0.75 {
                    droppedFrameCount += 1
                }
            }
        }

        lastFrameTime = now
    }

    /// Update memory usage
    private func updateMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    $0,
                    &count
                )
            }
        }

        if kerr == KERN_SUCCESS {
            let memoryBytes = Double(info.resident_size)
            let memoryMB = memoryBytes / (1024.0 * 1024.0)
            memoryUsageMB = memoryMB
            memoryHistory.append(memoryMB)
        }
    }

    /// Check if performance warnings should be triggered
    private func checkPerformanceWarnings() {
        let fpsWarning = currentFPS < fpsWarningThreshold
        let memoryWarning = memoryUsageMB > memoryWarningThresholdMB

        isPerformanceWarning = fpsWarning || memoryWarning

        if isPerformanceWarning {
            os_log(
                "PerformanceMonitor: Warning - FPS: %.1f, Memory: %.1fMB",
                log: .default,
                type: .error,
                currentFPS,
                memoryUsageMB
            )
        }
    }

    // MARK: - Character Count Tracking

    /// Update character count
    /// - Parameter count: Current number of characters in scene
    func updateCharacterCount(_ count: Int) {
        characterCount = count
        if count > peakCharacterCount {
            peakCharacterCount = count
        }
    }

    // MARK: - Performance Report

    /// Generate performance report
    /// - Returns: Performance report with statistics
    func getPerformanceReport() -> PerformanceReport {
        let now = Date()
        let duration = monitoringStartTime.map { now.timeIntervalSince($0) } ?? 0

        let avgFPS = fpsHistory.isEmpty ? 0 : fpsHistory.reduce(0, +) / Double(fpsHistory.count)
        let minFPS = fpsHistory.min() ?? 0
        let maxFPS = fpsHistory.max() ?? 0

        let avgMemory = memoryHistory.isEmpty ? 0 : memoryHistory.reduce(0, +) / Double(memoryHistory.count)
        let maxMemory = memoryHistory.max() ?? 0

        return PerformanceReport(
            timestamp: now,
            avgFPS: avgFPS,
            minFPS: minFPS,
            maxFPS: maxFPS,
            avgMemoryMB: avgMemory,
            maxMemoryMB: maxMemory,
            droppedFrames: droppedFrameCount,
            characterCountAtPeak: peakCharacterCount,
            duration: duration
        )
    }

    /// Export performance report as JSON string
    /// - Returns: JSON string of performance report
    func exportReport() -> String? {
        let report = getPerformanceReport()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(report),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }

        return jsonString
    }

    // MARK: - Reset

    /// Reset all monitoring data
    func reset() {
        fpsHistory.removeAll()
        memoryHistory.removeAll()
        droppedFrameCount = 0
        peakCharacterCount = 0
        lastFrameTime = nil
        monitoringStartTime = nil
        currentFPS = 60.0
        memoryUsageMB = 0.0
        characterCount = 0
        isPerformanceWarning = false
    }

    // MARK: - Diagnostics

    /// Get current performance status summary
    var statusSummary: String {
        """
        FPS: \(String(format: "%.1f", currentFPS))
        Memory: \(String(format: "%.1f", memoryUsageMB))MB
        Characters: \(characterCount)
        Warning: \(isPerformanceWarning ? "YES" : "NO")
        """
    }

    /// Check if performance meets target thresholds
    var meetsPerformanceTargets: Bool {
        return currentFPS >= targetFPS * 0.9 && memoryUsageMB < memoryWarningThresholdMB
    }
}

// MARK: - Performance Stats View

/// SwiftUI view for displaying performance stats
struct PerformanceStatsView: View {
    @ObservedObject var monitor = PerformanceMonitor.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Performance")
                .font(.caption)
                .fontWeight(.bold)

            HStack {
                Text("FPS:")
                    .font(.caption2)
                Text(String(format: "%.1f", monitor.currentFPS))
                    .font(.caption2)
                    .foregroundColor(monitor.currentFPS >= 55 ? .green : .red)
            }

            HStack {
                Text("Memory:")
                    .font(.caption2)
                Text(String(format: "%.0fMB", monitor.memoryUsageMB))
                    .font(.caption2)
                    .foregroundColor(monitor.memoryUsageMB < 200 ? .green : .red)
            }

            HStack {
                Text("Characters:")
                    .font(.caption2)
                Text("\(monitor.characterCount)")
                    .font(.caption2)
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.7))
        .cornerRadius(8)
    }
}
