// CaptureStore.swift

import Foundation
import UIKit
import Combine
import SwiftUI

struct CaptureRecord: Identifiable, Codable {
    let id: UUID
    let originalFilename: String
    let overlayFilename: String
    let timestamp: Date
    let pigmentationScore: Int
    let rednessScore: Int
}

final class CaptureStore: ObservableObject {
    @Published var records: [CaptureRecord] = []

    private let indexFilename = "captures.json"

    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var indexURL: URL {
        documentsURL.appendingPathComponent(indexFilename)
    }

    init() {
        load()
    }

    // MARK: - Public API

    func addCapture(
        original: UIImage,
        overlay: UIImage,
        pigScore: Int,
        redScore: Int
    ) {
        guard
            let originalData = original.jpegData(compressionQuality: 0.9),
            let overlayData = overlay.jpegData(compressionQuality: 0.9)
        else { return }

        let id = UUID()

        let origFilename = "capture_orig_\(id.uuidString).jpg"
        let overlayFilename = "capture_overlay_\(id.uuidString).jpg"

        let origURL = documentsURL.appendingPathComponent(origFilename)
        let overlayURL = documentsURL.appendingPathComponent(overlayFilename)

        do {
            try originalData.write(to: origURL)
            try overlayData.write(to: overlayURL)
        } catch {
            print("Error saving images:", error)
            return
        }

        let record = CaptureRecord(
            id: id,
            originalFilename: origFilename,
            overlayFilename: overlayFilename,
            timestamp: Date(),
            pigmentationScore: pigScore,
            rednessScore: redScore
        )

        // newest first
        records.insert(record, at: 0)
        save()
    }

    func delete(record: CaptureRecord) {
        // Find the index of this record
        guard let index = records.firstIndex(where: { $0.id == record.id }) else { return }

        let recordToDelete = records[index]

        // Remove files from disk
        let origURL = documentsURL.appendingPathComponent(recordToDelete.originalFilename)
        let overlayURL = documentsURL.appendingPathComponent(recordToDelete.overlayFilename)

        try? FileManager.default.removeItem(at: origURL)
        try? FileManager.default.removeItem(at: overlayURL)

        // Remove from in-memory array and save JSON
        records.remove(at: index)
        save()
    }
    
    func deleteAllCaptures() {
        let fm = FileManager.default

        // Remove all image files
        for record in records {
            let origURL = documentsURL.appendingPathComponent(record.originalFilename)
            let overlayURL = documentsURL.appendingPathComponent(record.overlayFilename)

            try? fm.removeItem(at: origURL)
            try? fm.removeItem(at: overlayURL)
        }

        // Clear in-memory list
        records.removeAll()
        save()
    }

    func image(for filename: String) -> UIImage? {
        let url = documentsURL.appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }

    func originalImage(for record: CaptureRecord) -> UIImage? {
        image(for: record.originalFilename)
    }

    func overlayImage(for record: CaptureRecord) -> UIImage? {
        image(for: record.overlayFilename)
    }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: indexURL)
        } catch {
            print("Error saving capture index:", error)
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: indexURL.path) else { return }
        do {
            let data = try Data(contentsOf: indexURL)
            let decoded = try JSONDecoder().decode([CaptureRecord].self, from: data)
            self.records = decoded
        } catch {
            print("Error loading capture index:", error)
        }
    }
}
