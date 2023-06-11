import RxSwift
import Alamofire

class StockService {
  
  private let baseURL = "https://finance-api.seekingalpha.com/real_time_quotes"
  
  func fetchStock(symbol: StockSymbol) -> Observable<StockResponse> {
    
    let url = "\(baseURL)?sa_ids=146"
    
    return Observable.create { observer in
      
      let decoder = JSONDecoder()
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
      decoder.dateDecodingStrategy = .formatted(dateFormatter)
      
      AF.request(url).responseDecodable(of: StockResponse.self, decoder: decoder) { response in
        
        switch response.result {
          
        case .success(let stock):
          observer.onNext(stock)
          observer.onCompleted()
          
        case .failure(let error):
          observer.onError(error)
          
        }
      }
      
      return Disposables.create()
    }
  }
}
