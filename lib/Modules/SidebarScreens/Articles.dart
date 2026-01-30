import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Models/ArticleModel.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';

class Articles extends StatefulWidget {
  const Articles({super.key});

  @override
  State<Articles> createState() => _ArticlesState();
}

class _ArticlesState extends State<Articles> {
  int _pageIndex = 0;
  String _typeFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  List<ArticleModel> _filteredArticles(GetArticlesModel articles) {
    final search = _searchController.text.toLowerCase();
    return articles.items.where((article) {
      final matchesSearch =
          search.isEmpty || article.title.toLowerCase().contains(search);
      final matchesType =
          _typeFilter == 'All' || article.wikiType == _typeFilter;
      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    final manager = Manager.get(context);
    manager.getArticles(_pageIndex, _typeFilter);
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

    return BlocConsumer<Manager, BlocStates>(
      listener: (_, _) {},
      builder: (context, state) {
        final displayedArticles = _filteredArticles(manager.articles);

        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Components.reusableText(
                content: 'Articles',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontColor: Colors.teal,
              ),
              const SizedBox(height: 16),
              _buildTypeTabs(manager),
              const SizedBox(height: 16),
              _buildSearchBar(manager, displayedArticles),
              const SizedBox(height: 24),
              ConditionalBuilder(
                condition: state is! LoadingState,
                builder: (_) => Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: Constant.screenWidth - sidebarWidth - 20,
                      ),
                      child: SingleChildScrollView(
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
                              label: Center(child: Text('Title')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Wiki Type')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Min Read')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Author')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Actions')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                          ],
                          rows: displayedArticles.map((a) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Center(
                                    child: Text(
                                      a.title.length > 30
                                          ? '${a.title.substring(0, 30)}...'
                                          : a.title,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                                DataCell(Center(child: Text(a.wikiType))),
                                DataCell(
                                  Center(child: Text('${a.minReadTime} min')),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      '${a.admin.firstName} ${a.admin.lastName}',
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.teal,
                                          ),
                                          onPressed: () => _showArticleDialog(
                                            context,
                                            manager,
                                            a,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            // TODO : implement Delete
                                          },
                                        ),
                                      ],
                                    ),
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

  Widget _buildTypeTabs(Manager manager) {
    final types = ['All', 'Supplements', 'Health', 'Fitness'];
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: types.map((type) {
          final active = _typeFilter == type;
          return InkWell(
            onTap: () {
              setState(() => _typeFilter = type);
              _pageIndex = 0;
              manager.getArticles(_pageIndex, _typeFilter);
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
                content: type,
                fontColor: active ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar(
    Manager manager,
    List<ArticleModel> displayedArticles,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: Components.reusableTextFormField(
            hint: 'Search by title',
            validator: (_) => null,
            prefixIcon: Icons.search,
            controller: _searchController,
          ),
        ),
        const SizedBox(width: 16),
        Components.reusablePagination(
          totalPages: manager.articles.totalPages,
          currentPage: manager.articles.currentPage,
          onPageChanged: (pageIndex) {
            _pageIndex = pageIndex;
            manager.getArticles(_pageIndex, _typeFilter);
          },
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () => _showArticleDialog(context, manager),
          child: const Text('Create Article'),
        ),
        const SizedBox(width: 16),
        Components.reusableText(
          content: 'Total Articles: ${displayedArticles.length}',
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  void _showArticleDialog(
    BuildContext context,
    Manager manager, [
    ArticleModel? article,
  ]) {
    final isEdit = article != null;

    final titleCtrl = TextEditingController(text: article?.title ?? '');
    final contentCtrl = TextEditingController(text: article?.content ?? '');

    final List<String> wikiTypes = [
      'Health',
      'Sport',
      'Food',
      'Fitness',
      'Supplements',
    ];

    String? selectedWikiType = article?.wikiType;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Components.reusableText(
            content: isEdit ? 'Edit Article' : 'Create Article',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontColor: Colors.teal,
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Components.reusableTextFormField(
                    hint: 'Title',
                    prefixIcon: Icons.title,
                    controller: titleCtrl,
                  ),
                  const SizedBox(height: 10),
                  Components.reusableTextFormField(
                    hint: 'Content',
                    prefixIcon: Icons.description,
                    controller: contentCtrl,
                    maxLines: 6,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedWikiType,
                    dropdownColor: Colors.grey[900],
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.info, color: Colors.grey),
                      label: Text(
                        'Wiki Type',
                        style: TextStyle(color: Colors.white),
                      ),
                      fillColor: Colors.black54,
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                    items: wikiTypes
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedWikiType = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty ||
                    contentCtrl.text.isEmpty ||
                    selectedWikiType == null) {
                  return;
                }
                final data = {
                  'title': titleCtrl.text,
                  'content': contentCtrl.text,
                  'wikiType': selectedWikiType,
                };
                if (isEdit) {
                  manager.updateArticle(data, article.id, _pageIndex,_typeFilter);
                } else {
                  manager.createArticle(data);
                }
                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}
