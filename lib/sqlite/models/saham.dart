class Saham {
  int? tickerid;
  String ticker;
  int open;
  int high;
  int last;
  double change;

  Saham({
    this.tickerid,
    required this.ticker,
    required this.open,
    required this.high,
    required this.last,
    required this.change,
  });

  factory Saham.fromMap(Map<String, dynamic> map) => Saham(
    tickerid: map['tickerid'] as int?,
    ticker: map['ticker'] as String,
    open: map['open'] as int,
    high: map['high'] as int,
    last: map['last'] as int,
    change:
        (map['change'] is int)
            ? (map['change'] as int).toDouble()
            : (map['change'] as double),
  );

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'ticker': ticker,
      'open': open,
      'high': high,
      'last': last,
      'change': change,
    };
    if (tickerid != null) map['tickerid'] = tickerid;
    return map;
  }
}
