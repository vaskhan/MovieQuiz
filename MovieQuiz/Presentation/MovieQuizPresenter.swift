//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Василий Ханин on 08.12.2024.
//
import UIKit
import Foundation

final class MovieQuizPresenter {
    // MARK: - Public properties
    let questionsAmount = 10
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var correctAnswers: Int = 0
    
    // MARK: - Private properties
    private var currentQuestionIndex = 0
    
    
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
    
    // MARK: - Public Methods
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func didAnswer(isYes: Bool) {
        viewController?.blockButtons()
        
        if currentQuestion?.correctAnswer == isYes {
            viewController?.showAnswerResult(isCorrect: true)
            viewController?.correctAnswers += 1
        } else {
            viewController?.showAnswerResult(isCorrect: false)
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) / \(questionsAmount)"
        )
    }
    
    func showNextQuestionOrResults() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.isLastQuestion() {
                viewController?.statisticService.store(correct: correctAnswers, total: self.questionsAmount)
                let alertModel = AlertModel(
                    title: "Этот раунд окончен!",
                    message: correctAnswers == self.questionsAmount ? "Поздравляем, Вы ответили на 10 из 10!" :  "Ваш результат \(correctAnswers)/\(self.questionsAmount)\nКоличество сыгранных квизов: \(viewController?.statisticService.gamesCount ?? 0)\nРекорд: \(viewController?.statisticService.bestGame.correct ?? 0)/\(viewController?.statisticService.bestGame.total ?? 0) (\(viewController?.statisticService.bestGame.date.dateTimeString ?? "нет данных"))\nСредняя точность: \(String(format: "%.2f", viewController?.statisticService.totalAccuracy ?? 0.0))%",
                    buttonText: "Сыграть ещё раз",
                    completion: {[weak self] in
                        self?.resetQuestionIndex()
                        self?.correctAnswers = 0
                        self?.viewController?.questionFactory?.requestNextQuestion()
                        self?.viewController?.unlockButtons()
                    })
                
                viewController?.alertPresenter?.showAlert(model: alertModel)
            } else {
                switchToNextQuestion()
                
                viewController?.questionFactory?.requestNextQuestion()
                viewController?.unlockButtons()
            }
        }
    }
}
