import SwiftUI

struct MessedUpFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step = 0
    @State private var whatHappened = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LockInTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        stepContent.padding(.top, 20)
                        Spacer(minLength: 80)
                    }.padding()
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("DAMAGE CONTROL")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(LockInTheme.accentAlt)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Exit") { dismiss() }.foregroundColor(LockInTheme.textMuted)
                }
            }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 0: step0
        case 1: step1
        default: step2
        }
    }

    private var step0: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.counterclockwise.circle.fill")
                .font(.system(size: 56)).foregroundColor(LockInTheme.accentAlt)
            Text("One mistake doesn't break the cut.")
                .font(.system(size: 22, weight: .bold)).foregroundColor(.white).multilineTextAlignment(.center)
            Text("What you do in the next hour matters more than what just happened.")
                .font(.system(size: 15)).foregroundColor(LockInTheme.textSecondary).multilineTextAlignment(.center)
            PrimaryButton("Continue", color: LockInTheme.accentAlt) { step = 1 }
        }
    }

    private var step1: some View {
        VStack(spacing: 16) {
            Text("Do these right now")
                .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
            VStack(spacing: 0) {
                salvageRow("1", "Log what you ate \u2014 accurately", "Open MyNetDiary. Log it honestly.")
                Divider().background(LockInTheme.border)
                salvageRow("2", "Do not skip the next meal", "Restricting after a binge makes it worse, not better.")
                Divider().background(LockInTheme.border)
                salvageRow("3", "Stay under TDEE for the rest of the day", "You can still salvage your deficit if the day isn\u2019t over.")
                Divider().background(LockInTheme.border)
                salvageRow("4", "Drink water", "Reduces bloating and resets your appetite signal.")
                Divider().background(LockInTheme.border)
                salvageRow("5", "Tomorrow is a clean slate", "The streak resets. The goal doesn\u2019t.")
            }
            .cardStyle()
            Button("Open MyNetDiary") { Task { await MyNetDiaryManager.shared.openMND() } }
                .foregroundColor(LockInTheme.accent)
            PrimaryButton("Got it", color: LockInTheme.accentAlt) { step = 2 }
        }
    }

    private var step2: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56)).foregroundColor(LockInTheme.success)
            Text("You\u2019re still in this.")
                .font(.system(size: 24, weight: .heavy)).foregroundColor(.white)
            Text("One bad meal doesn\u2019t erase weeks of progress. Log it, reset, and lock back in.")
                .font(.system(size: 14)).foregroundColor(LockInTheme.textSecondary).multilineTextAlignment(.center)
            PrimaryButton("Done") { dismiss() }
        }
    }

    @ViewBuilder
    private func salvageRow(_ num: String, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(num)
                .font(.system(size: 14, weight: .heavy))
                .foregroundColor(LockInTheme.accent)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                Text(detail).font(.system(size: 12)).foregroundColor(LockInTheme.textSecondary)
            }
        }
        .padding(14)
    }
}
