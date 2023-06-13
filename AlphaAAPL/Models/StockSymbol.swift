import Foundation

enum StockSymbol: String, Decodable, Encodable {
  case aapl = "AAPL"
  case goog = "GOOG"
  case msft = "MSFT"
}

struct StockResponse: Decodable, Encodable {
  
  let realTimeQuotes: [Stock]
  
  enum CodingKeys: String, CodingKey {
    case realTimeQuotes = "real_time_quotes"
  }
}

struct Stock: Decodable, Encodable {
  
  let id: Int
  let slug: String
  let symbol: StockSymbol
  let high: Double
  let low: Double
  let open: Double?
  let close: Double
  let prevClose: Double
  let last: Double
  let volume: Int
  let lastTime: Date
  let marketCap: Double
  let extTime: Date?
  let extPrice: Double?
  let extMarket: String?
  let info: String
  let src: String
  let updatedAt: Date
  
  enum CodingKeys: String, CodingKey {
    case id = "sa_id"
    case slug = "sa_slug"
    case symbol
    case high
    case low
    case open
    case close
    case prevClose = "prev_close"
    case last
    case volume
    case lastTime = "last_time"
    case marketCap = "market_cap"
    case extTime = "ext_time"
    case extPrice = "ext_price"
    case extMarket = "ext_market"
    case info
    case src
    case updatedAt = "updated_at"
  }
}
