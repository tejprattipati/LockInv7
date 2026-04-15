import Foundation

// MARK: - Compliance Categories
enum ComplianceCategory: String, Codable, CaseIterable, Identifiable {
    case morningWeighIn
    case loggedMeal1
    case loggedMeal2
    case loggedNightMeal
    case emergencySnackUsed
    case hitProteinTarget
    case underCalorieTarget
    case noDessert
    case noRestaurantFood
    case workoutCompleted
    case cardioCompleted
    case stepsGoalMet
    case loggedInMND
    case noUnplannedEating

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .morningWeighIn:    return "Morning Weigh-In"
        case .loggedMeal1:       return "Logged Meal 1"
        case .loggedMeal2:       return "Logged Meal 2"
        case .loggedNightMeal:   return "Logged Night Meal"
        case .emergencySnackUsed:return "Emergency Snack Used"
        case .hitProteinTarget:  return "Hit Protein Target"
        case .underCalorieTarget:return "Under Calorie Target"
        case .noDessert:         return "No Dessert"
        case .noRestaurantFood:  return "No Restaurant Food"
        case .workoutCompleted:  return "Workout Completed"
        case .cardioCompleted:   return "Cardio / Basketball"
        case .stepsGoalMet:      return "Steps Goal Met"
        case .loggedInMND:       return "Logged in MyNetDiary"
        case .noUnplannedEating: return "No Unplanned Eating"
        }
    }

    var points: Int {
        switch self {
        case .noRestaurantFood:  return 20
        case .noDessert:         return 15
        case .noUnplannedEating: return 15
        case .loggedNightMeal:   return 10
        case .underCalorieTarget:return 10
        case .hitProteinTarget:  return 10
        case .morningWeighIn:    return 8
        case .loggedInMND:       return 7
        case .loggedMeal1:       return 5
        case .loggedMeal2:       return 5
        case .workoutCompleted:  return 5
        case .cardioCompleted:   return 5
        case .stepsGoalMet:      return 3
        case .emergencySnackUsed:return 0
        }
    }

    var sfSymbol: String {
        switch self {
        case .morningWeighIn:    return "scalemass"
        case .loggedMeal1:       return "fork.knife"
        case .loggedMeal2:       return "fork.knife.circle"
        case .loggedNightMeal:   return "moon.fill"
        case .emergencySnackUsed:return "exclamationmark.circle"
        case .hitProteinTarget:  return "figure.strengthtraining.traditional"
        case .underCalorieTarget:return "flame"
        case .noDessert:         return "xmark.circle"
        case .noRestaurantFood:  return "takeoutbag.and.cup.and.straw"
        case .workoutCompleted:  return "dumbbell.fill"
        case .cardioCompleted:   return "figure.run"
        case .stepsGoalMet:      return "shoeprints.fill"
        case .loggedInMND:       return "checkmark.icloud"
        case .noUnplannedEating: return "lock.fill"
        }
    }

    var group: String {
        switch self {
        case .morningWeighIn: return "Morning"
        case .loggedMeal1, .loggedMeal2, .loggedNightMeal, .emergencySnackUsed, .loggedInMND: return "Nutrition"
        case .hitProteinTarget, .underCalorieTarget, .noDessert, .noRestaurantFood, .noUnplannedEating: return "Compliance"
        case .workoutCompleted, .cardioCompleted, .stepsGoalMet: return "Activity"
        }
    }
}

// MARK: - Meal Slot
enum MealSlot: String, Codable, CaseIterable, Identifiable {
    case meal1
    case meal2
    case nightMeal
    case emergencySnack

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .meal1:          return "Meal 1"
        case .meal2:          return "Meal 2"
        case .nightMeal:      return "Night Meal"
        case .emergencySnack: return "Emergency Snack"
        }
    }

    var sortOrder: Int {
        switch self {
        case .meal1: return 0; case .meal2: return 1
        case .nightMeal: return 2; case .emergencySnack: return 3
        }
    }

    var sfSymbol: String {
        switch self {
        case .meal1: return "sun.rise"; case .meal2: return "sun.max"
        case .nightMeal: return "moon.stars"; case .emergencySnack: return "bolt.fill"
        }
    }
}

// MARK: - Activity Level
enum ActivityLevel: String, Codable, CaseIterable, Identifiable {
    case sedentary, lightlyActive, moderatelyActive, veryActive

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sedentary:        return "Sedentary"
        case .lightlyActive:    return "Lightly Active"
        case .moderatelyActive: return "Moderately Active"
        case .veryActive:       return "Very Active"
        }
    }

    var multiplier: Double {
        switch self {
        case .sedentary:        return 1.35
        case .lightlyActive:    return 1.55
        case .moderatelyActive: return 1.65
        case .veryActive:       return 1.80
        }
    }

    var description: String {
        switch self {
        case .sedentary:        return "Desk job, little exercise"
        case .lightlyActive:    return "Light exercise 1\u20133 days/week"
        case .moderatelyActive: return "Moderate exercise 3\u20135 days/week"
        case .veryActive:       return "Hard exercise 6\u20137 days/week"
        }
    }
}

// MARK: - Reminder Type
enum ReminderType: String, Codable, CaseIterable, Identifiable {
    case morningWeighIn, noonWeighIn, sixPmWeighIn
    case meal1, mainMeal, preNightMeal
    case nightlyWarning, ninePmFoodLog, tenPmFoodLog
    case bedtimeWrap, workoutReminder

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .morningWeighIn:  return "Morning Weigh-In (10am)"
        case .noonWeighIn:     return "Weigh-In Reminder (Noon)"
        case .sixPmWeighIn:    return "Weigh-In Reminder (6pm)"
        case .meal1:           return "Meal 1 Reminder (9am)"
        case .mainMeal:        return "Main Meal Reminder (1pm)"
        case .preNightMeal:    return "Plan Night Meal (7pm)"
        case .nightlyWarning:  return "Nightly Anti-Order Warning (9pm)"
        case .ninePmFoodLog:   return "Log Food (9pm)"
        case .tenPmFoodLog:    return "Log Food (10pm)"
        case .bedtimeWrap:     return "Bedtime Wrap-Up (11pm)"
        case .workoutReminder: return "Workout Reminder (5pm)"
        }
    }

    var defaultHour: Int {
        switch self {
        case .morningWeighIn:  return 10
        case .noonWeighIn:     return 12
        case .sixPmWeighIn:    return 18
        case .meal1:           return 9
        case .mainMeal:        return 13
        case .preNightMeal:    return 19
        case .nightlyWarning:  return 21
        case .ninePmFoodLog:   return 21
        case .tenPmFoodLog:    return 22
        case .bedtimeWrap:     return 23
        case .workoutReminder: return 17
        }
    }
}
