// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:salespro_admin/Repository/paypal_repo.dart';
import 'package:salespro_admin/model/subscription_model.dart';
import '../../Provider/subacription_plan_provider.dart';
import '../../Repository/subscription_plan_repo.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../main.dart';
import '../../model/seller_info_model.dart';
import '../../model/subscription_plan_model.dart';
import '../../razorpay/razor_pay.dart';
import '../Payment Handler/payment_success.dart';
import '../Widgets/Constant Data/constant.dart';
import '../Widgets/Sidebar/sidebar_widget.dart';
import 'package:salespro_admin/generated/l10n.dart' as lang;
import 'dart:js' as js;
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({
    super.key,
  });
  static const String route = '/subscription_plans';

  @override
  // ignore: library_private_types_in_public_api
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  CurrentSubscriptionPlanRepo currentSubscriptionPlanRepo = CurrentSubscriptionPlanRepo();


// Assuming you have created an order via your backend


  SubscriptionModel currentSubscriptionPlan = SubscriptionModel(
    subscriptionName: 'Free',
    subscriptionDate: DateTime.now().toString(),
    saleNumber: 0,
    purchaseNumber: 0,
    partiesNumber: 0,
    dueNumber: 0,
    duration: 0,
    products: 0,
  );

  void getCurrentSubscriptionPlan() async {
    currentSubscriptionPlan = await currentSubscriptionPlanRepo.getCurrentSubscriptionPlans();
    setState(() {
      currentSubscriptionPlan;
    });
  }
  Razorpay? _razorpay;
  // Function to add a new seller


