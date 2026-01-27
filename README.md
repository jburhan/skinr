# skinr
SkinR: Skincare Mirror Prototype

**Introduction**
The global beauty industry is worth trillions of dollars, the skincare market specifically is a large market estimated to be worth USD122.11 billion, with an annual growth of 6.84%. (Fortune Business Insights, 2025). While skincare is highly embedded in day-to-day routine, users often lack objective tools to track whether their skincare products work. There are existing technologies to guide users but these devices are expensive, non-portable, or not integrated with meaningful analytics. So, I proposed developing SkinR: Skincare Mirror to address this gap by combining IoT hardware, controlled imaging, and deterministic on-device computer vision to provide consistent and data privacy compliant skin analysis.

**High-Level Architecture**
The prototype of SkinR: Skincare Mirror consists of 4 major parts:
1. IoT Hardware (Raspberry Pi 5 + Pi Camera 8MP) I reused these from the picar-x project. I use them to capture standardized facial images on demand via HTTP endpoint.
2. Makeup Mirror I purchased this from Amazon. I specifically opted for 30cm x 25cm mirror size because it could provide the face-to-camera distance that I need to take high quality images for analysis: ~40 – 50 cm. The LED light provides consistent ~5000K daylight illumination for RGB-based analysis.
3. iOS App compatible with iPhone 16+
I built:
  SplashView – shows loading screen for brand marketing: Logo + Slogan
  CaptureView – shows the capture button and results (original and analyzed images) + scores and baseline comparison 
  CalibrationView – allows users to reset baseline and adjust analysis sensitivity. 
  ProgressView – shows day-over-day charts of daily median scores (pigmentation and redness)
  IngredientsView – shows the focus of the day and recommended ingredients based on pigmentation and redness analysis. 
  SettingsView – highlights data privacy commitment, baseline, a link to a page that explains how SkinR works for transparency (only used for this project)
  HowSkinrWorksView – explains the data pipeline, what the scores mean, what the limitations are, and best practices to ensure consistent results. 
  SkinAnalyzer – the code uses iPhone processing power to run full deterministic CV pipeline locally
  SkinrBrand – this is where I put the brand design: the color and the logo. I realized that from my time as a Product Manager. Selling and marketing a product is as important as building the product itself. 
4. Local Data Storage I opted to store all the data on-device to avoid cloud privacy issues.

**Project Phases**
The project was completed within 5 phases:
Phase 1 — Hardware Setup + MVP Definition
This is the phase where I gathered and put together the Pi, the camera, the mirror, controlled for consistent brightness, built basic iOS UI skeleton, and established Pi → iPhone capture flow by running server.py, testing the capture function on the iOS app.
Phase 2 — Deterministic CV on Python (Exploration)
In this phase, I built and tested the logic in Python on my computer. This is where I designed pigmentation and redness scoring, tested threshold behavior, identified effects of noise and illumination drift. I took three sample images and analyzed them using the logic that I built
Phase 3 — Port CV to iOS (Swift)
In this phase, I ported the Python logic to full Swift (SkinAnalyzer.swift) so I could process the images on-device. This allowed GPU-accelerated pixel processing, overlay rendering, capture history + per-capture scoring, baseline resets + calibration sliders
Phase 4 — Progress Tracking, Ingredient Recommendation, and UI Polish
In this phase, I added more features to the app. Such as: 
Daily median score chart, I used the median to remove outliers caused by environmental reasons, history view with timestamps
Recommended ingredients to use based on pigmentation and redness scores:
I did research on common active skincare ingredients: sunscreen, niacinamide, vitamin C, tranexamic acid, kojic Acid, hydroquinone, retinoids, and their evidence-based effectiveness
UI polish for shippability: Brand design and UX polish that includes App icon, logo, colors, and slogans. 
Phase 5 — GDPR Compliance
Data privacy is very strong in Switzerland where I live now, so I decided to implement local-only storage instead of cloud, transparent “How SkinR Works” page, and a feature to allow full data deletion

**Evaluation**
This product is meant to bridge cosmetic and clinical uses. So, experiments and testing were conducted and these include making multiple captures at different times of day, verifying day-over-day score consistency, and validating that pigmentation/redness trends minimally track lighting changes. However, I only have a single-user dataset: me, so it limits model generality. I also found that the lack of segmentation limits ROI (face detection) effectiveness.
Performance
Capture speed is slower than expected because it is affected by mirror–Pi power separation. And iPhone 17 Pro used for CV to ensure real-time processing, older iPhone models might not work as fast. In the future, I hope to optimize Pi capture latency by LED→camera synchronization.
Future Iterations
Future iterations are encouraged post-class to productize this project. These include, without specific timelines:
Hardware iterations
Custom-built one-way mirror with central camera port, NOIR camera + UVA 365 nm LEDs, NIR illumination (850/940 nm), Multispectral sensors, Battery-powered portable redesign, and possibly custom PCB for mass production
Software iterations
True face ROI detection, replacing deterministic CV with hybrid ML models, faster Pi capture pipeline, and LLM-based skincare consultation feature, and definitely more research-based ingredients. 

**Conclusion**
This project succeeded in producing a working end-to-end core IoT prototype:
A Pi-based imaging system, a fully functional and bespoke iOS app, deterministic CV pipeline, score tracking + overlays, calibration, baseline, data compliance, ingredient recommendation engine, and branding + UI polish.
