import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Models/AboutUsModel.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';

class AboutTab extends StatefulWidget {
  const AboutTab({super.key});

  @override
  State<AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<AboutTab> {
  late TextEditingController name;
  late TextEditingController desc;
  late TextEditingController mission;
  late TextEditingController vision;
  late TextEditingController fb;
  late TextEditingController instagram;

  @override
  void initState() {
    super.initState();
    Manager.get(context).getAboutUs();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Manager.get(context);
    return BlocConsumer<Manager, BlocStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ConditionalBuilder(
            condition: state is! LoadingState,
            builder: (context) {
              if (state is SuccessState) {
                final g = manager.gymInfo as AboutUsModel;
                name = TextEditingController(text: g.gymName);
                desc = TextEditingController(text: g.gymDescription);
                mission = TextEditingController(text: g.ourMission);
                vision = TextEditingController(text: g.ourVision);
                fb = TextEditingController(text: g.facebookLink);
                instagram = TextEditingController(text: g.instagramLink);
              }
              return ListView(
                children: [
                  const SizedBox(height: 12),
                  _field('Gym Name', name, icon: Icons.fitness_center),
                  _field('Description', desc, max: 3, icon: Icons.description),
                  _field('Mission', mission, max: 2, icon: Icons.flag),
                  _field('Vision', vision, max: 2, icon: Icons.remove_red_eye),
                  _field('Facebook', fb, icon: Icons.facebook),
                  _field('Instagram', instagram, icon: Icons.camera_alt),
                  const SizedBox(height: 24),
                  ConditionalBuilder(
                    condition: state is! LoadingState,
                    builder: (context) => Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 60,
                        width: Constant.screenWidth / 5,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            manager.updateAboutUs({
                              'gymName': name.text,
                              'gymDescription': desc.text,
                              'ourMission': mission.text,
                              'ourVision': vision.text,
                              'facebookLink': fb.text,
                              'instagramLink': instagram.text,
                            });
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    fallback: (context) =>
                        Center(child: const CircularProgressIndicator()),
                  ),
                ],
              );
            },
            fallback: (context) =>
                Center(child: const CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Widget _field(
    String hint,
    TextEditingController controller, {
    int max = 1,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Components.reusableTextFormField(
        hint: hint,
        prefixIcon: icon,
        controller: controller,
        maxLines: max,
        fontColor: Colors.white,
        focusedColor: Colors.teal,
        fillColor: Colors.black54,
        hintColor: Colors.white54,
      ),
    );
  }
}
