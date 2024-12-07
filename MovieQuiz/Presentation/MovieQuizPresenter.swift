//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Василий Ханин on 08.12.2024.
//
import UIKit
import Foundation

final class MovieQuizPresenter {
    // MARK: -Public properties
    let questionsAmount = 10
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    // MARK: -Private properties
    private var currentQuestionIndex = 0
    
    
    // MARK: - IB Actions
    func noButtonClicked() {
        viewController?.blockButtons()
        if currentQuestion?.correctAnswer == false {
            viewController?.showAnswerResult(isCorrect: true)
            viewController?.correctAnswers += 1
        } else {
            viewController?.showAnswerResult(isCorrect: false)
        }
    }
    
    func yesButtonClicked() {
        viewController?.blockButtons()
        if currentQuestion?.correctAnswer == true {
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
}   
