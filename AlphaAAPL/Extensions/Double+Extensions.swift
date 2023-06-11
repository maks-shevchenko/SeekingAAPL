extension Double {
  
  var formattedMarketCap: String {
    
    let trillion = 1_000_000_000_000.0
    let billion = 1_000_000_000.0
    let million = 1_000_000.0
    let thousand = 1_000.0
    
    if self >= trillion {
      return String(format: "%.2fT", self / trillion)
    } else if self >= billion {
      return String(format: "%.2fB", self / billion)
    } else if self >= million {
      return String(format: "%.2fM", self / million)
    } else if self >= thousand {
      return String(format: "%.2fK", self / thousand)
    } else {
      return "\(self)"
    }
  }
}
