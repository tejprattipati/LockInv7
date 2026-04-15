import SwiftUI
import SwiftData

struct AntiBingeFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var goals: [GoalProfile]
    @Query private var profiles: [UserProfile]

    @State private var step = 0
    @State private var ateNightMeal = false
    @State private var hitProtein = false
    @State private var loggedMND = false
    @State private var timerSeconds = 900
    @State private var timerActive = false
    @State private var decision: Bool? = nil
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var goal: GoalProfile? { goals.first }
    var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ZStack {
                LockInTheme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Progress bar
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(LockInTheme.accent)
                                .frame(width: geo.size.width * CGFloat(step + 1) / 8)
                                .animation(.easeInOut, value: step)
                            Spacer()
                        }
                        .frame(height: 3)
                        .background(LockInTheme.border)
                    }
                    .frame(height: 3)

                    ScrollView {
                        VStack(spacing: 20) {
                            stepContent.padding(.top, 20)
                            Spacer(minLength: 80)
                        }.padding()
                    }
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("STOP THE SPIRAL")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(LockInTheme.danger)
                        .shadow(color: LockInTheme.danger.opacity(0.5), radius: 6)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Exit") { dismiss() }.foregroundColor(LockInTheme.textMuted)
                }
            }
        }
        .onReceive(timer) { _ in
            if timerActive && timerSeconds > 0 { timerSeconds -= 1 }
            else if timerActive && timerSeconds == 0 { timerActive = false; step = 7 }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 0: step0
        case 1: step1
        case 2: step2
        case 3: step3
        case 4: step4
        case 5: step5
        case 6: step6_timer
        case 7: step7_decision
        default: step8_logged
        }
    }

    private var step0: some View {
        VStack(spacing: 20) {
            Text("\u26a0\ufe0f Before you order anything")
                .font(.system(size: 22, weight: .bold)).foregroundColor(LockInTheme.danger)
            Text("Answer these questions honestly. They take 30 seconds.")
                .font(.system(size: 15)).foregroundColor(LockInTheme.textSecondary).multilineTextAlignment(.center)
            PrimaryButton("I'm ready", color: LockInTheme.danger) { step = 1 }
        }
    }

    private var step1: some View {
        VStack(spacing: 20) {
            Text("Did you eat your planned night meal?")
                .font(.system(size: 20, weight: .bold)).foregroundColor(.white).multilineTextAlignment(.center)
            HStack(spacing: 16) {
                PrimaryButton("Yes", color: LockInTheme.success) { ateNightMeal = true; step = 2 }
                PrimaryButton("No",  color: LockInTheme.danger)  { ateNightMeal = false; step = 5 }
            }
        }
    }

    private var step2: some View {
        VStack(spacing: 20) {
            Text("Did you hit your protein target today?")
                .font(.system(size: 20, weight: .bold)).foregroundColor(.white).multilineTextAlignment(.center)
            if let goal {
                Text("Target: \(goal.dailyProteinTarget)g")
                    .font(.system(size: 14)).foregroundColor(LockInTheme.textSecondary)
            }
            HStack(spacing: 16) {
                PrimaryButton("Yes", color: LockInTheme.success) { hitProtein = true; step = 3 }
                PrimaryButton("No",  color: LockInTheme.warning)  { hitProtein = false; step = 3 }
            }
        }
    }

    private var step3: some View {
        VStack(spacing: 20) {
            Text("Did you log everything in MyNetDiary?")
                .font(.system(size: 20, weight: .bold)).foregroundColor(.white).multilineTextAlignment(.center)
            HStack(spacing: 16) {
                PrimaryButton("Yes", color: LockInTheme.success) { loggedMND = true; step = 4 }
                PrimaryButton("Not yet", color: LockInTheme.warning) { loggedMND = false; step = 4 }
            }
            Button("Open MyNetDiary now") { Task { await MyNetDiaryManager.shared.openMND() } }
                .foregroundColor(LockInTheme.accent)
        }
    }

    private var step4: some View {
        VStack(spacing: 20) {
            if let goal {
                VStack(spacing: 8) {
                    Text("\(goal.daysRemaining) days left")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(LockInTheme.accent).glowAccent(radius: 10)
                    Text("to August 8, 2026")
                        .font(.system(size: 15)).foregroundColor(LockInTheme.textSecondary)
                }
                .padding().cardStyle()
            }
            // Damage comparison
            VStack(spacing: 0) {
                HStack {
                    Text("Ordering Food").foregroundColor(LockInTheme.danger).fontWeight(.bold)
                    Spacer()
                    Text("\u2248 1,400 kcal").foregroundColor(LockInTheme.danger).fontWeight(.bold)
                }
                .padding(14)
                Divider().background(LockInTheme.border)
                HStack {
                    Text("Your Planned Meal").foregroundColor(LockInTheme.success).fontWeight(.bold)
                    Spacer()
                    Text("\u2248 500 kcal").foregroundColor(LockInTheme.success).fontWeight(.bold)
                }
                .padding(14)
                Divider().background(LockInTheme.border)
                HStack {
                    Text("Difference")
                    Spacer()
                    Text("+900 kcal = +\u00bc lb of fat")
                        .foregroundColor(LockInTheme.danger)
                }
                .font(.system(size: 13))
                .foregroundColor(LockInTheme.textSecondary)
                .padding(14)
            }
            .cardStyle()
            PrimaryButton("Understood \u2014 show me what to eat") { step = 5 }
        }
    }

    private var step5: some View {
        VStack(spacing: 20) {
            Text("Eat this instead")
                .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
            VStack(alignment: .leading, spacing: 12) {
                replacementRow("1. Emergency Snack", "Greek yogurt or protein shake (~200 kcal)")
                replacementRow("2. Night Meal if still hungry", "Protein + veggies, no ordering")
                replacementRow("3. Water", "Drink a full glass before deciding")
                replacementRow("4. Wait 15 min", "Set the timer and don\u2019t open DoorDash")
            }
            .padding(16).cardStyle()
            PrimaryButton("Start 15-minute timer", color: LockInTheme.warning) {
                timerActive = true; timerSeconds = 900; step = 6
            }
        }
    }

    private var step6_timer: some View {
        VStack(spacing: 24) {
            Text("15-minute hold")
                .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
            Text(timeString(timerSeconds))
                .font(.system(size: 72, weight: .heavy, design: .monospaced))
                .foregroundColor(timerSeconds > 300 ? LockInTheme.accent : LockInTheme.danger)
                .glowAccent(radius: 12)
            Text("Eat your snack. Drink water. Do not open a food app.")
                .font(.system(size: 14)).foregroundColor(LockInTheme.textSecondary).multilineTextAlignment(.center)
            if timerSeconds == 0 || !timerActive {
                PrimaryButton("Time\u2019s up \u2014 make your decision") { step = 7 }
            } else {
                SecondaryButton("Skip timer") { timerActive = false; step = 7 }
            }
        }
        .padding().cardStyle()
    }

    private var step7_decision: some View {
        VStack(spacing: 24) {
            Text("What did you do?")
                .font(.system(size: 22, weight: .bold)).foregroundColor(.white)
            PrimaryButton("I resisted. I ate my plan.", color: LockInTheme.success) {
                decision = true; step = 8
            }
            PrimaryButton("I ordered food.", color: LockInTheme.danger) {
                decision = false; step = 8
            }
        }
    }

    private var step8_logged: some View {
        VStack(spacing: 20) {
            if decision == true {
                Image(systemName: "checkmark.seal.fill").font(.system(size: 56)).foregroundColor(LockInTheme.success)
                Text("Locked in.").font(.system(size: 28, weight: .heavy)).foregroundColor(LockInTheme.success)
                Text("Log it in MyNetDiary and mark tonight complete.")
                    .font(.system(size: 14)).foregroundColor(LockInTheme.textSecondary).multilineTextAlignment(.center)
            } else {
                Image(systemName: "xmark.circle.fill").font(.system(size: 56)).foregroundColor(LockInTheme.danger)
                Text("It happened.").font(.system(size: 28, weight: .heavy)).foregroundColor(LockInTheme.danger)
                Text("Log it accurately. Don\u2019t pretend it didn\u2019t happen. Tomorrow starts clean.")
                    .font(.system(size: 14)).foregroundColor(LockInTheme.textSecondary).multilineTextAlignment(.center)
            }
            PrimaryButton("Done") { dismiss() }
        }
    }

    @ViewBuilder
    private func replacementRow(_ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
            Text(detail).font(.system(size: 13)).foregroundColor(LockInTheme.textSecondary)
        }
    }

    private func timeString(_ s: Int) -> String {
        String(format: "%02d:%02d", s / 60, s % 60)
    }
}
