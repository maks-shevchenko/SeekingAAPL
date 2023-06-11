import XCTest
import RxSwift
@testable import AlphaAAPL

final class AlphaAAPLTests: XCTestCase {
  
  var stockService: StockService!
  var testView: MainViewController!
  var viewModel: MainViewModel!
  var disposeBag: DisposeBag!
  
  override func setUpWithError() throws {
    super.setUp()
    
    stockService = StockService()
    viewModel = MainViewModel(stockService: stockService)
    testView = MainViewController(viewModel: viewModel)
    disposeBag = DisposeBag()
    
    testView.loadViewIfNeeded()
  }
  
  override func tearDownWithError() throws {
    stockService = nil
    viewModel = nil
    testView = nil
    disposeBag = nil
    super.tearDown()
  }
  
  func testMainViewModel() throws {
    let expectation = XCTestExpectation(description: "MainViewModel")
    
    viewModel.stock
      .subscribe(onNext: { stock in
        XCTAssertNotNil(stock, "Stock should not be nil")
        expectation.fulfill()
      })
      .disposed(by: disposeBag)
    
    wait(for: [expectation], timeout: 10.0)
  }
  
  func testViewDidLoad() throws {
    XCTAssertNotNil(testView.view, "View should be loaded")
    XCTAssertNotNil(testView.priceLabel, "Price label should be loaded")
    XCTAssertNotNil(testView.symbolLabel, "Symbol label should be loaded")
  }
  
  func testViewUpdate() throws {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

    let mockStock = Stock(
        id: 146,
        slug: "aapl",
        symbol: .aapl,
        high: 182.23,
        low: 180.63,
        open: 181.5,
        close: 180.96,
        prevClose: 180.57,
        last: 180.96,
        volume: 48899973,
        lastTime: dateFormatter.date(from: "2023-06-09T15:59:59.940-04:00")!,
        marketCap: 2846265913920,
        extTime: dateFormatter.date(from: "2023-06-09T19:59:59.737-04:00")!,
        extPrice: 180.81,
        extMarket: "post",
        info: "Market Close",
        src: "IexPuller",
        updatedAt: dateFormatter.date(from: "2023-06-09T21:01:22.684-04:00")!
    )
    
    testView.update(with: mockStock)
    
    XCTAssertEqual(testView.priceLabel.text, "\(mockStock.close)")
    XCTAssertEqual(testView.symbolLabel.text, mockStock.symbol.rawValue)
  }
}
