class Transaksi {
  int? transaksiid;
  int tickerid;
  int jumlah_transaksi;
  int jenis_transaksi; // 0 = beli, 1 = jual

  Transaksi({
    this.transaksiid,
    required this.tickerid,
    required this.jumlah_transaksi,
    required this.jenis_transaksi,
  });

  factory Transaksi.fromMap(Map<String, dynamic> map) => Transaksi(
    transaksiid: map['transaksiid'] as int?,
    tickerid: map['tickerid'] as int,
    jumlah_transaksi: map['jumlah_transaksi'] as int,
    jenis_transaksi: map['jenis_transaksi'] as int,
  );

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'tickerid': tickerid,
      'jumlah_transaksi': jumlah_transaksi,
      'jenis_transaksi': jenis_transaksi,
    };
    if (transaksiid != null) map['transaksiid'] = transaksiid;
    return map;
  }
}
