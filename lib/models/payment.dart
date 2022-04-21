enum PaymentStatus { pending, payed }

const MONTHS = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

class Payment {
  int? id;
  String client;
  double amount;
  DateTime date;
  PaymentStatus status;

  Payment({
    this.id,
    required this.client,
    required this.amount,
    required this.date,
    this.status = PaymentStatus.pending,
  });

  Payment.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        client = map['client'],
        amount = map['amount'],
        date = DateTime.parse(map['date']),
        status = map['status'] == 'pending'
            ? PaymentStatus.pending
            : PaymentStatus.payed;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client': client,
      'amount': amount,
      'date': date.toString().substring(0, 10),
      'status': status.toString().split('.').last,
    };
  }

  String get month {
    return MONTHS[date.month - 1];
  }

  @override
  String toString() {
    return 'Payment{id: $id, client: $client, date: $date, status: $status}';
  }
}
