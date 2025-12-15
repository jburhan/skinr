// IngredientsView.swift
import SwiftUI

struct IngredientsView: View {
    @ObservedObject var store: CaptureStore
    @ObservedObject var settings: SettingsStore

    private var latestRecord: CaptureRecord? {
        store.records.sorted { $0.timestamp < $1.timestamp }.last
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SkinrBrandHeader()

                    if let record = latestRecord {
                        let pig = record.pigmentationScore
                        let red = record.rednessScore
                        let focus = focus(for: pig, red: red)

                        focusSummaryView(pigScore: pig, redScore: red, focus: focus)

                        ingredientsSections(pigScore: pig, redScore: red, focus: focus)

                        safetySection
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("No scans yet")
                                .font(.headline)
                            Text("Capture at least one picture to unlock personalized ingredient suggestions.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 24)
                    }

                    Spacer(minLength: 24)
                }
                .padding()
            }
            .background(Color.skinrOffWhite.ignoresSafeArea())
            .navigationTitle("Ingredients")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Focus

    private enum Focus {
        case pigmentation
        case redness
        case balanced
    }

    private func focus(for pig: Int, red: Int) -> Focus {
        let pigExcess = pig - 50
        let redExcess = red - 50

        if pigExcess >= 15 && redExcess <= 10 {
            return .pigmentation
        } else if redExcess >= 15 && pigExcess <= 10 {
            return .redness
        } else {
            return .balanced
        }
    }

    // MARK: - UI Sections

    @ViewBuilder
    private func focusSummaryView(pigScore: Int, redScore: Int, focus: Focus) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today’s focus")
                .font(.headline)

