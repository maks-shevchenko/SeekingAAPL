class MainViewControllerFactory {
  
  func makeMainViewController() -> MainViewController {
    
    let stockService = StockService() 
    let viewModel = MainViewModel(stockService: stockService)
    let mainViewController = MainViewController(viewModel: viewModel)
    return mainViewController
    
  }
}
