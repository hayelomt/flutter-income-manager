import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:income_tracker/models/payment.dart';
import 'package:income_tracker/services/database_service.dart';
import 'package:validators/validators.dart' as validator;

class PaymentInput extends StatefulWidget {
  const PaymentInput({Key? key, required this.onLoadPayment}) : super(key: key);

  final Function onLoadPayment;

  @override
  State<PaymentInput> createState() => _PaymentInputState();
}

class _PaymentInputState extends State<PaymentInput> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final _moneyController = TextEditingController(text: '');
  final _clientController = TextEditingController(text: '');
  String date = DateTime.now().toString().substring(0, 10);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Add payment entry',
        style: TextStyle(color: Colors.green),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: ListBody(
            children: <Widget>[
              TextFormField(
                controller: _clientController,
                decoration: InputDecoration(hintText: 'Client / Company'),
                validator: (String? val) {
                  if (val == null || val.isEmpty) {
                    return 'Client can\'t be empty';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _moneyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Payment Money',
                ),
                validator: (String? val) {
                  if (val == null || val.isEmpty) {
                    return 'Money cant be empty';
                  }
                  if (!validator.isNumeric(val)) {
                    return 'Money must be number';
                  }

                  return null;
                },
              ),
              DateTimePicker(
                type: DateTimePickerType.date,
                dateMask: 'd MMM, yyyy',
                initialValue: DateTime.now().toString(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                icon: Icon(Icons.event),
                dateLabelText: 'Payment Date',
                onChanged: (val) => {
                  setState(() {
                    date = val;
                  })
                },
                validator: (val) {
                  return null;
                },
              )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Add'),
          onPressed: () async {
            final valid = formKey.currentState?.validate();
            if (valid != null && valid) {
              await DatabaseService.insert(Payment(
                  client: _clientController.text,
                  amount: double.parse(_moneyController.text),
                  date: DateTime.parse(date)));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Payment added')));
              widget.onLoadPayment();
            }
          },
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
