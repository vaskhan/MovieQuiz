import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Public Properties
    var correctAnswers = 0
    let statisticService = StatisticService()
    var questionFactory: QuestionFactoryProtocol?
    var alertPresenter: AlertPresenter?
    
    // MARK: - Private Properties
    private let presenter = MovieQuizPresenter()
    
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
        presenter.viewController = self
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Public Methods
    func didReceiveNextQuestion(question: QuizQuestion?) {
            presenter.didReceiveNextQuestion(question: question)
    }
    
    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
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
    
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.masksToBounds = true
        
        if isCorrect == true {
            imageView.layer.borderColor = UIColor(named: "YP Green")?.cgColor
        } else {
            imageView.layer.borderColor = UIColor(named: "YP Red")?.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            presenter.correctAnswers = correctAnswers
            presenter.showNextQuestionOrResults()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                guard let self = self else { return }
                
                imageView.layer.borderWidth = 0
                imageView.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    func blockButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    func unlockButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    // MARK: - Private Methods
    
    
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

