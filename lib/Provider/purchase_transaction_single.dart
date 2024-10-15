import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salespro_admin/Provider/transactions_provider.dart';
import 'package:salespro_admin/model/transition_model.dart';

import '../Repository/transactions_repo.dart';
import '../Repository/transactions_repo.dart';
import '../Repository/transactions_repo.dart';

PurchaseTransitionRepo purchaseTransitionSingleRepo = PurchaseTransitionRepo();
final purchaseTransitionProviderSIngle = FutureProvider.autoDispose<List<PurchaseTransactionModel>>((ref) => purchaseTransitionRepo.getAllTransitionSingle());