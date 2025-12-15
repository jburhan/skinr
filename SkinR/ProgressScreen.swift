// ProgressScreen.swift

import SwiftUI
import Charts

struct ProgressScreen: View {
    @ObservedObject var store: CaptureStore
    @ObservedObject var settings: SettingsStore

    private let dateTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()

    // Sorted records (oldest → newest)
    private var sortedRecords: [CaptureRecord] {
        store.records.sorted { $0.timestamp < $1.timestamp }
    }

    // Daily medians for chart
    private var dailyAggregates: [DailyAggregate] {
        aggregateByDay(records: sortedRecords)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Progress")
                    .padding(.top)
                    .font(.title)
                    .fontWeight(.bold)
                Text("Daily median scores")
                    .font(.headline)
                    .foregroundColor(.secondary)
                if store.records.isEmpty {
                    Text("No captures yet")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // LINE CHART: daily median pigmentation (brown) and redness (red)
                    Chart {
                        ForEach(dailyAggregates) { day in
                            // Pigmentation
                            LineMark(
                                x: .value("Date", day.date),
                                y: .value("Score", day.pigMedian)
                            )
                            .foregroundStyle(by: .value("Metric", "Pigmentation"))
                            .interpolationMethod(.catmullRom)

                            PointMark(
                                x: .value("Date", day.date),
                                y: .value("Score", day.pigMedian)
                            )
                            .foregroundStyle(by: .value("Metric", "Pigmentation"))

                            // Redness
                            LineMark(
                                x: .value("Date", day.date),
                                y: .value("Score", day.redMedian)
                            )
                            .foregroundStyle(by: .value("Metric", "Redness"))
                            .interpolationMethod(.catmullRom)

                            PointMark(
                                x: .value("Date", day.date),
                                y: .value("Score", day.redMedian)
                            )
                            .foregroundStyle(by: .value("Metric", "Redness"))
                        }
                    }
                    .frame(height: 260)
                    .chartForegroundStyleScale([
                        "Pigmentation": .brown,
                        "Redness": .red
                    ])

                    // DETAILED LIST BELOW CHART
                    List {
                        ForEach(sortedRecords) { record in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(dateTimeFormatter.string(from: record.timestamp))
                                    .font(.subheadline)

                                HStack {
                                    Text("Pigmentation: \(record.pigmentationScore)")
                                    Text("•")
                                    Text("Redness: \(record.rednessScore)")
                                }
                                .font(.footnote)

                                if let basePig = settings.baselinePigmentation {
                                    let deltaPig = record.pigmentationScore - basePig
                                    Text("Δ Pig vs baseline: \(deltaPig >= 0 ? "+" : "")\(deltaPig)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }

                                if let baseRed = settings.baselineRedness {
                                    let deltaRed = record.rednessScore - baseRed
                                    Text("Δ Red vs baseline: \(deltaRed >= 0 ? "+" : "")\(deltaRed)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }

                Spacer()
            }
            .padding()
        }
    }

    // MARK: - Daily aggregation (median per day)

    private func aggregateByDay(records: [CaptureRecord]) -> [DailyAggregate] {
        var buckets: [Date: [CaptureRecord]] = [:]
        let calendar = Calendar.current

        // Group records by day (startOfDay)
        for r in records {
            let day = calendar.startOfDay(for: r.timestamp)
            buckets[day, default: []].append(r)
        }

        // Build DailyAggregate array
        var result: [DailyAggregate] = []
        for (day, recs) in buckets {
            let pigValues = recs.map { $0.pigmentationScore }
            let redValues = recs.map { $0.rednessScore }

            let pigMedian = median(of: pigValues)
            let redMedian = median(of: redValues)

            result.append(
                DailyAggregate(
                    date: day,
                    pigMedian: pigMedian,
                    redMedian: redMedian
                )
            )
        }

        // Sort by date ascending
        result.sort { $0.date < $1.date }
        return result
    }

    private func median(of values: [Int]) -> Int {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let mid = sorted.count / 2
        if sorted.count % 2 == 1 {
            return sorted[mid]
        } else {
            let a = sorted[mid - 1]
            let b = sorted[mid]
            return Int(Double(a + b) / 2.0)
        }
    }
}

// Helper type for chart data
struct DailyAggregate: Identifiable {
    let id = UUID()
    let date: Date
    let pigMedian: Int
    let redMedian: Int
}
