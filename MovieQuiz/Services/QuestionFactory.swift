import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    // MARK: - Private properties
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    private var viewController: MovieQuizViewControllerProtocol?
    
    // MARK: - Public methods
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?, viewController: MovieQuizViewControllerProtocol) {
            self.delegate = delegate
            self.moviesLoader = moviesLoader
            self.viewController = viewController
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.viewController?.showLoadingIndicator()
            }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else {
                DispatchQueue.main.async {
                    self.viewController?.hideLoadingIndicator()
                }
                return
            }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                assertionFailure("Failed to load image")
                
                DispatchQueue.main.async {
                    self.viewController?.hideLoadingIndicator()
                }
                return
            }
            
            let rating = Double(movie.rating ?? "0") ?? 0
            
            let isGreaterThan = Bool.random()
            let randomSign = Bool.random() ? -1.00 : 1.00
            let randomValue = Double.random(in: 0.05...0.95)
            let ratingChange = rating + (randomSign * randomValue)
            
            let text: String
            let correctAnswer: Bool
            
            if isGreaterThan {
                text = "Рейтинг этого фильма выше \(String(format: "%.2f", ratingChange))?"
                correctAnswer = rating > ratingChange
            } else {
                text = "Рейтинг этого фильма ниже \(String(format: "%.2f", ratingChange))?"
                correctAnswer = rating < ratingChange
            }
            
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                viewController?.hideLoadingIndicator()
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
