//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Василий Ханин on 08.12.2024.
//

import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Public properties
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(networkClient: NetworkClient()), delegate: self, viewController: viewController)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - Private properties
    private var currentQuestionIndex = 0
    private let questionsAmount = 10
    private var currentQuestion: QuizQuestion?
    private let statisticService = StatisticService()
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let errorMessage = (error as NSError).localizedDescription
        viewController?.showNetworkError(message: errorMessage)
    }
    
    // MARK: - Public Methods
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) / \(questionsAmount)"
        )
    }
    
    // MARK: - Private Methods
    private func didAnswer(isYes: Bool) {
        viewController?.blockButtons()
        
        if currentQuestion?.correctAnswer == isYes {
            proceedWithAnswer(isCorrect: true)
            correctAnswers += 1
        } else {
            proceedWithAnswer(isCorrect: false)
        }
    }
    
    func proceedToNextQuestionOrResults() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.isLastQuestion() {
                statisticService.store(correct: correctAnswers, total: self.questionsAmount)
                let alertModel = AlertModel(
                    title: "Этот раунд окончен!",
                    message: correctAnswers == self.questionsAmount ? "Поздравляем, Вы ответили на 10 из 10!" :  "Ваш результат \(correctAnswers)/\(self.questionsAmount)\nКоличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%",
                    buttonText: "Сыграть ещё раз",
                    completion: {[weak self] in
                        self?.restartGame()
                        self?.correctAnswers = 0
                        self?.questionFactory?.requestNextQuestion()
                        self?.viewController?.unlockButtons()
                    })
                
                viewController?.alertPresenter?.showAlert(model: alertModel)
            } else {
                switchToNextQuestion()
                
                questionFactory?.requestNextQuestion()
                viewController?.unlockButtons()
            }
        }
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        viewController?.imageView.layer.borderWidth = 8
        viewController?.imageView.layer.masksToBounds = true
        
        if isCorrect == true {
            viewController?.highlightImageBorder(isCorrect: isCorrect)
        } else {
            viewController?.highlightImageBorder(isCorrect: isCorrect)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            proceedToNextQuestionOrResults()
        }
    }
}
