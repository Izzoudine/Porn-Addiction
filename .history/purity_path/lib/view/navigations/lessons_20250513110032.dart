import 'package:flutter/material.dart';
import 'package:purity_path/utils/consts.dart';

class Lessons extends StatefulWidget {
  const Lessons({Key? key}) : super(key: key);

  @override
  State<Lessons> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<Lessons> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec sous-titre
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
                  // Sous-titre ajouté sous "Lessons"
                  const Text(
                    'Islamic guidance for your journey',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(AppColors.primary),

                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 15),
            
       // Solution 1: Using Container with fixed tab sizes
Container(
  margin: const EdgeInsets.symmetric(horizontal: 20),
  child: Theme(
    data: Theme.of(context).copyWith(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
    ),
    child: Container(
      height: 50, // Fixed height for tabs
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.teal.shade600,
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
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
        isScrollable: false, // This distributes tabs evenly
        indicatorSize: TabBarIndicatorSize.tab, // Makes indicator match tab size
        tabs: [
          Container(
            width: double.infinity,
            child: const Center(child: Text('Duas')),
          ),
          Container(
            width: double.infinity,
            child: const Center(child: Text('Hadiths')),
          ),
          Container(
            width: double.infinity,
            child: const Center(child: Text('Motivations',style:TextStyle(fontSize: 14))),
          ),
        ],
      ),
    ),
  ),
)
  ,const SizedBox(height: 20),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Duas Tab
                  ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 15), // Réduit les marges horizontales pour des cartes plus larges
                    children: [
                      _buildResourceCard(
                        'Dua for Strength',
                        'اللَّهُمَّ إِنِّي أَسْأَلُكَ الثَّبَاتَ فِي الْأَمْرِ، وَالْعَزِيمَةَ عَلَى الرُّشْدِ',
                        'O Allah, I ask You for firmness in the matter and determination upon guidance.',
                        Colors.teal.shade50,
                        Colors.teal,
                        () => _navigateToDetailPage(
                          context, 
                          'Dua for Strength',
                          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الثَّبَاتَ فِي الْأَمْرِ، وَالْعَزِيمَةَ عَلَى الرُّشْدِ',
                          'O Allah, I ask You for firmness in the matter and determination upon guidance.',
                          'This dua is particularly beneficial when you are facing temptations. It asks Allah for firmness in your affairs and determination to stay on the right path. Recite it when you feel your resolve weakening.',
                          'Duas',
                          Colors.teal,
                        ),
                      ),
                      _buildResourceCard(
                        'Dua for Protection',
                        'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
                        'O Allah, suffice me with what You have allowed instead of what You have forbidden, and make me independent of all others besides You.',
                        Colors.blue.shade50,
                        Colors.blue,
                        () => _navigateToDetailPage(
                          context, 
                          'Dua for Protection',
                          'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
                          'O Allah, suffice me with what You have allowed instead of what You have forbidden, and make me independent of all others besides You.',
                          'This powerful dua asks Allah to make the halal (permissible) things sufficient for you so that you avoid the haram (forbidden). It\'s especially helpful when struggling with addictive behaviors.',
                          'Duas',
                          Colors.blue,
                        ),
                      ),
                      _buildResourceCard(
                        'Dua for Forgiveness',
                        'رَبِّ اغْفِرْ لِي خَطِيئَتِي وَجَهْلِي، وَإِسْرَافِي فِي أَمْرِي كُلِّهِ، وَمَا أَنْتَ أَعْلَمُ بِهِ مِنِّي',
                        'O my Lord! Forgive my sins, my ignorance, my immoderation in my affairs, and all that You know better than I do.',
                        Colors.purple.shade50,
                        Colors.purple,
                        () => _navigateToDetailPage(
                          context, 
                          'Dua for Forgiveness',
                          'رَبِّ اغْفِرْ لِي خَطِيئَتِي وَجَهْلِي، وَإِسْرَافِي فِي أَمْرِي كُلِّهِ، وَمَا أَنْتَ أَعْلَمُ بِهِ مِنِّي',
                          'O my Lord! Forgive my sins, my ignorance, my immoderation in my affairs, and all that You know better than I do.',
                          'This comprehensive dua for forgiveness acknowledges our human weaknesses and asks Allah to forgive all our shortcomings. It\'s particularly beneficial after a relapse to help you get back on track.',
                          'Duas',
                          Colors.purple,
                        ),
                      ),
                      _buildResourceCard(
                        'Dua for Guidance',
                        'اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ، وَعَافِنِي فِيمَنْ عَافَيْتَ، وَتَوَلَّنِي فِيمَنْ تَوَلَّيْتَ',
                        'O Allah, guide me among those whom You have guided, pardon me among those You have pardoned, turn to me in friendship among those on whom You have turned in friendship.',
                        Colors.amber.shade50,
                        Colors.amber,
                        () => _navigateToDetailPage(
                          context, 
                          'Dua for Guidance',
                          'اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ، وَعَافِنِي فِيمَنْ عَافَيْتَ، وَتَوَلَّنِي فِيمَنْ تَوَلَّيْتَ',
                          'O Allah, guide me among those whom You have guided, pardon me among those You have pardoned, turn to me in friendship among those on whom You have turned in friendship.',
                          'This beautiful dua, known as Dua al-Qunoot, asks Allah for guidance, pardon, and friendship. Recite it regularly to strengthen your connection with Allah and seek His continuous guidance.',
                          'Duas',
                          Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  
                  // Hadiths Tab
                  ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 15), // Réduit les marges horizontales pour des cartes plus larges
                    children: [
                      _buildResourceCard(
                        'On Lowering the Gaze',
                        'The Prophet ﷺ said: "Do not follow a glance with another, for you will be forgiven for the first, but not for the second."',
                        'Reported by Ahmad, Abu Dawud and At-Tirmidhi',
                        Colors.green.shade50,
                        Colors.green,
                        () => _navigateToDetailPage(
                          context, 
                          'On Lowering the Gaze',
                          '',
                          'The Prophet ﷺ said: "Do not follow a glance with another, for you will be forgiven for the first, but not for the second."',
                          'This hadith teaches us about the importance of controlling our gaze. The first accidental glance at something inappropriate may be forgiven, but deliberately looking again is sinful. This hadith is particularly relevant for overcoming visual temptations that often lead to pornography addiction.',
                          'Hadiths',
                          Colors.green,
                        ),
                      ),
                      _buildResourceCard(
                        'On Purity',
                        'The Prophet ﷺ said: "Verily, Allah is pure and loves purity."',
                        'Sahih Muslim',
                        Colors.teal.shade50,
                        Colors.teal,
                        () => _navigateToDetailPage(
                          context, 
                          'On Purity',
                          '',
                          'The Prophet ﷺ said: "Verily, Allah is pure and loves purity."',
                          'This hadith reminds us that Allah loves purity in all its forms - physical, mental, and spiritual. By striving for purity in our thoughts and actions, we align ourselves with what Allah loves. This can be a powerful motivation in your journey to overcome addiction.',
                          'Hadiths',
                          Colors.teal,
                        ),
                      ),
                      _buildResourceCard(
                        'On Self-Control',
                        'The Prophet ﷺ said: "The strong person is not the one who can wrestle someone else down. The strong person is the one who can control himself when he is angry."',
                        'Sahih Al-Bukhari',
                        Colors.blue.shade50,
                        Colors.blue,
                        () => _navigateToDetailPage(
                          context, 
                          'On Self-Control',
                          '',
                          'The Prophet ﷺ said: "The strong person is not the one who can wrestle someone else down. The strong person is the one who can control himself when he is angry."',
                          'This hadith redefines strength as self-control rather than physical power. It teaches us that true strength lies in controlling our desires and emotions, not in giving in to them. Apply this wisdom to your struggle with addiction by recognizing that resisting urges is a sign of true strength.',
                          'Hadiths',
                          Colors.blue,
                        ),
                      ),
                      _buildResourceCard(
                        'On Repentance',
                        'The Prophet ﷺ said: "One who repents from sin is like one who has not sinned."',
                        'Ibn Majah',
                        Colors.purple.shade50,
                        Colors.purple,
                        () => _navigateToDetailPage(
                          context, 
                          'On Repentance',
                          '',
                          'The Prophet ﷺ said: "One who repents from sin is like one who has not sinned."',
                          'This beautiful hadith gives us hope by teaching that sincere repentance wipes away sins as if they never happened. No matter how many times you may have relapsed, sincere repentance gives you a fresh start. Allah\'s mercy is greater than any sin.',
                          'Hadiths',
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  
                  // Motivations Tab
                  ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 15), // Réduit les marges horizontales pour des cartes plus larges
                    children: [
                      _buildResourceCard(
                        'The Neuroscience of Addiction',
                        'Learn how pornography affects your brain chemistry and creates addictive patterns.',
                        'Tap to read more',
                        Colors.orange.shade50,
                        Colors.orange,
                        () => _navigateToDetailPage(
                          context, 
                          'The Neuroscience of Addiction',
                          '',
                          'How Pornography Affects Your Brain',
                          'Pornography addiction works similarly to substance addiction in the brain. When you view pornography, your brain releases dopamine, creating feelings of pleasure. With repeated exposure, your brain requires more explicit content to achieve the same dopamine release, leading to escalation.\n\nThis creates neural pathways that strengthen with each viewing, making the habit more difficult to break. However, the brain has "neuroplasticity" - the ability to form new neural connections. By abstaining from pornography, these pathways begin to weaken, while new, healthier pathways strengthen through positive activities.\n\nUnderstanding this process can help you recognize that your struggle is not a moral failing but a neurological challenge that can be overcome with time and consistent effort.',
                          'Motivations',
                          Colors.orange,
                        ),
                      ),
                      _buildResourceCard(
                        'Islamic Perspective on Addiction',
                        'Understanding addiction through the lens of Islamic teachings and principles.',
                        'Tap to read more',
                        Colors.teal.shade50,
                        Colors.teal,
                        () => _navigateToDetailPage(
                          context, 
                          'Islamic Perspective on Addiction',
                          '',
                          'Understanding Addiction Through Islamic Teachings',
                          'Islam recognizes human weakness and the potential for addiction, but also provides a framework for overcoming it. The Quran states: "Allah does not burden a soul beyond what it can bear" (2:286), reminding us that every challenge we face is within our capacity to overcome.\n\nAddiction is often related to the concept of "nafs" (lower self) that commands to evil (Quran 12:53). Through spiritual discipline, one can progress to the "nafs al-lawwamah" (the self-reproaching soul) and eventually to "nafs al-mutma\'innah" (the soul at peace).\n\nIslamic principles that help overcome addiction include: regular prayer (salah) which provides structure and mindfulness, fasting (sawm) which builds self-control, remembrance of Allah (dhikr) which provides spiritual strength, and community support (ummah) which provides accountability and encouragement.',
                          'Motivations',
                          Colors.teal,
                        ),
                      ),
                      _buildResourceCard(
                        'Practical Steps to Break Free',
                        'A comprehensive guide with actionable steps to overcome pornography addiction.',
                        'Tap to read more',
                        Colors.blue.shade50,
                        Colors.blue,
                        () => _navigateToDetailPage(
                          context, 
                          'Practical Steps to Break Free',
                          '',
                          'Actionable Steps to Overcome Addiction',
                          '1. Install blocking software on all your devices to prevent access to inappropriate content.\n\n2. Identify your triggers (boredom, stress, loneliness) and develop specific strategies for each one.\n\n3. Replace the habit with healthy alternatives: exercise, reading, social activities, or creative pursuits.\n\n4. Practice mindfulness and meditation to become more aware of your thoughts and urges without acting on them.\n\n5. Maintain a journal to track your progress, identify patterns, and celebrate victories.\n\n6. Establish accountability with a trusted friend or mentor who can support your journey.\n\n7. Create a "emergency plan" for moments of strong temptation: specific actions to take, people to call, or places to go.\n\n8. Be patient with yourself and recognize that recovery is a process with ups and downs.',
                          'Motivations',
                          Colors.blue,
                        ),
                      ),
                      _buildResourceCard(
                        'Success Stories',
                        'Read inspiring stories from people who have successfully overcome their addiction.',
                        'Tap to read more',
                        Colors.green.shade50,
                        Colors.green,
                        () => _navigateToDetailPage(
                          context, 
                          'Success Stories',
                          '',
                          'Stories of Hope and Recovery',
                          'Ahmad\'s Story: "After struggling with pornography addiction for 7 years, I finally broke free by combining spiritual practice with practical strategies. The first month was the hardest, but it gets easier. Now, 3 years clean, my relationships are healthier and my faith stronger than ever."\n\nYusuf\'s Story: "I relapsed countless times before finally succeeding. The key was not giving up after failures but learning from them. Each attempt taught me something new about my triggers and weaknesses. Now 18 months clean, I can say the struggle was worth it."\n\nIbrahim\'s Story: "What worked for me was completely restructuring my daily routine. I started praying all five prayers at the mosque, exercising daily, and learning a new language to keep busy. These positive habits gradually replaced the negative ones, and after 6 months, the urges became manageable."',
                          'Motivations',
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResourceCard(String title, String content, String subtitle, Color bgColor, Color accentColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // Assure que la carte prend toute la largeur disponible
        margin: const EdgeInsets.only(bottom: 20), // Augmenté pour plus d'espace entre les cartes
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
              spreadRadius: 2, // Augmenté pour une ombre plus visible
              blurRadius: 8, // Augmenté pour une ombre plus douce
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: accentColor.withOpacity(0.3),
            width: 1.5, // Bordure plus épaisse
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22), // Padding augmenté pour des cartes plus grandes
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                      textAlign: TextAlign.center, // Texte centré
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: accentColor,
                  ),
                ],
              ),
              const SizedBox(height: 12), // Espace augmenté
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: "CrimsonText"
                ),
                textAlign: TextAlign.center, // Texte centré
              ),
              const SizedBox(height: 8), // Espace augmenté
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center, // Texte centré
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _navigateToDetailPage(
    BuildContext context, 
    String title, 
    String arabicText, 
    String translatedText, 
    String description,
    String category,
    Color color,
  ) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => DetailPage(
          title: title,
          arabicText: arabicText,
          translatedText: translatedText,
          description: description,
          category: category,
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
    Key? key,
    required this.title,
    required this.arabicText,
    required this.translatedText,
    required this.description,
    required this.category,
    required this.color,
  }) : super(key: key);

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
            // Header section with gradient
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
                crossAxisAlignment: CrossAxisAlignment.center, // Centré
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
                      textAlign: TextAlign.center, // Texte centré
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
                    textAlign: TextAlign.center, // Texte centré
                  ),
                ],
              ),
            ),
            
            // Content section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Centré
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
                      textAlign: TextAlign.center, // Texte centré
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  const Text(
                    'Understanding & Application',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center, // Texte centré
                  ),
                  const SizedBox(height: 15),
                  
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center, // Texte centré
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Bouton "Save to Favorites" supprimé comme demandé
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}