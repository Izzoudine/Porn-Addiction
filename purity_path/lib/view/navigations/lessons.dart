import 'package:flutter/material.dart';
import 'package:purity_path/utils/consts.dart'; // Adjust import based on your project structure
import 'package:purity_path/data/models/daily_model.dart'; // Adjust import for DailyContent model
import 'package:purity_path/view/navigations/dailies_manager.dart'; // Adjust import for DailiesManager

class Lessons extends StatefulWidget {
  const Lessons({super.key});

  @override
  State<Lessons> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<Lessons>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  Map<String, List<DailyContent>> _dailies = {};
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDailies();
  }

  Future<void> _loadDailies() async {
    setState(() {
      _isLoading = true;
    });
    
    // Try to get data synchronously first
    _dailies = DailiesManager.getAllDailiesSync();
    
    // If empty, load from SharedPreferences
    if (_dailies.isEmpty) {
      await DailiesManager.loadDailies();
      _dailies = DailiesManager.getAllDailiesSync();
    }
    
    setState(() {
      _isLoading = false;
    });
    
    print('Loaded dailies: ${_dailies.keys}, duas: ${_dailies['duas']?.length ?? 0}, hadiths: ${_dailies['hadiths']?.length ?? 0}, motivations: ${_dailies['motivations']?.length ?? 0}');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final Map<String, Map<String, Color>> sectionColors = {
    'duas': {'bg': Colors.teal.shade50, 'accent': Colors.teal},
    'hadiths': {'bg': Colors.blue.shade50, 'accent': Colors.blue},
    'motivations': {'bg': Colors.green.shade50, 'accent': Colors.green},
  };

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(AppColors.primary),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Loading lessons...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              )
            : _dailies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No lessons available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Please check your internet connection\nand restart the app',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadDailies,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(AppColors.primary),
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                          ),
                          child: Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lessons',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(AppColors.primary),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Text(
                              'Islamic guidance for your journey',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(AppColors.primary),
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                          ),
                          child: SizedBox(
                            height: 50,
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Color(AppColors.primary),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(AppColors.primary)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.grey.shade800,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              dividerColor: Colors.transparent,
                              isScrollable: false,
                              indicatorSize: TabBarIndicatorSize.tab,
                              tabs: [
                                SizedBox(
                                  width: double.infinity,
                                  child: const Center(child: Text('Duas')),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: const Center(child: Text('Hadiths')),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: const Center(
                                    child: Text(
                                      'Motivations',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildTabContent('duas'),
                            _buildTabContent('hadiths'),
                            _buildTabContent('motivations'),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildTabContent(String section) {
    final sectionData = _dailies[section] ?? [];
    final colors = sectionColors[section]!;

    if (sectionData.isEmpty) {
      return Center(
        child: Text(
          'No ${section} available',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: sectionData.map((daily) {
        return _buildResourceCard(
          daily,
          colors['bg']!,
          colors['accent']!,
          () => _navigateToDetailPage(context, daily, colors['accent']!),
        );
      }).toList(),
    );
  }

  Widget _buildResourceCard(
    DailyContent daily,
    Color bgColor,
    Color accentColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: accentColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      daily.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: accentColor),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                daily.content,
                style: const TextStyle(fontSize: 16, fontFamily: "CrimsonText"),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                daily.specific,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetailPage(
    BuildContext context,
    DailyContent daily,
    Color color,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage( // Adjust DetailPage based on your implementation
          title: daily.name,
          arabicText: daily.contentType == 'Dua' ? daily.content : '',
          translatedText: daily.contentType == 'Dua' ? daily.specific : daily.content,
          description: daily.description,
          category: daily.contentType,
          color: color,
        ),
      ),
    );
  }
}
class DetailPage extends StatelessWidget {
  final String title;
  final String arabicText;
  final String translatedText;
  final String description;
  final String category;
  final Color color;

  const DetailPage({
    super.key,
    required this.title,
    required this.arabicText,
    required this.translatedText,
    required this.description,
    required this.category,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        elevation: 0,
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (arabicText.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        arabicText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          height: 1.5,
                          color: color.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      translatedText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Understanding & Application',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}