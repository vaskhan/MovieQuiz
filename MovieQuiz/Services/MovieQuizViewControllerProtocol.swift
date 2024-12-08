//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Василий Ханин on 08.12.2024.
//
import UIKit
import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    var alertPresenter: AlertPresenter? { get set }
    var imageView: UIImageView! { get set }
    
    func show(quiz step: QuizStepViewModel)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func blockButtons()
    func unlockButtons()
}
