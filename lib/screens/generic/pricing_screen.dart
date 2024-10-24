import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlanViewScreen extends StatelessWidget {
  const PlanViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _fetchOrganizationData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('No plan data available'));
        }

        Map<String, dynamic> orgData =
            snapshot.data!.data() as Map<String, dynamic>;
        return _buildPlanView(context, orgData);
      },
    );
  }

  Widget _buildPlanView(BuildContext context, Map<String, dynamic> orgData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Your Current Plan',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            _buildPlanCard(
              context,
              title: "Your Organization Plan",
              apprentices: "${orgData['maxApprentices'] ?? 5}",
              price:
                  "₱${(orgData['maxApprentices'] ?? 5) <= 5 ? 5 : orgData['maxApprentices'] * 10} /monthly",
            ),
            SizedBox(height: 20),
            Text(
              'Contact your mentor to upgrade the plan.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String apprentices,
    required String price,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      width: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          SizedBox(height: 16),
          Text(
            apprentices,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Max Apprentices',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            price,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<DocumentSnapshot> _fetchOrganizationData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    String orgId = userDoc.get('orgId');

    return FirebaseFirestore.instance
        .collection('organizations')
        .doc(orgId)
        .get();
  }
}

class PlanUpgradeScreen extends ConsumerStatefulWidget {
  const PlanUpgradeScreen({super.key});

  @override
  _PlanUpgradeScreenState createState() => _PlanUpgradeScreenState();
}

class _PlanUpgradeScreenState extends ConsumerState<PlanUpgradeScreen> {
  double _currentSliderValue = 10;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseHelper().getOrganization(
          ref.read(appUserNotifierProvider).requireValue.orgId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return Center(child: Text('No organization data available'));
        }

        return _buildUpgradeView(context, snapshot.data!);
      },
    );
  }

  Widget _buildUpgradeView(BuildContext context, Map<String, dynamic> orgData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Upgrade plan for more apprentices',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'More apprentices, more learning, more impact!',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            _buildTag(context, "Current Plan", isSelected: true),
            SizedBox(height: 20),
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.blue[100],
                        inactiveTrackColor: Colors.blue[100],
                        thumbColor: Theme.of(context).primaryColor,
                        overlayShape: SliderComponentShape.noOverlay,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 20,
                          elevation: 5,
                        ),
                      ),
                      child: Slider(
                        value: _currentSliderValue,
                        min: 10,
                        max: 100,
                        divisions: 9,
                        onChanged: (double value) {
                          setState(() {
                            _currentSliderValue = value;
                          });
                        },
                      ),
                    ),
                    Text(
                      '${_currentSliderValue.toInt()}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPlanCard(
                            context,
                            title: "Your Current Plan",
                            apprentices: "${orgData['maxApprentices'] ?? 5}",
                            price:
                                "₱${(orgData['maxApprentices'] ?? 5) <= 5 ? 5 : orgData['maxApprentices'] * 10} /monthly",
                          ),
                        ),
                        Expanded(
                          child: _buildPlanCard(
                            context,
                            title: "New Plan",
                            apprentices: "${_currentSliderValue.toInt()}",
                            price:
                                "₱${(_currentSliderValue * 10).toInt()} /monthly",
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              'If you are upgrading from current plan, the change will be immediate.\n'
              'If you are downgrading from current plan, the change will happen in the next billing cycle.',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text(
                'Proceed to Payment',
              ),
              onPressed: () => ref
                  .watch(screenProvider.notifier)
                  .pushScreen(CreditCardFormScreen(
                    {
                      'maxApprentices': _currentSliderValue.toInt(),
                      'planPrice': _currentSliderValue.toInt() * 10,
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text,
      {bool isSelected = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[300] : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isSelected ? Colors.black : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String apprentices,
    required String price,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          SizedBox(height: 16),
          Text(
            apprentices,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Max Apprentices',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            price,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class CreditCardFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> planDetails;

  const CreditCardFormScreen(this.planDetails, {super.key});

  @override
  _CreditCardFormScreenState createState() => _CreditCardFormScreenState();
}

class _CreditCardFormScreenState extends ConsumerState<CreditCardFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvv = '';

  // Validator for card number
  String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter card number';
    } else if (value.length != 16) {
      return 'Card number must be 16 digits';
    }
    return null;
  }

  // Validator for expiry date (MM/YY format)
  String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter expiry date';
    }
    final RegExp regExp = RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$');
    if (!regExp.hasMatch(value)) {
      return 'Invalid expiry date (MM/YY)';
    }
    return null;
  }

  // Validator for card holder name
  String? validateCardHolderName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter card holder name';
    }
    return null;
  }

  // Validator for CVV
  String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter CVV';
    } else if (value.length != 3) {
      return 'CVV must be 3 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Card Number'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 16,
              validator: validateCardNumber,
              onChanged: (value) => cardNumber = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Expiry Date (MM/YY)'),
              keyboardType: TextInputType.datetime,
              maxLength: 5,
              validator: validateExpiryDate,
              onChanged: (value) => expiryDate = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Card Holder Name'),
              validator: validateCardHolderName,
              onChanged: (value) => cardHolderName = value,
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(labelText: 'CVV'),
              keyboardType: TextInputType.number,
              maxLength: 3,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: validateCVV,
              onChanged: (value) => cvv = value,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Submit the form
                  await _submitForm();
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    await FirebaseFirestore.instance
        .collection('organizations')
        .doc(ref.watch(appUserNotifierProvider).requireValue.orgId!)
        .update(widget.planDetails);

    ref.watch(screenProvider.notifier).popScreen();
  }
}
