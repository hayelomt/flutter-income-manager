import 'package:flutter/material.dart';
import 'package:income_tracker/models/payment.dart';
import 'package:income_tracker/services/database_service.dart';
import 'package:income_tracker/widgets/payment_input.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  bool _loading = true;
  List<Payment> _payments = [];

  @override
  void initState() {
    super.initState();
    loadPayments();
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return PaymentInput(onLoadPayment: loadPayments);
      },
    );
  }

  void loadPayments() async {
    setState(() {
      _loading = true;
      _payments = [];
    });
    final paymentList = await DatabaseService.payments();

    setState(() {
      _loading = false;
      _payments = paymentList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF3F9F5),
      key: scaffoldKey,
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 24.0),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text('Pending Payments',
                      style: TextStyle(fontSize: 20.0)),
                ),
                SizedBox(height: 16.0),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 12.0,
                      right: 12.0,
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 48.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _payments
                              .map((item) => _paymentSummary(item))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff5FB671),
        child: Icon(Icons.add),
        onPressed: () {
          _showMyDialog(context);
        },
      ),
    );
  }

  Container _buildHeader() {
    final paymentTotal = _payments.isNotEmpty
        ? _payments.map((a) => a.amount).reduce((a, b) => a + b)
        : 0;

    return Container(
      height: 200,
      width: double.infinity,
      padding: EdgeInsets.only(top: 60, left: 30),
      decoration: BoxDecoration(
        color: Color(0xff5FB671),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(96.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Pending',
              style: TextStyle(color: Colors.grey[200], fontSize: 16.0)),
          SizedBox(height: 10.0),
          Text(
            '$paymentTotal',
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Container _paymentSummary(Payment payment) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.0),
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.circular(16),
        border: Border(
          bottom: BorderSide(width: 1.0, color: Colors.grey.withOpacity(.3)),
        ),
      ),
      child: ListTile(
        title: Text(payment.client),
        subtitle: Text('${payment.amount}'),
        trailing: IconButton(
          icon: Icon(Icons.done, color: Colors.green),
          onPressed: () {
            DatabaseService.markComplete(payment.id!).then((_) async {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Payment Received')));
              loadPayments();
            });
          },
        ),
        contentPadding: EdgeInsets.only(left: 5.0),
        leading: Container(
          width: 55,
          height: 55,
          padding: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: Color(0xff5FB671),
            borderRadius: BorderRadius.circular(60),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${payment.date.day}',
                  style: TextStyle(color: Colors.white, fontSize: 18.0)),
              Text('${payment.month},${payment.date.year}',
                  style: TextStyle(color: Colors.white, fontSize: 11.0))
            ],
          ),
        ),
      ),
    );
  }
}
