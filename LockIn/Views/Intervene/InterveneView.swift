import SwiftUI
import SwiftData

struct InterveneView: View {
    @Query private var goals: [GoalProfile]
    @Query private var profiles: [UserProfile]
    @State private var showAntiBinge = false
    @State private var showMessedUp = false
    @State private var showMND = false

    var goal: GoalProfile? { goals.first }

    var body: some View {
        NavigationStack {
            ZStack {
                LockInTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        // Risk header
                        riskHeader
                        // Action grid
                        VStack(spacing: 12) {
                            SectionHeader(title: "Intervention").padding(.horizontal)
                            InterveneBigButton(
                                title: "I'm About to Order Food",
                                subtitle: "Stop the spiral. Do this first.",
                                icon: "bolt.shield.fill",
                                color: LockInTheme.danger
                            ) { showAntiBinge = true }

                            InterveneBigButton(
                                title: "I'm Hungry Right Now",
                                subtitle: "Find what to eat instead.",
                                icon: "fork.knife",
                                color: LockInTheme.warning
                            ) { showAntiBinge = true }

                            InterveneBigButton(
                                title: "I Already Messed Up",
                                subtitle: "Salvage the rest of today.",
                                icon: "arrow.counterclockwise",
                                color: LockInTheme.accentAlt
                            ) { showMessedUp = true }
                        }
                        .padding(.horizontal)

                        // MND shortcuts
                        VStack(spacing: 12) {
                            SectionHeader(title: "MyNetDiary").padding(.horizontal)
                            HStack(spacing: 12) {
                                mndButton("Open MND",   icon: "arrow.up.right.square") { Task { await MyNetDiaryManager.shared.openMND() } }
                                mndButton("Log Food",   icon: "fork.knife")             { Task { await MyNetDiaryManager.shared.openLogFood() } }
                                mndButton("Log Weight", icon: "scalemass")              { Task { await MyNetDiaryManager.shared.openLogWeight() } }
                            }
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 80)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("INTERVENE")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(LockInTheme.accent)
                        .shadow(color: LockInTheme.accent.opacity(0.55), radius: 8)
                }
            }
        }
        .sheet(isPresented: $showAntiBinge) { AntiBingeFlowView() }
        .sheet(isPresented: $showMessedUp)  { MessedUpFlowView() }
    }

    private var riskHeader: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(LockInTheme.warning)
                Text("High Risk Window")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(LockInTheme.warning)
                Spacer()
                if let goal {
                    Text("Day \(goal.daysElapsed)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(LockInTheme.textSecondary)
                }
            }
            Text("Late nights are your biggest failure point. Use this tab before you make a bad decision.")
                .font(.system(size: 13))
                .foregroundColor(LockInTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16).cardStyle().padding(.horizontal)
    }

    @ViewBuilder
    private func mndButton(_ label: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 20)).foregroundColor(LockInTheme.accent)
                Text(label).font(.system(size: 11, weight: .medium)).foregroundColor(LockInTheme.textSecondary)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 14).cardStyle()
        }
    }
}

struct InterveneBigButton: View {
    let title: String; let subtitle: String; let icon: String; let color: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon).font(.system(size: 24)).foregroundColor(color).frame(width: 44)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.system(size: 16, weight: .bold)).foregroundColor(LockInTheme.textPrimary)
                    Text(subtitle).font(.system(size: 13)).foregroundColor(LockInTheme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(LockInTheme.textMuted)
            }
            .padding(16).cardStyle()
        }
    }
}
