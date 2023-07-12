//v3
import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Properties
  
    @IBOutlet private var imageView: UIImageView! //Афиша
    @IBOutlet private var textLabel: UILabel!     //Вопрос
    @IBOutlet private var counterLabel: UILabel!    //Счетчик
    @IBOutlet private var activityIndicator: UIActivityIndicatorView! //кружок загрузки
    
    private var correctAnswers = 0    // переменная со счётчиком правильных ответов
    private var currentQuestionIndex = 0    // переменная с индексом текущего вопроса
    private var currentQuestion: QuizQuestion?
    private var questionFactory : QuestionFactory?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
 
    private let questionCount = 10
 
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactoryImpl(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImpl()
        
        alertPresenter = AlertPresenterImpl(viewController: self)
        questionFactory?.requestNextQuestion()
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionCount)")
        return questionStep
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // приватный метод, который обрабатывает результат ответа
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect { // 1
            correctAnswers += 1 // 2
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        if currentQuestionIndex == questionCount - 1 {
            showFinalResults()
            imageView.layer.masksToBounds = true
        } else {
            currentQuestionIndex += 1
            // Идем в состояние "Вопрос показан"
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showFinalResults () {
        statisticService?.store(correct: correctAnswers, total: questionCount)
        
        let alertModel = AlertModel(
            title: "Игра окончена",
            message: makeResultMessage(),
            buttonText: "OK",
            buttonAction: { [weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
        )
        
        alertPresenter?.show(alertModel: alertModel)
    }
    
    private func makeResultMessage() -> String {
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("Error message")
            return ""
        }
        
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionCount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)" + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(accuracy)"
        
        let components: [String] = [currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine]
        
        let resultMessage = components.joined(separator: "\n")
        
        return resultMessage
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: "Ошибка соединения",
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                self.questionFactory?.requestNextQuestion()
            }
        
        alertPresenter?.show(alertModel: alertModel)
    }
    
    // MARK: - Buttons
    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion?.correctAnswer)
    }

    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion?.correctAnswer)
    }
    
}

// MARK: - Extentions
extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveQuestion(_ question: QuizQuestion) {
        self.currentQuestion = question
        let viewModel = self.convert(model: question)
        self.show(quiz: viewModel)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
}