            HStack(alignment: .center, spacing: 12) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.skinrTeal.opacity(0.1))
                    .frame(minHeight: 90)
                    .overlay(
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(focusTitle(for: focus))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.skinrCharcoal)

                                Text(focusSubtitle(for: focus))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 6)
                            Spacer()
                        }
                        .padding(.horizontal)
                    )
            }
            .padding(.bottom, 8)        


            HStack(spacing: 16) {
                scorePill(
                    title: "Pigmentation",
                    score: pigScore,
                    color: .brown
                )
                scorePill(
                    title: "Redness",
                    score: redScore,
                    color: .red
                )
            }
        }
    }

    private func focusTitle(for focus: Focus) -> String {
        switch focus {
        case .pigmentation: return "Even out pigmentation"
        case .redness:      return "Calm redness & sensitivity"
        case .balanced:     return "Balance tone & calm redness"
        }
    }

    private func focusSubtitle(for focus: Focus) -> String {
        switch focus {
        case .pigmentation:
            return "Your pigmentation score is more elevated than redness today."
        case .redness:
            return "Your redness score is more elevated than pigmentation today."
        case .balanced:
            return "Pigmentation and redness are both relevant. Focus on gentle, multi-tasking actives."
        }
    }

    @ViewBuilder
    private func scorePill(title: String, score: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack {
                Text("\(score)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.skinrCharcoal)
                Spacer()
            }
            ProgressView(value: Double(score), total: 100.0)
                .accentColor(color)
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Ingredient model

    struct Ingredient: Identifiable {
        enum Category {
            case pigmentation
            case redness
            case both
            case advanced
        }

        enum IrritationRisk: String {
            case low = "Low"
            case medium = "Medium"
            case high = "High"
        }

        let id = UUID()
        let name: String
        let tagline: String
        let category: Category
        let evidence: String
        let whenToUse: String
        let bestForm: String
        let notes: String
        let irritationRisk: IrritationRisk
    }

    // MARK: - Ingredient selection

    @ViewBuilder
    private func ingredientsSections(pigScore: Int, redScore: Int, focus: Focus) -> some View {
        let pigmentItems = pigmentationIngredients(for: pigScore, redScore: redScore)
        let rednessItems = rednessIngredients(for: pigScore, redScore: redScore)
        let advancedItems = advancedDiscussionIngredients(for: pigScore, redScore: redScore)

        VStack(alignment: .leading, spacing: 16) {
            if !pigmentItems.isEmpty {
                Text("For pigmentation")
                    .font(.headline)
                VStack(spacing: 12) {
                    ForEach(pigmentItems) { ingredient in
                        IngredientCardView(ingredient: ingredient)
                    }
                }
            }

            if !rednessItems.isEmpty {
                Text("For redness & sensitivity")
                    .font(.headline)
                    .padding(.top, 8)
                VStack(spacing: 12) {
                    ForEach(rednessItems) { ingredient in
                        IngredientCardView(ingredient: ingredient)
                    }
                }
            }

            if !advancedItems.isEmpty {
                Text("Ask a dermatologist about")
                    .font(.headline)
                    .padding(.top, 8)
                VStack(spacing: 12) {
                    ForEach(advancedItems) { ingredient in
                        IngredientCardView(ingredient: ingredient)
                    }
                }
            }
        }
    }

    private func pigmentationIngredients(for pigScore: Int, redScore: Int) -> [Ingredient] {
        var items: [Ingredient] = []

        // Always: sunscreen
        items.append(
            Ingredient(
                name: "Broad-spectrum sunscreen",
                tagline: "Non-negotiable for any pigmentation work",
                category: .pigmentation,
                evidence: "Strong",
                whenToUse: "AM, every day, reapply outdoors",
                bestForm: "SPF 30–50+, UVA + visible light; consider tinted mineral SPF if prone to dark spots",
                notes: "UV and visible light are major drivers of hyperpigmentation. Consistent SPF is the most important step.",
                irritationRisk: .low
            )
        )

        // Niacinamide – safe backbone, also helps redness.
        items.append(
            Ingredient(
                name: "Niacinamide (≈4–5%)",
                tagline: "Brightening + barrier support",
                category: .both,
                evidence: "Strong",
                whenToUse: "AM or PM, 1–2× daily",
                bestForm: "Serum or moisturizer with 2–5% niacinamide",
                notes: "Helps reduce uneven pigmentation and calms redness while supporting the skin barrier.",
                irritationRisk: .low
            )
        )

        if pigScore >= 60 {
            // Vitamin C
            items.append(
                Ingredient(
                    name: "Vitamin C",
                    tagline: "Antioxidant support + pigment control",
                    category: .pigmentation,
                    evidence: "Strong",
                    whenToUse: "AM, under sunscreen",
                    bestForm: "Stabilized vitamin C serum; use lower strengths if sensitive",
                    notes: "Supports brightening and UV protection. Pure L-ascorbic can be irritating at high strengths.",
                    irritationRisk: redScore >= 60 ? .medium : .medium
                )
            )

            // Tranexamic acid
            items.append(
                Ingredient(
                    name: "Tranexamic acid (topical)",
                    tagline: "Targeted dark-spot support",
                    category: .pigmentation,
                    evidence: "Strong",
                    whenToUse: "PM, 1× daily",
                    bestForm: "Serum with ~2–5% tranexamic acid",
                    notes: "Useful for stubborn dark spots and melasma when combined with strict sun protection.",
                    irritationRisk: .low
                )
            )
        }

        if pigScore >= 70 {
            // Kojic / arbutin / licorice
            items.append(
                Ingredient(
                    name: "Kojic acid / arbutin / licorice extract",
                    tagline: "Additional pigment modulators",
                    category: .pigmentation,
                    evidence: "Moderate",
                    whenToUse: "PM, alternate nights with other actives",
                    bestForm: "Spot-treatment serum or cream in low–moderate strength",
                    notes: "Use cautiously and avoid layering too many strong brighteners at once to reduce irritation risk.",
                    irritationRisk: .medium
                )
            )
        }

        return items
    }

    private func rednessIngredients(for pigScore: Int, redScore: Int) -> [Ingredient] {
        var items: [Ingredient] = []

        // Barrier support – always safe
        items.append(
            Ingredient(
                name: "Ceramides + cholesterol + fatty acids",
                tagline: "Barrier-repairing moisturizer",
                category: .redness,
                evidence: "Strong",
                whenToUse: "AM and PM",
                bestForm: "Fragrance-free cream with ceramides and humectants",
                notes: "Chronic redness often improves when the barrier is strengthened with ceramides and gentle moisturizers.",
                irritationRisk: .low
            )
        )

        items.append(
            Ingredient(
                name: "Soothing ingredients",
                tagline: "Calm visible redness",
                category: .redness,
                evidence: "Moderate",
                whenToUse: "AM and/or PM, as needed",
                bestForm: "Moisturizer or serum with colloidal oatmeal, centella, green tea, or licorice",
                notes: "Look for formulas aimed at redness-prone or sensitive skin. Avoid strong fragrances and drying alcohols.",
                irritationRisk: .low
            )
        )

        // Niacinamide is already in pigmentation section, but it’s also relevant here.
        if redScore >= 60 {
            items.append(
                Ingredient(
                    name: "Niacinamide (low–moderate strength)",
                    tagline: "Anti-inflammatory + barrier-support",
                    category: .both,
                    evidence: "Strong",
                    whenToUse: "AM or PM",
                    bestForm: "Gentle serum or moisturizer; avoid stacking with too many other actives",
                    notes: "Helps reduce redness and sensitivity over time, especially alongside a good barrier moisturizer.",
                    irritationRisk: .low
                )
            )
        }

        // Azelaic acid useful when both pigment + redness are issues
        if redScore >= 60 || pigScore >= 60 {
            items.append(
                Ingredient(
                    name: "Azelaic acid (≈10%)",
                    tagline: "Bridges pigment and redness",
                    category: .both,
                    evidence: "Strong",
                    whenToUse: "PM, start 2–3× per week",
                    bestForm: "Leave-on cream or gel around 10%",
                    notes: "Can help with both uneven tone and redness. Introduce gradually; mild tingling is common at first.",
                    irritationRisk: .medium
                )
            )
        }

        return items
    }

    private func advancedDiscussionIngredients(for pigScore: Int, redScore: Int) -> [Ingredient] {
        var items: [Ingredient] = []

        if pigScore >= 70 {
            items.append(
                Ingredient(
                    name: "Retinoids (retinol, tretinoin, adapalene)",
                    tagline: "Advanced pigment and texture support",
                    category: .advanced,
                    evidence: "Strong",
                    whenToUse: "PM only, introduce slowly",
                    bestForm: "Start with OTC retinol; stronger options require medical supervision",
                    notes: "Effective but often irritating. Discuss with a dermatologist if you have persistent pigmentation or sensitive skin.",
                    irritationRisk: .high
                )
            )

            items.append(
                Ingredient(
                    name: "Hydroquinone",
                    tagline: "Prescription-strength lightening agent",
                    category: .advanced,
                    evidence: "Strong",
                    whenToUse: "Short-term, under medical supervision",
                    bestForm: "Dermatologist-prescribed formulation, often combined with other actives",
                    notes: "Can be very effective but carries risk of misuse and side effects. Only use under a dermatologist’s guidance.",
                    irritationRisk: .high
                )
            )
        }

        if redScore >= 70 {
            items.append(
                Ingredient(
                    name: "Prescription rosacea treatments",
                    tagline: "For persistent or severe redness",
                    category: .advanced,
                    evidence: "Strong",
                    whenToUse: "As directed by a dermatologist",
                    bestForm: "Topicals like metronidazole, ivermectin, azelaic 15%, or vasoconstrictor gels",
                    notes: "If redness is painful, with bumps, burning, or eye symptoms, a dermatologist visit is more appropriate than more cosmetics.",
                    irritationRisk: .medium
                )
            )
        }

        return items
    }

    // MARK: - Ingredient card view

    struct IngredientCardView: View {
        let ingredient: Ingredient

        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(ingredient.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.skinrCharcoal)
                    Spacer()
                    Text(ingredient.evidence)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.skinrTeal.opacity(0.12))
                        .cornerRadius(6)
                }

                Text(ingredient.tagline)
                    .font(.footnote)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("When to use")
                        .font(.caption2)
                        .fontWeight(.semibold)
                    Text(ingredient.whenToUse)
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text("Best form")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.top, 2)
                    Text(ingredient.bestForm)
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    if !ingredient.notes.isEmpty {
                        Text("Notes")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.top, 2)
                        Text(ingredient.notes)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                HStack {
                    Text("Irritation risk: \(ingredient.irritationRisk.rawValue)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }

    // MARK: - Safety section

    private var safetySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Important")
                .font(.headline)
                .padding(.top, 8)

            Text("SkinR suggests cosmetic ingredients based on visible pigmentation and redness. It does not diagnose conditions or replace professional medical advice.")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("See a dermatologist if you notice:")
                .font(.caption)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text("• Painful, burning, or very sudden redness")
                Text("• Swelling, pus, or eye symptoms")
                Text("• Rapidly changing moles or lesions")
                Text("• Persistent dark patches that do not improve with strict sun protection")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.top, 12)
    }
}