// Function to update seller info

  @override
  initState() {
    super.initState();
    // voidLink(context: context);
    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _handlePaymentSuccess;
    getCurrentSubscriptionPlan();
    // MyApp.getPaypalInfo();
    planName;
  }




  void openCheckout(String contact, String email,var amount,) {
    var options = js.JsObject.jsify({
      "key": "rzp_live_LQpw9dfarShC9Z", // Razorpay Key ID
      "amount": amount, // Amount in paise (50000 paise = 500 INR)
      "currency": "INR",
      "name": "JoinBills",
      "description": "Subscription Payment",
      "prefill": {
        "contact": contact,
        "email": email,
      },
      "external": {
        "wallets": ["paytm"]
      },
      "handler": js.allowInterop((response) {
        // Handle successful payment response
        print("Payment ID: ${response['razorpay_payment_id']}");
        EasyLoading.showSuccess("Payment Successful: ${response['razorpay_payment_id']}");
      }),
      "modal": {
        "ondismiss": js.allowInterop(() {
          // Handle payment modal dismissal
          print("Checkout form closed");
          EasyLoading.showError("Checkout form closed");
        })
      }
    });

    try {
      // Call the JavaScript function to open the Razorpay checkout
      js.context.callMethod('openRazorpayCheckout', [options]);
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _razorpay?.clear();
  }
  var contact;
  var email;

  var planName;
  // void openCheckout(String contact, String email,var amount,)  {
  //
  //   var options = js.JsObject.jsify({
  //     "key":"rzp_live_LQpw9dfarShC9Z", // Razorpay Key ID
  //     "amount": amount, // Amount in paise (50000 paise = 500 INR)
  //     "currency": "INR",
  //     "name": "JoinBills",
  //     "description": "Subscription",
  //     "prefill": {
  //       "contact": contact,
  //       "email": email,
  //     },
  //     "external": {
  //       "wallets": ["paytm"]
  //     },
  //     "handler": js.allowInterop((response)  {
  //       // Handle successful payment response
  //       print("Payment ID: ${response['razorpay_payment_id']}");
  //
  //       // Assuming constUserId is your user ID
  //       // EasyLoading.showSuccess("Payment Successful: ${response['razorpay_payment_id']}");
  //     }),
  //     "modal": {
  //       "ondismiss": js.allowInterop(() {
  //         // Handle payment modal dismissal
  //         print("Checkout form closed");
  //         EasyLoading.showError("Checkout form closed");
  //       })
  //     }
  //   });
  //   try {
  //     // Call the JavaScript function to open the Razorpay checkout
  //     js.context.callMethod('openRazorpayCheckout', [options]);
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  // Payment success handler
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    SubscriptionPlanRepo subscriptionPlanRepo = SubscriptionPlanRepo();
    List<SubscriptionPlanModel> planList = await subscriptionPlanRepo.getAllSubscriptionPlans();
    EasyLoading.showSuccess('Payment Successful');

    for(var i in planList ){
      await PaymentSuccess.updateSubscription(constUserId,i.subscriptionName, context);

    }

    // Call updateSubscription after successful payment

  }

  // Payment error handler
  void _handlePaymentError(PaymentFailureResponse response) {
    EasyLoading.showError('Payment Failed');
  }

  // External wallet handler (Optional)
  void _handleExternalWallet(ExternalWalletResponse response) {
    EasyLoading.showInfo('External Wallet selected');
  }
  List<Color> colors = [
    const Color(0xFF06DE90),
    const Color(0xFFF5B400),
    const Color(0xFFFF7468),
  ];
  // PaypalRepo paypalRepo = PaypalRepo();
  SubscriptionPlanModel selectedPlan =
      SubscriptionPlanModel(subscriptionName: '', saleNumber: 0, purchaseNumber: 0, partiesNumber: 0, dueNumber: 0, duration: 0, products: 0, subscriptionPrice: 0, offerPrice: 0);
  ScrollController mainScroll = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkWhite,
      body: Consumer(builder: (context, ref, __) {
        final subscriptionData = ref.watch(subscriptionPlanProvider);
        // final personDetials = ref.watch(personalInformationModel);
        return Scrollbar(
          controller: mainScroll,
          child: SingleChildScrollView(
            controller: mainScroll,
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 240,
                  child: SideBarWidget(
                    index: 13,
                    isTab: false,
                  ),
                ),
                subscriptionData.when(data: (data) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        width: context.width() < 1080 ? 1080 - 240 : MediaQuery.of(context).size.width - 240,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('images/jb.png'),
                                ),
                              ),
                            ),
                            Divider(
                              thickness: 1.0,
                              color: kGreyTextColor.withOpacity(0.1),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              lang.S.of(context).choceaplan,
                              style: kTextStyle.copyWith(color: kGreyTextColor, fontWeight: FontWeight.bold, fontSize: 21.0),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20.0),
                            Center(
                              child: SizedBox(
                                width: context.width() < 1080 ? 1080 - 240 : MediaQuery.of(context).size.width - 240,
                                height: 500,
                                child: ListView.builder(
                                  physics: const ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15),
                                              color: kWhite,
                                              border: Border.all(color: kBorderColorTextField),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: kDarkWhite,
                                                  offset: Offset(5, 5),
                                                  spreadRadius: 2.0,
                                                  blurRadius: 10.0,
                                                )
                                              ]
                                            ),
                                            width: 260,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Image.asset(
                                                  'images/free.png',
                                                  height: 80.0,
                                                  width: 80.0,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(20.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        data[index].subscriptionName,
                                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 25.0),
                                                      ),
                                                      const SizedBox(height: 6.0),
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            data[index].offerPrice > 0 ? '$currency${data[index].subscriptionPrice}' : '',
                                                            style: const TextStyle(
                                                              decoration: TextDecoration.lineThrough,
                                                              fontSize: 18,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                          Text(
                                                            data[index].offerPrice > 0 ? '$currency${data[index].offerPrice}' : '$currency${data[index].subscriptionPrice}',
                                                            style: kTextStyle.copyWith(color: colors[index % 3], fontSize: 25.0, fontWeight: FontWeight.bold),
                                                          ),
                                                          const SizedBox(width: 4.0),
                                                          Text(
                                                            '/${data[index].duration} Day',
                                                            style: kTextStyle.copyWith(color: kTitleColor),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 6.0,
                                                      ),
                                                      Text(
                                                        lang.S.of(context).allBasicFeature,
                                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 16.0),
                                                      ),
                                                      const SizedBox(
                                                        height: 6.0,
                                                      ),
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.check,
                                                            color: colors[index % 3],
                                                          ),
                                                          const SizedBox(
                                                            width: 4.0,
                                                          ),
                                                          currentSubscriptionPlan.subscriptionName == data[index].subscriptionName
                                                              ? Text(
                                                                  data[index].saleNumber == -202
                                                                      ? 'Unlimited Sales'
                                                                      : 'Sales Limit (${currentSubscriptionPlan.saleNumber}/${data[index].saleNumber})',
                                                                  style: kTextStyle.copyWith(color: kTitleColor, fontSize: 12.0),
                                                                )
                                                              : Text(
                                                                  data[index].saleNumber == -202 ? 'Unlimited Sales' : '${data[index].saleNumber} Sales',
                                                                  style: kTextStyle.copyWith(color: kTitleColor, fontSize: 12.0),
                                                                ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 6.0),
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.check,
                                                            color: colors[index % 3],
                                                          ),
                                                          const SizedBox(width: 4.0),
                                                          currentSubscriptionPlan.subscriptionName == data[index].subscriptionName
                                                              ? Text(
                                                                  data[index].partiesNumber == -202
                                                                      ? 'Unlimited Purchases'
                                                                      : 'Purchases Limit (${currentSubscriptionPlan.partiesNumber}/${data[index].partiesNumber})',
                                                                  style: kTextStyle.copyWith(color: kTitleColor, fontSize: 12.0),
                                                                )
                                                              : Text(
                                                                  data[index].partiesNumber == -202 ? 'Unlimited Purchases' : '${data[index].partiesNumber} Purchases',
                                                                  style: kTextStyle.copyWith(color: kTitleColor, fontSize: 12.0),
                                                                ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 6.0),
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.check,
                                                            color: colors[index % 3],
                                                          ),
                                                          const SizedBox(
                                                            width: 4.0,
                                                          ),
                                                          currentSubscriptionPlan.subscriptionName == data[index].subscriptionName
                                                              ? Text(
                                                                  data[index].partiesNumber == -202
                                                                      ? 'Unlimited Parties'
                                                                      : 'Parties Limit (${currentSubscriptionPlan.partiesNumber}/${data[index].partiesNumber})',
                                                                  style: kTextStyle.copyWith(color: kTitleColor, fontSize: 12.0),
                                                                )
                                                              : Text(
                                                                  data[index].partiesNumber == -202 ? 'Unlimited Parties' : '${data[index].partiesNumber} Parties',
                                                                  style: kTextStyle.copyWith(color: kTitleColor, fontSize: 12.0),
                                                                ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 6.0,
                                                      ),
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.check,
                                                            color: colors[index % 3],
                                                          ),
                                                          const SizedBox(
                                                            width: 4.0,
                                                          ),
                                                          currentSubscriptionPlan.subscriptionName == data[index].subscriptionName
                                                              ? Text(
                                                                  data[index].dueNumber == -202
                                                                      ? 'Unlimited Due Collection'
                                                                      : 'Due Collection Limit (${currentSubscriptionPlan.dueNumber}/${data[index].dueNumber})',
                                                                  style: kTextStyle.copyWith(color: kTitleColor, fontSize: 12.0),
                                                                )
                                                              : Text(
                                                                  data[index].dueNumber == -202 ? 'Unlimited Due Collection' : '${data[index].dueNumber} Due Collection',
                                                                  style: kTextStyle.copyWith(color: kTitleColor, fontSize: 12.0),
                                                                ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 6.0,
                                                      ),
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.check,
                                                            color: colors[index % 3],
                                                          ),
                                                          const SizedBox(width: 4.0),
                                                          Text(
                                                            lang.S.of(context).unlimitedInvoices,
                                                            style: kTextStyle.copyWith(color: kTitleColor, fontSize: 12.0),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 6.0,
                                                      ),
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.check,
                                                            color: colors[index % 3],
                                                          ),
                                                          const SizedBox(width: 4.0),
                                                          currentSubscriptionPlan.subscriptionName == data[index].subscriptionName
                                                              ? Text(
                                                                  data[index].products == -202
                                                                      ? 'Unlimited Products'
                                                                      : 'Products Limit (${currentSubscriptionPlan.products}/${data[index].products})',
                                                                  style: kTextStyle.copyWith(color: kTitleColor, fontSize: 12.0),
                                                                )
                                                              : Text(
                                                                  data[index].products == -202 ? 'Unlimited Products' : '${data[index].products} Products',
                                                                  style: kTextStyle.copyWith(color: kTitleColor, fontSize: 12.0),
                                                                ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 10.0,
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.all(6.0),
                                                        width: 200.0,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(20.0),
                                                          color: colors[index % 3],
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              lang.S.of(context).getStarted,
                                                              style: kTextStyle.copyWith(color: white, fontWeight: FontWeight.bold),
                                                            ),
                                                            const SizedBox(
                                                              width: 4.0,
                                                            ),
                                                            const Icon(
                                                              Icons.arrow_forward_rounded,
                                                              color: white,
                                                            ),
                                                          ],
                                                        ),
                                                      ).onTap(() async {
                                                        if (index >= 0 && index < data.length && data[index].subscriptionPrice > 0) {


                                                          openCheckout("8113808039", "amalasamad9@gmail.com", data[index].offerPrice.toString());

                                                        } else {
                                                          EasyLoading.showError('Failed');
                                                        }

                                                      }).visible(
                                                          currentSubscriptionPlan.subscriptionName != data[index].subscriptionName && data[index].subscriptionName != 'Free')
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          ///__________Current Plan__________________________________________________________________________________
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                  color: kBlueTextColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        lang.S.of(context).currentPlan,
                                                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                                      ),
                                                      Text(
                                                        'Expires in ${(DateTime.parse(currentSubscriptionPlan.subscriptionDate).difference(DateTime.now()).inDays.abs() - currentSubscriptionPlan.duration).abs()} Days',
                                                        style: kTextStyle.copyWith(color: kWhiteTextColor),
                                                        maxLines: 3,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ).visible(currentSubscriptionPlan.subscriptionName == data[index].subscriptionName)
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, error: (Object error, StackTrace? stackTrace) {
                  return Text(error.toString());
                }, loading: () {
                  return const Center(child: CircularProgressIndicator());
                }),
              ],
            ),
          ),
        );
      }),
    );
  }
}
