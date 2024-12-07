import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private let presenter = MovieQuizPresenter()
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private let statisticService = StatisticService()
    
    // MARK: - View Life Cycles
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        activityIndicator.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
        questionFactory?.loadData()
        alertPresenter = AlertPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        blockButtons()
        if currentQuestion?.correctAnswer == false {
            showAnswerResult(isCorrect: true)
            correctAnswers += 1
        } else {
            showAnswerResult(isCorrect: false)
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        blockButtons()
        if currentQuestion?.correctAnswer == true {
            showAnswerResult(isCorrect: true)
            correctAnswers += 1
        } else {
            showAnswerResult(isCorrect: false)
        }
    }
    
    // MARK: - Public Methods
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let errorMessage = (error as NSError).localizedDescription
        showNetworkError(message: errorMessage)
    }
    
    // MARK: - Private Methods    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.masksToBounds = true
        
        if isCorrect == true {
            imageView.layer.borderColor = UIColor(named: "YP Green")?.cgColor
        } else {
            imageView.layer.borderColor = UIColor(named: "YP Red")?.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            imageView.layer.borderWidth = 0
            imageView.layer.borderColor = UIColor.clear.cgColor
            
            if presenter.isLastQuestion() {
                statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
                let alertModel = AlertModel(
                    title: "Этот раунд окончен!",
                    message: correctAnswers == presenter.questionsAmount ? "Поздравляем, Вы ответили на 10 из 10!" :  "Ваш результат \(correctAnswers)/\(presenter.questionsAmount)\nКоличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%",
                    buttonText: "Сыграть ещё раз",
                    completion: {[weak self] in
                        self?.presenter.resetQuestionIndex()
                        self?.correctAnswers = 0
                        self?.questionFactory?.requestNextQuestion()
                        self?.unlockButtons()
                    })
                
                alertPresenter?.showAlert(model: alertModel)
            } else {
                presenter.switchToNextQuestion()
                
                questionFactory?.requestNextQuestion()
                unlockButtons()
            }
        }
    }
    
    private func blockButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    private func unlockButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alert = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз", completion: {[weak self] in
            self?.presenter.resetQuestionIndex()
            self?.correctAnswers = 0
            self?.questionFactory?.requestNextQuestion()
            self?.unlockButtons()
        })
        
        alertPresenter?.showAlert(model: alert)
    }
}

