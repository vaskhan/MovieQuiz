import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case gamesCount
        case correctAnswers
        case totalQuestion
        case date
        case bestCorrect
        case totalBest
        case dateBest
    }
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestCorrect.rawValue)
            let total = storage.integer(forKey: Keys.totalBest.rawValue)
            let date = storage.object(forKey: Keys.dateBest.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.totalBest.rawValue)
            storage.set(newValue.date, forKey: Keys.dateBest.rawValue)
        }
    }
    var totalAccuracy: Double {
        get {
            let correctAnswers = storage.integer(forKey: Keys.correctAnswers.rawValue)
            let totalQuestions = storage.integer(forKey: Keys.totalQuestion.rawValue)
            
            guard totalQuestions > 0 else { return 0.0 }
            return (Double(correctAnswers) / Double(totalQuestions)) * 100
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let newCorrect = storage.integer(forKey: Keys.correctAnswers.rawValue) + count
        let newTotal = storage.integer(forKey: Keys.totalQuestion.rawValue) + amount
        
        storage.set(newCorrect, forKey: Keys.correctAnswers.rawValue)
        storage.set(newTotal, forKey: Keys.totalQuestion.rawValue)
        
        gamesCount += 1
        if count > bestGame.correct {
            bestGame = GameResult(correct: count, total: amount, date: Date())
        }
    }
}
