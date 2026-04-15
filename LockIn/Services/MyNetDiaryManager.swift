import Foundation
import UIKit

final class MyNetDiaryManager {
    static let shared = MyNetDiaryManager()
    private init() {}

    private let mndScheme = "mynetdiary://"
    private let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id287529757")!

    enum Action: String {
        case open = "", logFood = "food", logWeight = "weight", diary = "diary"
    }

    @discardableResult
    func open(action: Action = .open) async -> Bool {
        guard let url = URL(string: mndScheme + action.rawValue) else { return false }
        return await withCheckedContinuation { cont in
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:]) { ok in
                    if ok { cont.resume(returning: true) }
                    else {
                        UIApplication.shared.open(self.appStoreURL, options: [:]) { _ in
                            cont.resume(returning: false)
                        }
                    }
                }
            }
        }
    }

    func openMND() async { await open(action: .open) }
    func openLogFood() async { await open(action: .logFood) }
    func openLogWeight() async { await open(action: .logWeight) }

    var manualInstructions: String {
        "1. Open MyNetDiary\n2. Go to your Diary\n3. Log each meal\n4. Check totals match your plan\n5. Return to LockIn and confirm"
    }
}
