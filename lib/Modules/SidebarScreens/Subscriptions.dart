import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Models/ClassModel.dart';
import 'package:gms_flutter_windows/Models/SubscriptionModel.dart';
import 'package:gms_flutter_windows/Models/UserModel.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';

class Subscriptions extends StatefulWidget {
  const Subscriptions({super.key});

  @override
  State<Subscriptions> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<Subscriptions>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  double discount = 0.0;
  List<SubscriptionModel> userSubscriptions = [];
  List<UserModel> pendingUsers = [];

  final discountController = TextEditingController();
  final amountController = TextEditingController();

  late Manager manager;
  UserModel? selectedUser;
  ClassModel? selectedClass;
  ClassModel? selectedPendingClass;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    manager = Manager.get(context);
    manager.getAllUsers().then((_) => manager.getAllClasses());
    amountController.addListener(() => setState(() {}));
    discountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    discountController.dispose();
    amountController.dispose();
    manager.userSubscriptions.clear();
    manager.expiredSubscriptions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Manager, BlocStates>(
      listener: (context, state) {},
      builder: (context, state) => Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Components.reusableText(
              content: 'Subscriptions',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontColor: Colors.teal,
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              labelColor: Colors.teal,
              unselectedLabelColor: Colors.white,
              indicatorColor: Colors.teal,
              tabs: const [
                Tab(text: 'History & Payment'),
                Tab(text: 'Pending Payments'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ConditionalBuilder(
                condition: state is! LoadingState,
                builder: (context) => TabBarView(
                  controller: _tabController,
                  children: [_historyPaymentTab(), _pendingPaymentsTab()],
                ),
                fallback: (context) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyPaymentTab() {
    // we use seenTitles Set to prevent duplicates
    final seenTitles = <String>{};
    List<DropdownMenuItem<String>> classItems = userSubscriptions
        .where((s) => seenTitles.add(s.aClass.title))
        .map(
          (s) => DropdownMenuItem<String>(
            value: s.aClass.title,
            child: Components.reusableText(
              content: s.aClass.title,
              fontColor: Colors.white70,
            ),
          ),
        )
        .toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<int>(
                  value: selectedUser?.id,
                  hint: Components.reusableText(
                    content: 'Select user',
                    fontColor: Colors.white70,
                  ),
                  dropdownColor: Colors.black54,
                  isExpanded: true,
                  items: manager.allUsers.items.map((u) {
                    final name = '${u.firstName} ${u.lastName}';
                    return DropdownMenuItem(
                      value: u.id,
                      child: Components.reusableText(
                        content: name,
                        fontColor: Colors.white70,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final user = manager.allUsers.items.firstWhere(
                      (u) => u.id == value,
                    );
                    setState(() {
                      selectedUser = user;
                      selectedClass = null;
                      userSubscriptions.clear();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onPressed: (selectedUser == null)
                    ? null
                    : () async {
                        await manager
                            .getUserSubscriptionsHistory(selectedUser!.id)
                            .then((_) {
                              setState(
                                () => userSubscriptions =
                                    manager.userSubscriptions,
                              );
                            });
                      },
                child: const Text(
                  'View History',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: selectedClass?.title,
                  hint: Components.reusableText(
                    content: 'Select Class',
                    fontColor: Colors.white70,
                  ),
                  dropdownColor: Colors.black54,
                  isExpanded: true,
                  items: classItems,
                  onChanged: (value) {
                    final cls = userSubscriptions
                        .firstWhere((s) => s.aClass.title == value)
                        .aClass;
                    setState(() {
                      selectedClass = cls;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              if (selectedClass != null)
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.teal,
                    ),
                    child: Center(
                      child: Components.reusableText(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        content:
                            'price/month: \$${selectedClass!.price.toString()}',
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Components.reusableTextFormField(
                  hint: 'Amount',
                  prefixIcon: Icons.attach_money,
                  controller: amountController,
                  textInputType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Components.reusableTextFormField(
                  hint: 'Discount',
                  prefixIcon: Icons.percent,
                  controller: discountController,
                  textInputType: TextInputType.number,
                  onChanged: (v) => discount = double.tryParse(v) ?? 0.0,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onPressed:
                    (selectedUser == null ||
                        selectedClass == null ||
                        amountController.text.isEmpty ||
                        discountController.text.isEmpty)
                    ? null
                    : () async {
                        final amount =
                            double.tryParse(amountController.text) ?? 0.0;
                        if (amount <= 0) return;
                        manager.updateUserSubscription({
                          'userId': selectedUser!.id,
                          'classId': selectedClass!.id,
                          'paymentAmount': amount,
                          'discountPercentage': discount,
                        });
                      },
                child: const Text(
                  'Add Payment',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _subscriptionHistoryList(userSubscriptions)),
        ],
      ),
    );
  }

  Widget _subscriptionHistoryList(List<SubscriptionModel> subscriptions) {
    if (subscriptions.isEmpty) {
      return const Center(
        child: Text(
          'No subscription history.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    return ListView.builder(
      itemCount: subscriptions.length,
      itemBuilder: (context, i) {
        final s = subscriptions[i];
        return Card(
          color: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Components.reusableText(
                  content:
                      '${s.aClass.title} - \$${s.paymentAmount.toStringAsFixed(2)}',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontColor: Colors.teal,
                ),
                const SizedBox(height: 6),
                Components.reusableText(
                  content: 'Class Price: \$${s.aClass.price}',
                  fontSize: 14,
                  fontColor: Colors.white70,
                ),
                const SizedBox(height: 4),
                Components.reusableText(
                  content:
                      'Paid on: ${s.paymentDate.year}-${s.paymentDate.month.toString().padLeft(2, '0')}-${s.paymentDate.day.toString().padLeft(2, '0')}',
                  fontSize: 14,
                  fontColor: Colors.white70,
                ),
                if (s.discountPercentage > 0) ...[
                  const SizedBox(height: 4),
                  Components.reusableText(
                    content:
                        'Discount: ${s.discountPercentage.toStringAsFixed(0)}%',
                    fontSize: 14,
                    fontColor: Colors.orangeAccent,
                  ),
                ],
                const SizedBox(height: 4),
                Components.reusableText(
                  content:
                      'Coach: ${s.aClass.coach.firstName} ${s.aClass.coach.lastName}',
                  fontSize: 14,
                  fontColor: Colors.white70,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pendingPaymentsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<int>(
                  value: selectedPendingClass?.id,
                  hint: Components.reusableText(
                    content: 'Select Class',
                    fontColor: Colors.white70,
                  ),
                  dropdownColor: Colors.black54,
                  isExpanded: true,
                  items: manager.allClasses.items.map((c) {
                    return DropdownMenuItem<int>(
                      value: c.id,
                      child: Components.reusableText(
                        content: c.title,
                        fontColor: Colors.white70,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final cls = manager.allClasses.items.firstWhere(
                      (c) => c.id == value,
                    );
                    setState(() {
                      selectedPendingClass = cls;
                      pendingUsers.clear();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onPressed: selectedPendingClass == null
                    ? null
                    : () async {
                        await manager
                            .getPendingPaymentsByClassId(
                              selectedPendingClass!.id,
                            )
                            .then((_) {
                              setState(() {
                                pendingUsers = manager.expiredSubscriptions;
                              });
                            });
                      },
                child: const Text(
                  'Load',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: pendingUsers.isEmpty
                ? const Center(
                    child: Text(
                      'No pending payments.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    itemCount: pendingUsers.length,
                    itemBuilder: (context, index) {
                      final user = pendingUsers[index];

                      return Card(
                        color: Colors.red.shade900.withAlpha(153),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Components.reusableText(
                                      content:
                                          '${user.firstName} ${user.lastName}',
                                      fontWeight: FontWeight.bold,
                                      fontColor: Colors.white,
                                    ),
                                    const SizedBox(height: 4),
                                    Components.reusableText(
                                      content: user.phoneNumber,
                                      fontColor: Colors.white70,
                                    ),
                                    const SizedBox(height: 4),
                                    Components.reusableText(
                                      content: user.email,
                                      fontColor: Colors.white70,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}