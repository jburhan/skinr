# SkinR — Smart Skincare Mirror

**Author:** Jimmy Burhan
**Project Type:** IoT · Computer Vision · iOS Application  

**Demo Videos:**  
- Hardware Demo  
- App Demo  
- Code Demo

---

## Introduction

The global beauty industry is valued in the trillions of dollars, with the skincare market alone estimated at **USD 122.11 billion**, growing at an annual rate of **6.84%** (Fortune Business Insights, 2025). Despite skincare being deeply embedded in daily routines, users lack objective and repeatable tools to assess whether their products are effective.

Existing solutions are often expensive, non-portable, or disconnected from meaningful analytics, while also raising privacy concerns. To address this gap, I developed **SkinR**, a smart skincare mirror that combines **IoT hardware**, **controlled imaging**, and **deterministic on-device computer vision** to deliver consistent, privacy-preserving skin analysis.

---

## High-Level Architecture

SkinR consists of four primary components.

### 1. IoT Hardware

- Raspberry Pi 5  
- Raspberry Pi Camera (8MP)

These components were reused from the PiCar-X project and are used to capture standardized facial images on demand via an HTTP endpoint.

---

### 2. Makeup Mirror

- Purchased from Amazon  
- Mirror size: **30 × 25 cm**  
- Face-to-camera distance: **~40–50 cm**  
- LED lighting: **~5000K daylight**

The mirror size and lighting were selected to ensure consistent illumination and sufficient image quality for RGB-based analysis.

---

### 3. iOS Application (iPhone 16+)

The iOS app serves as the primary user interface and performs all image analysis locally.

#### Views

- **SplashView** — Branding and loading screen (logo + slogan)  
- **CaptureView** — Image capture, analysis results, overlays, baseline comparison, and scores  
- **CalibrationView** — Baseline reset and sensitivity adjustment  
- **ProgressView** — Day-over-day charts using daily median pigmentation and redness scores  
- **IngredientsView** — Recommended skincare ingredients based on analysis results  
- **SettingsView** — Data privacy, baseline management, and transparency  
- **HowSkinRWorksView** — Explains the pipeline, score interpretation, limitations, and best practices  

---

### 4. On-Device Processing & Branding

- **SkinAnalyzer** — Deterministic computer vision pipeline executed entirely on-device in Swift  
- **SkinRBrand** — Centralized branding system (logo, colors, typography)

---

## Data Storage & Privacy

All data is stored **locally on the device**. No cloud storage or third-party analytics are used, ensuring compliance with Swiss and EU data privacy standards.

---

## Computer Vision Pipeline

The analysis scope was limited to features achievable using **RGB lighting only**.

### Pigmentation Detection
- Grayscale conversion to measure darkness intensity  
- Luminance percentile-based thresholding  

### Redness Detection
- HSV color space isolation of red hue ranges  
- Saturation gating to suppress noise  

#### Rationale
- Single experimental subject  
- Acne and sebum detection require UV fluorescence  
- Aging and dryness detection require additional sensors  
- RGB imaging is sufficient for pigmentation and redness trends  

---

## Normalization & Noise Control

- Luminance standardization to reduce exposure drift  
- ROI masking to approximate facial areas  
- Background and hair exclusion  
- Visual debugging overlays:
  - Green for pigmentation  
  - Red for redness  

The system prioritizes **day-to-day trends** over absolute scores.

---

## Project Phases

### Phase 1 — Hardware Setup & MVP Definition
- Hardware assembly  
- Controlled lighting setup  
- iOS UI skeleton  
- Pi → iPhone capture pipeline via `server.py`

### Phase 2 — CV Exploration (Python)
- Algorithm prototyping  
- Threshold tuning  
- Noise and illumination testing  

### Phase 3 — CV Port to Swift
- Full rewrite of CV logic in `SkinAnalyzer.swift`  
- GPU-accelerated on-device processing  
- Capture history, overlays, and calibration  

### Phase 4 — Analytics, Recommendations & UI Polish
- Daily median score charts  
- Ingredient recommendations based on evidence-based research:
  - Sunscreen, niacinamide, vitamin C  
  - Tranexamic acid, kojic acid, hydroquinone  
  - Retinoids  
- Branding and UX refinement  

### Phase 5 — GDPR Compliance
- Local-only storage  
- Transparent “How SkinR Works” documentation  
- Full data deletion feature  

---

## Evaluation

Testing included:
- Multiple captures at different times of day  
- Day-over-day trend consistency checks  
- Sensitivity analysis under lighting variation  

Limitations:
- Single-user dataset  
- No true facial segmentation  

---

## Performance

- Capture latency affected by mirror–Pi power separation  
- CV processing tested on iPhone 17 Pro  
- Future optimization will focus on LED–camera synchronization  

---

## Future Iterations

### Hardware
- Custom one-way mirror with central camera port  
- NOIR camera + 365 nm UVA LEDs  
- NIR illumination (850/940 nm)  
- Multispectral sensors  
- Battery-powered portable design  
- Custom PCB for scalability  

### Software
- True face detection and segmentation  
- Hybrid deterministic + ML models  
- Faster capture pipeline  
- LLM-based skincare consultation  
- Expanded ingredient knowledge base  

---

## Conclusion

This project successfully delivered a **fully functional end-to-end IoT prototype**, including a Pi-based imaging system, a bespoke iOS application, a deterministic on-device computer vision pipeline, trend tracking, calibration, ingredient recommendations, privacy-first architecture, and polished branding.
