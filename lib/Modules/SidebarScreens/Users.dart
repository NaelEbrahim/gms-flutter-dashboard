import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Models/UserModel.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  int _pageIndex = 0;
  String _roleFilter = 'All';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _filteredUsers(GetUsersModel users) {
    final search = _searchController.text.toLowerCase();
    return users.items.where((user) {
      final matchesSearch =
          search.isEmpty ||
          user.firstName.toLowerCase().contains(search) ||
          user.lastName.toLowerCase().contains(search) ||
          user.email.toLowerCase().contains(search);
      return matchesSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    Manager.get(context).getUsers(_roleFilter, _pageIndex);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Manager.get(context);
    final sidebarWidth = Constant.screenWidth / 5;
    const horizontalPadding = 20.0;

    return BlocConsumer<Manager, BlocStates>(
      listener: (_, _) {},
      builder: (context, state) {
        final displayedUsers = _filteredUsers(manager.users);
        return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Components.reusableText(
                content: 'Users',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontColor: Colors.teal,
              ),
              const SizedBox(height: 16),
              _buildRoleTabs(manager),
              const SizedBox(height: 16),
              _buildSearchBar(manager, displayedUsers),
              const SizedBox(height: 24),
              ConditionalBuilder(
                condition: state is! LoadingState,
                builder: (context) => Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth:
                            Constant.screenWidth -
                            sidebarWidth -
                            horizontalPadding,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            Colors.grey[800],
                          ),
                          dataRowColor: WidgetStateProperty.all(
                            Colors.grey[850],
                          ),
                          headingTextStyle: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                          dataTextStyle: const TextStyle(color: Colors.white),
                          columns: const [
                            DataColumn(
                              label: Text('First Name'),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Text('Last Name'),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Text('Phone'),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Text('Email'),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Text('Gender'),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Text('Actions'),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                          ],
                          rows: displayedUsers.map((user) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Center(
                                    child: Text(
                                      user.firstName,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      user.lastName,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      user.phoneNumber,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      user.email,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      user.gender,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () => showUserFormDialog(
                                          context,
                                          manager,
                                          user: user,
                                        ),
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.teal,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                fallback: (_) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleTabs(Manager manager) {
    final roles = ['All', 'Admin', 'Secretary', 'Coach', 'User'];
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: roles.map((role) {
          final active = _roleFilter == role;
          return InkWell(
            onTap: () {
              setState(() => _roleFilter = role);
              _pageIndex = 0;
              manager.getUsers(role, _pageIndex);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? Colors.teal : Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Components.reusableText(
                content: role,
                fontColor: active ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar(Manager manager, List<UserModel> displayedUsers) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Components.reusableTextFormField(
            hint: 'Search by name or email',
            prefixIcon: Icons.search,
            controller: _searchController,
            validator: (_) => null,
          ),
        ),
        const SizedBox(width: 12),
        Components.reusablePagination(
          totalPages: manager.users.totalPages,
          currentPage: manager.users.currentPage,
          onPageChanged: (pageIndex) {
            _pageIndex = pageIndex;
            manager.getUsers(_roleFilter, pageIndex);
          },
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => showUserFormDialog(context, manager),
          icon: const Icon(Icons.person_add),
          label: const Text('Create User'),
        ),
        const SizedBox(width: 16),
        Components.reusableText(
          content: 'Total Users: ${displayedUsers.length}',
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  void showUserFormDialog(
    BuildContext mainContext,
    Manager manager, {
    UserModel? user,
  }) {
    final isEdit = user != null;
    final firstName = TextEditingController(text: user?.firstName ?? '');
    final lastName = TextEditingController(text: user?.lastName ?? '');
    final email = TextEditingController(text: user?.email ?? '');
    final phone = TextEditingController(text: user?.phoneNumber ?? '');
    final dob = TextEditingController(text: user?.dob ?? '');
    final gender = TextEditingController(text: user?.gender ?? 'Male');
    final List<String> availableRoles = ['Admin', 'Secretary', 'Coach', 'User'];
    List<String> selectedRoles = isEdit ? [] : [];

    showDialog(
      context: mainContext,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Components.reusableText(
            content: isEdit ? 'Edit User' : 'Create User',
            fontColor: Colors.teal,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          content: SizedBox(
            width: 350,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Components.reusableTextFormField(
                      hint: 'First Name',
                      prefixIcon: Icons.person,
                      controller: firstName,
                    ),
                    const SizedBox(height: 10),
                    Components.reusableTextFormField(
                      hint: 'Last Name',
                      prefixIcon: Icons.badge_outlined,
                      controller: lastName,
                    ),
                    const SizedBox(height: 10),
                    Components.reusableTextFormField(
                      hint: 'Email',
                      prefixIcon: Icons.email_outlined,
                      controller: email,
                    ),
                    const SizedBox(height: 10),
                    Components.reusableTextFormField(
                      hint: 'Phone Number',
                      prefixIcon: Icons.phone,
                      controller: phone,
                    ),
                    const SizedBox(height: 10),
                    Components.reusableTextFormField(
                      hint: 'Date of Birth',
                      prefixIcon: Icons.date_range,
                      controller: dob,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: isEdit
                              ? DateTime.parse(user.dob)
                              : DateTime.now(),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          dob.text = picked.toIso8601String().split('T').first;
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Components.reusableTextFormField(
                      hint: 'Gender',
                      prefixIcon: Icons.male,
                      controller: gender,
                      readOnly: true,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: Colors.grey[900],
                            content: DropdownButton<String>(
                              value: gender.text,
                              dropdownColor: Colors.grey[900],
                              style: const TextStyle(color: Colors.white),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Male',
                                  child: Text('Male'),
                                ),
                                DropdownMenuItem(
                                  value: 'Female',
                                  child: Text('Female'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => gender.text = value!);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    if (!isEdit) ...[
                      const SizedBox(height: 12),
                      Components.reusableText(
                        content: 'Roles',
                        fontColor: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 8),
                      ...availableRoles.map(
                        (role) => CheckboxListTile(
                          value: selectedRoles.contains(role),
                          onChanged: (checked) {
                            setState(() {
                              checked == true
                                  ? selectedRoles.add(role)
                                  : selectedRoles.remove(role);
                            });
                          },
                          title: Text(
                            role,
                            style: const TextStyle(color: Colors.white),
                          ),
                          activeColor: Colors.teal,
                          checkColor: Colors.black,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              child: Text(isEdit ? 'Save' : 'Create'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (isEdit) {
                    manager.updateUser(
                      {
                        'firstName': firstName.text,
                        'lastName': lastName.text,
                        'email': email.text,
                        'phoneNumber': phone.text,
                        'gender': gender.text,
                        'dob': dob.text,
                      },
                      user.id,
                      _roleFilter,
                      _pageIndex,
                    );
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                    final password = await manager.createUser({
                      'firstName': firstName.text,
                      'lastName': lastName.text,
                      'email': email.text,
                      'phoneNumber': phone.text,
                      'gender': gender.text,
                      'dob': dob.text,
                      'roles': selectedRoles,
                    });
                    if (password != '-') {
                      _showPasswordDialog(mainContext, password);
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordDialog(BuildContext context, String password) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Components.reusableText(
          content: 'User Created',
          fontColor: Colors.teal,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Components.reusableText(
              content: 'Generated Password:',
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Components.reusableText(content: password, fontSize: 18),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: password));
                    Components.showSnackBar(
                      context,
                      'Password copied',
                      color: Colors.green,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Components.reusableText(
              content: 'Save this password. It will not be shown again.',
              fontColor: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
