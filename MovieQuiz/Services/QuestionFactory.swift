//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Roman Frolov on 19.06.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didRecieveQuestion(_ question: QuizQuestion)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}

protocol QuestionFactory {
    func requestNextQuestion()
    func loadData()
}

final class QuestionFactoryImpl {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
 
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items // сохраняем фильм в нашу новую переменную
                    self.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error) // сообщаем об ошибке нашему MovieQuizViewController
                }
            }
        }
    }
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate? = nil) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
}

extension QuestionFactoryImpl: QuestionFactory {
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                let index = (0..<self.movies.count).randomElement() ?? 0
                
                guard let movie = self.movies[safe: index] else { return }
                
                var imageData = Data()
               
               do {
                    imageData = try Data(contentsOf: movie.resizedImageURL)
                } catch {
                    print("Failed to load image")
                }
                
                let rating = Float(movie.rating) ?? 0
                
                let text = "Рейтинг этого фильма больше чем 7?"
                let correctAnswer = rating > 7
                
                let question = QuizQuestion(image: imageData,
                                             text: text,
                                             correctAnswer: correctAnswer)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didRecieveQuestion(question)
                }
            }
    }
}

// массив вопросов
//private let questions: [QuizQuestion] = [
//    QuizQuestion(
//        image: "The Godfather",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "The Dark Knight",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "Kill Bill",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "The Avengers",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "Deadpool",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "The Green Knight",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "Old",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: false),
//    QuizQuestion(
//        image: "The Ice Age Adventures of Buck Wild",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: false),
//    QuizQuestion(
//        image: "Tesla",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: false),
//    QuizQuestion(
//        image: "Vivarium",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: false)
//]
