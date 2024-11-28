import 'package:codecraft/main.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:paypal_payment/paypal_payment.dart';
import 'package:paypal_sdk/core.dart';
import 'package:paypal_sdk/subscriptions.dart';

class PlanViewScreen extends StatefulWidget {
  const PlanViewScreen({super.key});

  @override
  _PlanViewScreenState createState() => _PlanViewScreenState();
}

class _PlanViewScreenState extends State<PlanViewScreen> {
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
              price: (orgData['maxApprentices'] ?? 5) <= 5
                  ? "FREE"
                  : "₱${orgData['maxApprentices'] * 10} /monthly",
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
            // cancel subscription
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

  Future<void> _cancelSubscription() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    String orgId = userDoc.get('orgId');

    final org = await FirebaseFirestore.instance
        .collection('organizations')
        .doc(orgId)
        .get();

    PayPalEnvironment environment = PayPalEnvironment.sandbox(
      clientId: clientId,
      clientSecret: secretKey,
    );

    PayPalHttpClient client = PayPalHttpClient(environment);

    SubscriptionsApi subscriptionsApi = SubscriptionsApi(client);
    subscriptionsApi.cancelSubscription(
      org.get('plan'),
      'CANCELLED',
    );

    await FirebaseFirestore.instance
        .collection('organizations')
        .doc(orgId)
        .set({
      'plan': 'Free',
      'maxApprentices': 5,
    }, SetOptions(merge: true));
  }
}

class PlanUpgradeScreen extends ConsumerStatefulWidget {
  const PlanUpgradeScreen({super.key});

  @override
  _PlanUpgradeScreenState createState() => _PlanUpgradeScreenState();
}

class _PlanUpgradeScreenState extends ConsumerState<PlanUpgradeScreen> {
  double _currentSliderValue = 10.0;

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

        _currentSliderValue =
            (snapshot.data!['maxApprentices'] ?? 5.0).toDouble();

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
                        min: 0,
                        max: 100,
                        divisions: 100,
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
                            price: (orgData['maxApprentices'] ?? 5) <= 5
                                ? "FREE"
                                : "₱${orgData['maxApprentices'] * 10} /monthly",
                          ),
                        ),
                        Expanded(
                          child: _buildPlanCard(
                            context,
                            title: "New Plan",
                            apprentices: "${_currentSliderValue.toInt()}",
                            price: _currentSliderValue.toInt() <= 5
                                ? "FREE"
                                : "₱${_currentSliderValue.toInt() * 10} /monthly",
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
              onPressed: () async => await _createPlan(),
              child: Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPlan() async {
    final computedPrice = (_currentSliderValue.toInt() * 10)
        .toDouble(); // Ensure this is a double

    try {
      Utils.scrollableMaterialDialog(
        context: context,
        title: 'Payment Details',
        customViewPosition: CustomViewPosition.BEFORE_ACTION,
        titleAlign: TextAlign.center,
        dialogWidth: 400,
        customView: Column(
          children: [
            Text(
              'You are about to upgrade to a new plan with ${_currentSliderValue.toInt()} apprentices.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Total: ₱$computedPrice',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return PaypalSubscriptionPayment(
                      sandboxMode: true,
                      clientId: clientId,
                      secretKey: secretKey,
                      productName: 'Apprentices Expansion',
                      type: "DIGITAL",
                      planName: 'Apprentices Expansion',
                      customId: ref
                              .watch(appUserNotifierProvider)
                              .requireValue
                              .orgId ??
                          '',
                      billingCycles: [
                        {
                          'frequency': {
                            "interval_unit": "MONTH",
                            "interval_count": 1
                          },
                          'tenure_type': 'REGULAR',
                          'sequence': 1,
                          "total_cycles": 0,
                          'pricing_scheme': {
                            'fixed_price': {
                              'value': 10,
                              'currency_code': 'PHP',
                            },
                          },
                        }
                      ],
                      quantitySupported: true,
                      quantity: _currentSliderValue.toInt().toString(),
                      paymentPreferences: const {"auto_bill_outstanding": true},
                      returnURL: kDebugMode
                          ? 'http://localhost:5000/'
                          : 'https://code-craft.live/',
                      cancelURL: kDebugMode
                          ? 'http://localhost:5000/'
                          : 'https://code-craft.live/',
                      onSuccess: () {
                        Utils.displayDialog(
                          context: context,
                          title: 'Success',
                          content: 'Payment successful!',
                        );
                      },
                      onError: () {
                        Utils.displayDialog(
                          context: context,
                          title: 'Error',
                          content: 'Payment failed. Please try again.',
                        );
                      },
                      onCancel: () {
                        Utils.displayDialog(
                          context: context,
                          title: 'Cancelled',
                          content: 'Payment cancelled.',
                        );
                      },
                    );
                  },
                ),
              );
            },
            child: Text('Proceed to Payment.'),
          ),
        ],
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      Utils.displayDialog(
        context: context,
        title: 'Error',
        content:
            'Failed to create plan: ${e.apiError!.message!}.\nPlease contact support.',
      );
    }
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
