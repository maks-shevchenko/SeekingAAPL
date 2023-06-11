import UIKit
import RxSwift
import Alamofire

class MainViewController: UIViewController {
  
  private let disposeBag = DisposeBag()
  
  private let viewModel: MainViewModel
  
  private let gradientLayer = CAGradientLayer()
  internal let priceLabel = UILabel()
  internal let symbolLabel = UILabel()
  private let changeLabel = UILabel()
  private let marketCapLabel = UILabel()
  private let marketStatusLabel = UILabel()
  private let overlayView = UIView()
  
  init(viewModel: MainViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupGradientLayer()
    setupLabels()
    bindViewModel()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    gradientLayer.frame = view.bounds
    overlayView.frame = view.bounds
  }
  
  private func setupGradientLayer() {
    gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
    view.layer.addSublayer(gradientLayer)
    
    overlayView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
    overlayView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(overlayView)
  }
  
  private func setupLabels() {
    
    priceLabel.font = .systemFont(ofSize: 60, weight: .bold)
    priceLabel.textColor = .white
    priceLabel.textAlignment = .center
    priceLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(priceLabel)
    
    symbolLabel.font = .systemFont(ofSize: 20, weight: .medium)
    symbolLabel.textColor = .white
    symbolLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(symbolLabel)
    
    changeLabel.font = .systemFont(ofSize: 20, weight: .medium)
    changeLabel.textColor = .white
    changeLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(changeLabel)
    
    marketCapLabel.font = .systemFont(ofSize: 20, weight: .medium)
    marketCapLabel.textColor = .white
    marketCapLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(marketCapLabel)
    
    marketStatusLabel.font = .systemFont(ofSize: 20, weight: .medium)
    marketStatusLabel.textColor = .white
    marketStatusLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(marketStatusLabel)
    
    NSLayoutConstraint.activate([
      priceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      priceLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      
      symbolLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
      symbolLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      
      marketCapLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
      marketCapLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      
      changeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      changeLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 20),
      
      marketStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      marketStatusLabel.topAnchor.constraint(equalTo: changeLabel.bottomAnchor, constant: 20)
    ])
  }
  
  private func bindViewModel() {
    
    viewModel.stock
      .compactMap { $0 }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] stock in
        self?.update(with: stock)
      })
      .disposed(by: disposeBag)
    
    viewModel.error
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] error in
        self?.showErrorAlert(error: error)
      })
      .disposed(by: disposeBag)
    
    viewModel.startAnimationSubject
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        self?.startOverlayAnimation()
      })
      .disposed(by: disposeBag)
  }
  
  func update(with stock: Stock) {
    
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.maximumFractionDigits = 2
    
    let percentChange = ((stock.close - stock.prevClose) / stock.prevClose) * 100
    let formattedPercentChange = numberFormatter.string(from: NSNumber(value: percentChange)) ?? "0"
    
    print(stock.close)
    
    if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
      self.priceLabel.text = "\(stock.close)"
    } else {
      UIView.animate(withDuration: 0.15, animations: {
        self.priceLabel.alpha = 0.0
      }) { _ in
        self.priceLabel.text = "\(stock.close)"
        UIView.animate(withDuration: 0.15) {
          self.priceLabel.alpha = 1.0
        }
      }
    }
    
    symbolLabel.text = stock.symbol.rawValue
    
    changeLabel.text = "\(formattedPercentChange)%"
    changeLabel.textColor = percentChange >= 0 ? .systemGreen : .systemRed
    marketCapLabel.text = "Market Cap: \(stock.marketCap.formattedMarketCap)"
    
    let now = Date()
    if now >= stock.lastTime && now <= stock.extTime {
      marketStatusLabel.text = "Market: Open"
    } else {
      marketStatusLabel.text = "Market: Closed"
    }
  }
  
  private func showErrorAlert(error: Error) {
    
    let message: String
    
    if let error = error as? AFError, case .responseSerializationFailed(let reason) = error {
      switch reason {
      case .decodingFailed(let error):
        message = "Decoding failed: \(error)"
      default:
        message = error.localizedDescription
      }
    } else {
      message = error.localizedDescription
    }
    
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
  
  private func startOverlayAnimation() {
    
    overlayView.frame = CGRect(x: 0, y: 0, width: 0, height: self.view.bounds.height)
    
    UIView.animate(withDuration: viewModel.updateFrequency, delay: 0, options: [.curveLinear]) {
      self.overlayView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
    } completion: { _ in
      self.overlayView.frame = CGRect(x: 0, y: 0, width: 0, height: self.view.bounds.height)
    }
  }
}
