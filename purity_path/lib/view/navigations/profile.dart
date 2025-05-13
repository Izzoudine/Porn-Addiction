import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isGuest = true;
  String _userName = "Invité";
  String _userEmail = "";
  int _cleanDays = 0;
  int _totalRelapses = 0;
  DateTime? _lastRelapseDate;
  DateTime? _accountCreationDate;
  bool _hasStartedJourney = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    
    // Simuler la récupération des données utilisateur
    // Dans une vraie application, ces données viendraient d'une base de données ou d'une API
    final isGuest = prefs.getBool('isGuest') ?? true;
    final userName = prefs.getString('userName') ?? "Invité";
    final userEmail = prefs.getString('userEmail') ?? "";
    final totalRelapses = prefs.getInt('totalRelapses') ?? 0;
    final accountCreationDateStr = prefs.getString('accountCreationDate');
    final hasStartedJourney = prefs.getBool('hasStartedJourney') ?? false;
    
    // Récupérer la date du dernier relapse pour calculer les jours propres
    final lastRelapseStr = prefs.getString('lastRelapse');
    DateTime? lastRelapseDate;
    int cleanDays = 0;
    
    if (lastRelapseStr != null && hasStartedJourney) {
      lastRelapseDate = DateTime.parse(lastRelapseStr);
      final now = DateTime.now();
      cleanDays = now.difference(lastRelapseDate).inDays;
    }
    
    // Récupérer ou définir la date de création du compte
    DateTime accountCreationDate;
    if (accountCreationDateStr != null) {
      accountCreationDate = DateTime.parse(accountCreationDateStr);
    } else {
      accountCreationDate = DateTime.now();
      await prefs.setString('accountCreationDate', accountCreationDate.toIso8601String());
    }

    setState(() {
      _isGuest = isGuest;
      _userName = userName;
      _userEmail = userEmail;
      _cleanDays = cleanDays;
      _totalRelapses = totalRelapses;
      _lastRelapseDate = lastRelapseDate;
      _accountCreationDate = accountCreationDate;
      _hasStartedJourney = hasStartedJourney;
      _isLoading = false;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    // Utiliser le format de date sans spécifier de locale
    return DateFormat('dd MMMM yyyy').format(date);
  }

  void _showConnectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Se connecter",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3),
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Connectez-vous pour sauvegarder votre progression et accéder à toutes les fonctionnalités.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                "Cette fonctionnalité sera disponible prochainement.",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Fermer",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Ici, vous pourriez naviguer vers la page de connexion
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Continuer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2196F3),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF2196F3),
        ),
           ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // En-tête du profil
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar et badge invité
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            // Avatar
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3).withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF2196F3),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _userName.isNotEmpty ? _userName[0].toUpperCase() : "?",
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2196F3),
                                  ),
                                ),
                              ),
                            ),
                            // Badge invité
                            if (_isGuest)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  "INVITÉ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Nom d'utilisateur
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        if (_userEmail.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _userEmail,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        // Bouton de connexion pour les invités
                        if (_isGuest)
                          ElevatedButton.icon(
                            onPressed: _showConnectDialog,
                            icon: const Icon(Icons.login),
                            label: const Text("Se connecter"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                
                  const SizedBox(height: 20),
                  
                  // Options du profil
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.settings,
                          size: 20,
                          color: Color(0xFF2196F3),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Options',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Liste des options
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                                    _buildOptionItem(
                          icon: Icons.notifications_outlined,
                          title: "Notifications",
                          onTap: () {
                            // Action pour les notifications
                          },
                        ),
                        const Divider(height: 1),
                        _buildOptionItem(
                          icon: Icons.language_outlined,
                          title: "Langue",
                          subtitle: "Français",
                          onTap: () {
                            // Action pour changer la langue
                          },
                        ),
                        const Divider(height: 1),
                        _buildOptionItem(
                          icon: Icons.help_outline,
                          title: "Aide et support",
                          onTap: () {
                            // Action pour l'aide
                          },
                        ),
                        const Divider(height: 1),
                        _buildOptionItem(
                          icon: Icons.info_outline,
                          title: "À propos",
                          onTap: () {
                            // Action pour à propos
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Bouton de déconnexion
                  if (!_isGuest)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Action pour se déconnecter
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text("Se déconnecter"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          minimumSize: const Size(double.infinity, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2196F3),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2196F3),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}