import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query private var goalProfiles: [GoalProfile]
    @Query private var weightEntries: [WeightEntry]
    @Query private var mealTemplates: [MealTemplate]
    @Query private var tdeeStates: [TDEEAdjustmentState]

    @State private var viewingDate = Calendar.current.startOfDay(for: Date())
    @State private var currentLog: DailyLog?
    @State private var showWeighIn = false
    @State private var showCalLog = false
    @State private var showScreenshot = false
    @State private var weighInText = ""
    @State private var calText = ""
    @State private var protText = ""
    @State private var carbsText = ""
    @State private var fatText = ""

    var profile: UserProfile? { userProfiles.first }
    var goal: GoalProfile? { goalProfiles.first }
    var tdeeState: TDEEAdjustmentState? { tdeeStates.first }

    var isViewingToday: Bool { Calendar.current.isDateInToday(viewingDate) }

    var bodyComp: BodyComposition? {
        guard let p = profile, let g = goal else { return nil }
        return CalculationEngine.bodyComposition(profile: p, goal: g, tdeeState: tdeeState)
    }

    var sevenDayAvg: Double? {
        CalculationEngine.sevenDayAverage(entries: weightEntries)
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                LockInTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        dateNavHeader
                        headerCard
                        nutritionCard
                        if let log = currentLog {
                            DailyChecklistView(log: log)
                                .padding(.horizontal)
                        }
                        quickActions
                        Spacer(minLength: 80)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("LOCKIN")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(LockInTheme.accent)
                        .shadow(color: LockInTheme.accent.opacity(0.55), radius: 8)
                }
            }
        }
        .onAppear { loadOrCreateLog() }
        .onChange(of: viewingDate) { loadOrCreateLog() }
        .sheet(isPresented: $showWeighIn) { weighInSheet }
        .sheet(isPresented: $showCalLog)  { calLogSheet }
        .sheet(isPresented: $showScreenshot) {
            ScreenshotImportView(isPresented: $showScreenshot) { cal, prot, carbs, fat in
                saveCalories(cal, prot, carbs, fat)
            }
        }
    }

    // MARK: - Date Nav
    private var dateNavHeader: some View {
        HStack {
            Button {
                viewingDate = Calendar.current.date(byAdding: .day, value: -1, to: viewingDate) ?? viewingDate
            } label: {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold))
                    .foregroundColor(LockInTheme.accent)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(isViewingToday ? "Today" : currentLog?.dateFormatted ?? dateFormatted(viewingDate))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isViewingToday ? LockInTheme.textPrimary : LockInTheme.warning)
                if !isViewingToday {
                    Text("Past Day \u2014 tap items to edit")
                        .font(.system(size: 11))
                        .foregroundColor(LockInTheme.textMuted)
                }
            }

            Spacer()

            Button {
                let next = Calendar.current.date(byAdding: .day, value: 1, to: viewingDate) ?? viewingDate
                if next <= Calendar.current.startOfDay(for: Date()) {
                    viewingDate = next
                }
            } label: {
                Image(systemName: "chevron.right").font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isViewingToday ? LockInTheme.textMuted : LockInTheme.accent)
                    .frame(width: 44, height: 44)
            }
            .disabled(isViewingToday)
        }
        .padding(.horizontal)
    }

    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    if let goal {
                        Text("Day \(goal.daysElapsed)")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundColor(LockInTheme.accent)
                            .shadow(color: LockInTheme.accent.opacity(0.55), radius: 10)
                    }
                    if let w = profile?.currentWeightLb {
                        Text(String(format: "%.1f lb", w))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(LockInTheme.textPrimary)
                    }
                    if let avg = sevenDayAvg {
                        Text(String(format: "7d avg: %.1f lb", avg))
                            .font(.system(size: 12))
                            .foregroundColor(LockInTheme.textSecondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    if let goal {
                        Text("\(goal.daysRemaining)")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundColor(LockInTheme.textPrimary)
                        Text("days left")
                            .font(.system(size: 12))
                            .foregroundColor(LockInTheme.textSecondary)
                    }
                    if let log = currentLog {
                        Text("\(log.totalPoints) pts")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(LockInTheme.success)
                    }
                }
            }

            // Streak + compliance
            if let log = currentLog {
                HStack(spacing: 8) {
                    let score = log.complianceScore
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4).fill(LockInTheme.border).frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(scoreColor(score))
                            .frame(width: max(8, CGFloat(score) / 100.0 * (UIScreen.main.bounds.width - 80)), height: 8)
                            .shadow(color: scoreColor(score).opacity(0.5), radius: 4)
                    }
                    Text("\(score)%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(scoreColor(score))
                        .frame(width: 36)
                }
            }
        }
        .padding(16).cardStyle().padding(.horizontal)
    }

    // MARK: - Nutrition Card
    private var nutritionCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("NUTRITION").font(.system(size: 11, weight: .semibold)).foregroundColor(LockInTheme.textMuted)
                Spacer()
                Button("Open MND") { Task { await MyNetDiaryManager.shared.openMND() } }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(LockInTheme.accent)
            }

            let calories = currentLog?.actualCalories ?? 0
            let protein  = currentLog?.actualProtein  ?? 0
            let carbs    = currentLog?.actualCarbs    ?? 0
            let fat      = currentLog?.actualFat      ?? 0
            let calTarget  = goal?.dailyCalorieTarget  ?? 1900
            let protTarget = goal?.dailyProteinTarget  ?? 145
            let tdee       = Int(bodyComp?.tdee ?? 2175)

            // Calories row
            nutritionRow(
                label: "Calories",
                value: calories, target: calTarget,
                color: calorieColor(calories, target: calTarget, tdee: tdee)
            )

            // Protein row
            nutritionRow(
                label: "Protein",
                value: protein, target: protTarget,
                unit: "g",
                color: protein >= protTarget ? LockInTheme.success : LockInTheme.warning
            )

            // Carbs + Fat (shown when imported)
            if carbs > 0 || fat > 0 {
                HStack(spacing: 12) {
                    nutritionMini("Carbs", value: carbs, unit: "g")
                    nutritionMini("Fat",   value: fat,   unit: "g")
                }
            }

            // Log buttons
            HStack(spacing: 10) {
                SecondaryButton("Update Manually", icon: "pencil") { showCalLog = true }
                SecondaryButton("Import Screenshot", icon: "camera.viewfinder") { showScreenshot = true }
            }
        }
        .padding(16).cardStyle().padding(.horizontal)
    }

    // MARK: - Quick Actions
    private var quickActions: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "Quick Actions").padding(.horizontal)
            HStack(spacing: 12) {
                quickBtn("Weigh In", icon: "scalemass", color: LockInTheme.accent) {
                    weighInText = profile.map { String(format: "%.1f", $0.currentWeightLb) } ?? ""
                    showWeighIn = true
                }
                quickBtn("Log Food", icon: "fork.knife", color: LockInTheme.success) {
                    showCalLog = true
                }
                quickBtn("Open MND", icon: "arrow.up.right.square", color: LockInTheme.accentAlt) {
                    Task { await MyNetDiaryManager.shared.openMND() }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Weigh-In Sheet
    private var weighInSheet: some View {
        NavigationStack {
            ZStack {
                LockInTheme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("Log Weight").font(.system(size: 22, weight: .bold)).foregroundColor(.white)
                    TextField("e.g. 168.5", text: $weighInText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 20))
                    PrimaryButton("Save") {
                        if let val = Double(weighInText) { saveWeighIn(val) }
                        showWeighIn = false
                    }
                    SecondaryButton("Cancel") { showWeighIn = false }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { showWeighIn = false }.foregroundColor(LockInTheme.textMuted)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Cal Log Sheet
    private var calLogSheet: some View {
        NavigationStack {
            ZStack {
                LockInTheme.background.ignoresSafeArea()
                VStack(spacing: 16) {
                    Text("Log Nutrition").font(.system(size: 22, weight: .bold)).foregroundColor(.white)
                    logField("Calories", text: $calText)
                    logField("Protein (g)", text: $protText)
                    logField("Carbs (g)", text: $carbsText)
                    logField("Fat (g)", text: $fatText)
                    PrimaryButton("Save") {
                        saveCalories(
                            Int(calText)   ?? 0,
                            Int(protText)  ?? 0,
                            Int(carbsText) ?? 0,
                            Int(fatText)   ?? 0
                        )
                        showCalLog = false
                    }
                    SecondaryButton("Cancel") { showCalLog = false }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { showCalLog = false }.foregroundColor(LockInTheme.textMuted)
                }
            }
        }
        .presentationDetents([.medium])
        .onAppear {
            calText   = currentLog.map { String($0.actualCalories) } ?? ""
            protText  = currentLog.map { String($0.actualProtein) }  ?? ""
            carbsText = currentLog.map { String($0.actualCarbs) }    ?? ""
            fatText   = currentLog.map { String($0.actualFat) }      ?? ""
        }
    }

    // MARK: - Helpers
    private func loadOrCreateLog() {
        let start = viewingDate
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        var descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )
        descriptor.fetchLimit = 1

        if let existing = try? modelContext.fetch(descriptor).first {
            currentLog = existing
            existing.ensureChecklistItems()
        } else if isViewingToday {
            let log = DailyLog(date: viewingDate)
            modelContext.insert(log)
            log.ensureChecklistItems()
            try? modelContext.save()
            currentLog = log
        } else {
            currentLog = nil
        }
    }

    func saveWeighIn(_ value: Double) {
        guard let log = currentLog else { return }
        log.isWeighedIn = true
        log.weighInValue = value
        log.checklistItem(for: .morningWeighIn)?.isCompleted = true
        log.checklistItem(for: .morningWeighIn)?.completedAt = Date()

        // Update profile weight (only if viewing today)
        if isViewingToday {
            profile?.updateWeight(value)
        }

        // Store weight entry
        let entry = WeightEntry(date: viewingDate, weightLb: value,
                                bodyFatPercent: profile?.estimatedBodyFatPercent,
                                source: "manual")
        modelContext.insert(entry)
        try? modelContext.save()

        if isViewingToday {
            Task { NotificationManager.shared.cancelWeighInFollowUps() }
        }
    }

    func saveCalories(_ cal: Int, _ prot: Int, _ carbs: Int, _ fat: Int) {
        guard let log = currentLog else { return }
        log.actualCalories = cal
        log.actualProtein  = prot
        log.actualCarbs    = carbs
        log.actualFat      = fat
        log.isFoodLogged   = true

        let protTarget = goal?.dailyProteinTarget ?? 145
        let calTarget  = goal?.dailyCalorieTarget ?? 1900
        if prot >= protTarget { log.checklistItem(for: .hitProteinTarget)?.isCompleted = true }
        if cal <= calTarget   { log.checklistItem(for: .underCalorieTarget)?.isCompleted = true }
        log.checklistItem(for: .loggedInMND)?.isCompleted = true

        try? modelContext.save()

        if isViewingToday {
            Task { NotificationManager.shared.cancelFoodLoggingReminders() }
        }
    }

    // MARK: - Sub-views
    @ViewBuilder
    private func nutritionRow(label: String, value: Int, target: Int, unit: String = "kcal", color: Color) -> some View {
        HStack {
            Text(label).font(.system(size: 14)).foregroundColor(LockInTheme.textSecondary)
            Spacer()
            Text("\(value) / \(target) \(unit)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
        }
    }

    @ViewBuilder
    private func nutritionMini(_ label: String, value: Int, unit: String) -> some View {
        HStack {
            Text(label).font(.system(size: 12)).foregroundColor(LockInTheme.textMuted)
            Spacer()
            Text("\(value)\(unit)").font(.system(size: 12, weight: .semibold)).foregroundColor(LockInTheme.textSecondary)
        }
        .padding(10).background(LockInTheme.surface).cornerRadius(8)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func quickBtn(_ label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 20)).foregroundColor(color)
                Text(label).font(.system(size: 11, weight: .medium)).foregroundColor(LockInTheme.textSecondary)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 14).cardStyle()
        }
    }

    @ViewBuilder
    private func logField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 12)).foregroundColor(LockInTheme.textSecondary)
            TextField("0", text: text).keyboardType(.numberPad)
                .padding(10).background(LockInTheme.surface)
                .cornerRadius(8).foregroundColor(.white)
        }
    }

    private func calorieColor(_ cal: Int, target: Int, tdee: Int) -> Color {
        if cal <= target { return LockInTheme.success }
        if cal <= tdee   { return LockInTheme.warning }
        return LockInTheme.danger
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 80 { return LockInTheme.success }
        if score >= 50 { return LockInTheme.warning }
        return LockInTheme.danger
    }

    private func dateFormatted(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "EEEE, MMM d"
        return f.string(from: date)
    }
}
