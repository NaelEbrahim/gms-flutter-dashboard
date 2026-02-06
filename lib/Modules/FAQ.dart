import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Models/FAQModel.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';

class FaqTab extends StatefulWidget {
  const FaqTab({super.key});

  @override
  State<FaqTab> createState() => _FaqTabState();
}

class _FaqTabState extends State<FaqTab> {
  @override
  void initState() {
    super.initState();
    Manager.get(context).getFaqs();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Manager.get(context);

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              onPressed: () => _faqDialog(context, manager),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add FAQ',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        Expanded(
          child: BlocConsumer<Manager, BlocStates>(
            listener: (context, state) {},
            builder: (context, state) {
              return ConditionalBuilder(
                condition: state is! LoadingState,
                builder: (context) {
                  if (manager.faqs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No FAQs found',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: manager.faqs.length,
                    itemBuilder: (_, i) {
                      final faq = manager.faqs[i];
                      return Card(
                        color: Colors.grey[850],
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            faq.question,
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              faq.answer,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.teal,
                                ),
                                onPressed: () => _faqDialog(
                                  context,
                                  manager,
                                  faq,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  Components.deleteDialog<Manager>(
                                    context,
                                    () async {
                                      manager.deleteFaq(faq.id);
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                fallback: (context) =>
                    Center(child: const CircularProgressIndicator()),
              );
            },
          ),
        ),
      ],
    );
  }

  void _faqDialog(BuildContext context, Manager manager, [FAQModel? faq]) {
    final qController = TextEditingController(text: faq?.question ?? '');
    final aController = TextEditingController(text: faq?.answer ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          faq == null ? 'Add FAQ' : 'Edit FAQ',
          style: const TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Components.reusableTextFormField(
                hint: 'Question',
                prefixIcon: Icons.help_outline,
                controller: qController,
                fontColor: Colors.white,
                focusedColor: Colors.teal,
                fillColor: Colors.black54,
                hintColor: Colors.white54,
              ),
              const SizedBox(height: 12),
              Components.reusableTextFormField(
                hint: 'Answer',
                prefixIcon: Icons.reply,
                controller: aController,
                fontColor: Colors.white,
                focusedColor: Colors.teal,
                fillColor: Colors.black54,
                hintColor: Colors.white54,
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(
            width: 150,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                if (faq == null) {
                  manager.createFaq({
                    'question': qController.text,
                    'answer': aController.text,
                  });
                } else {
                  manager.updateFaq({
                    'question': qController.text,
                    'answer': aController.text,
                  }, faq.id);
                }
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
