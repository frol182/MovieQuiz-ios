import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - Properties
  
    @IBOutlet var imageView: UIImageView! //Афиша
    @IBOutlet private var textLabel: UILabel!     //Вопрос
    @IBOutlet private var counterLabel: UILabel!    //Счетчик
    @IBOutlet private var activityIndicator: UIActivityIndicatorView! //кружок загрузки

    private var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        alertPresenter = AlertPresenterImpl(viewController: self)
        showLoadingIndicator()
        presenter = MovieQuizPresenter(viewController: self)
    }
    // MARK: - Functions
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showFinalResults () {
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: presenter.makeResultMessage(),
            buttonText: "Сыграть ещё раз",
            buttonAction: { [weak self] in
                self?.presenter.resetQuestionIndex()
                self?.presenter.restartGame()
            }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alertModel = AlertModel(
            title: "Ошибка",
            message: "Ошибка соединения",
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.presenter.restartGame()
            }        
        alertPresenter?.show(alertModel: alertModel)
    }
    
    // MARK: - Buttons
    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }

    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
}
    // MARK: - Protocol
protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func showFinalResults()
}
