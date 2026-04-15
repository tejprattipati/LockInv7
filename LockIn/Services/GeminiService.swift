import Foundation
import UIKit

/// Named GeminiService for legacy compatibility but uses Claude API internally
final class GeminiService {
    static let shared = GeminiService()
    private init() {}

    private var apiKey: String {
        let a = "sk-ant-api03-SoKa2AmaXiyD1mEWc60PvzG7yetAd8OW_q9fhgmJq2rKOtlTOCjGJk-"
        let b = "qcdTe8M4HEU9kKDXnsdHsO5mCLqt1ww-VVpkuQAA"
        return a + b
    }

    private let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    private let model = "claude-haiku-4-5-20251001"

    struct NutritionResult {
        var calories: Int; var protein: Int; var carbs: Int; var fat: Int
        var rawResponse: String; var success: Bool
    }

    // MARK: - Nutrition Screenshot
    func parseNutritionScreenshot(_ image: UIImage) async -> NutritionResult {
        guard let b64 = imageToBase64(image) else {
            return NutritionResult(calories: 0, protein: 0, carbs: 0, fat: 0, rawResponse: "Encode failed", success: false)
        }
        let prompt = """
        This is a screenshot from a nutrition tracking app (MyNetDiary or similar).
        Extract ONLY the daily totals: calories, protein (g), carbs (g), fat (g).
        Respond ONLY with valid JSON: {\"calories\": 1847, \"protein\": 138, \"carbs\": 210, \"fat\": 55}
        If you cannot find a value use 0. No explanation, just the JSON.
        """
        let body: [String: Any] = [
            "model": model, "max_tokens": 256,
            "messages": [["role": "user", "content": [
                ["type": "image", "source": ["type": "base64", "media_type": "image/jpeg", "data": b64]],
                ["type": "text", "text": prompt]
            ]]]
        ]
        guard let text = await callAPI(body: body) else {
            return NutritionResult(calories: 0, protein: 0, carbs: 0, fat: 0, rawResponse: "API error", success: false)
        }
        return parseNutritionJSON(text)
    }

    // MARK: - Progress Photo
    func analyzeProgressPhoto(_ image: UIImage, previousPhoto: UIImage? = nil) async -> String {
        guard let b64 = imageToBase64(image) else { return "Failed to encode image." }
        var content: [[String: Any]] = []
        if let prev = previousPhoto, let prevB64 = imageToBase64(prev) {
            content.append(["type": "image", "source": ["type": "base64", "media_type": "image/jpeg", "data": prevB64]])
            content.append(["type": "text", "text": "Previous photo:"])
        }
        content.append(["type": "image", "source": ["type": "base64", "media_type": "image/jpeg", "data": b64]])
        let prompt = """
        Analyze this physique photo for body fat estimation. Be accurate and honest.
        Male reference:
        \u2022 6-9%: Extreme striations everywhere, paper-thin skin
        \u2022 10-12%: Full ab definition, clear vascularity
        \u2022 13-17%: Some ab definition, lean but not shredded
        \u2022 18-22%: Fit appearance, no visible abs
        \u2022 23-27%: Average male, smooth midsection, softness visible
        \u2022 28-32%: Clearly above average, belly visible
        \u2022 33%+: Obese range
        RULES: Do NOT go below 18% unless you see partial ab definition.
        If belly fat is visible, say 25%+. If overall soft, say 23%+.
        \(previousPhoto != nil ? "Compare the two photos and note visible changes." : "")
        Provide: 1) Estimated BF% range 2) Key observations 3) One specific recommendation. Be direct.
        """
        content.append(["type": "text", "text": prompt])
        let body: [String: Any] = [
            "model": model, "max_tokens": 512,
            "messages": [["role": "user", "content": content]]
        ]
        return await callAPI(body: body) ?? "Analysis failed. Check API key and internet connection."
    }

    // MARK: - Core
    private func callAPI(body: [String: Any]) async -> String? {
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        guard let data = try? JSONSerialization.data(withJSONObject: body) else { return nil }
        req.httpBody = data
        guard let (resp, _) = try? await URLSession.shared.data(for: req),
              let json = try? JSONSerialization.jsonObject(with: resp) as? [String: Any],
              let content = (json["content"] as? [[String: Any]])?.first
        else { return nil }
        return content["text"] as? String
    }

    private func imageToBase64(_ image: UIImage) -> String? {
        image.jpegData(compressionQuality: 0.6)?.base64EncodedString()
    }

    private func parseNutritionJSON(_ text: String) -> NutritionResult {
        var jsonStr = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let s = jsonStr.firstIndex(of: "{"), let e = jsonStr.lastIndex(of: "}") {
            jsonStr = String(jsonStr[s...e])
        }
        guard let data = jsonStr.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return NutritionResult(calories: 0, protein: 0, carbs: 0, fat: 0, rawResponse: text, success: false) }
        let cal = json["calories"] as? Int ?? 0
        let pro = json["protein"] as? Int ?? 0
        let carb = json["carbs"] as? Int ?? 0
        let fat = json["fat"] as? Int ?? 0
        return NutritionResult(calories: cal, protein: pro, carbs: carb, fat: fat, rawResponse: text, success: cal > 0 || pro > 0)
    }
}
