//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Василий Ханин on 08.12.2024.
//
import UIKit
import Foundation

final class MovieQuizPresenter {
    
    private var currentQuestionIndex = 0
    let questionsAmount = 10
    
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
