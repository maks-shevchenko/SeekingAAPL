import RxSwift
import RxCocoa

class MainViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let stockService: StockService
  
  private let stockSubject = BehaviorSubject<Stock?>(value: nil)
  private let errorSubject = PublishSubject<Error>()
  
  let updateFrequency: TimeInterval = 10
  let startAnimationSubject = PublishSubject<Void>()
  
  var stock: Observable<Stock?> {
    return stockSubject.asObservable()
  }
  
  var error: Observable<Error> {
    return errorSubject.asObservable()
  }
  
  init(stockService: StockService) {
    self.stockService = stockService
    loadCachedStock()
    setupFetch()
  }
  
  private func cacheStock(_ stock: Stock) {
    if let encodedStock = try? JSONEncoder().encode(stock) {
      UserDefaults.standard.set(encodedStock, forKey: "cachedStock")
    }
  }
  
  private func loadCachedStock() {
    if let encodedStock = UserDefaults.standard.data(forKey: "cachedStock"),
       let stock = try? JSONDecoder().decode(Stock.self, from: encodedStock) {
      stockSubject.onNext(stock)
    }
  }
  
  private func setupFetch() {
    
    Observable<Int>
      .timer(.seconds(0), period: .seconds(Int(updateFrequency)), scheduler: MainScheduler.instance)
      .do(onNext: { [weak self] _ in
        self?.startAnimationSubject.onNext(())
      })
      .flatMap { [weak self] _ -> Observable<Stock?> in
        guard let self = self else { return .just(nil) }
        return self.fetchStock()
      }
      .bind(to: stockSubject)
      .disposed(by: disposeBag)
  }
  
  private func fetchStock() -> Observable<Stock?> {
    
    return stockService.fetchStock(symbol: .aapl)
      .map { $0.realTimeQuotes.first }
      .do(onNext: { [weak self] stock in
        if let stock = stock {
          self?.cacheStock(stock)
        }
      })
      .catch { [weak self] error -> Observable<Stock?> in
        self?.errorSubject.onNext(error)
        return .just(nil)
      }
  }
}
