//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Roman Frolov on 19.06.2023.
//

import Foundation

struct QuizQuestion {
    let image: Data            // картинка, полученная с сервера
    let text: String           // строка с вопросом о рейтинге фильма
    let correctAnswer: Bool    // булевое значение (true, false), правильный ответ на вопрос
}
