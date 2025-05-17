import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purity_path/data/services/notification_service.dart';
import 'package:purity_path/utils/consts.dart';
import 'package:purity_path/utils/routes/routes_name.dart';
import '../../data/models/permission_model.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<PermissionItem> _permissions = [
    PermissionItem(
      permission: Permission.notification,
      title: 'Notification Access',
      description: 'Monitor and control notifications from other apps',
      icon: Icons.notifications_active,
      color: const Color(AppColors.primary),
    ),
    PermissionItem(
      permission: Permission.notification,
      title: 'Post Notifications',
      description: 'Allow us to send you important alerts',
      icon: Icons.message,
      color: const Color(0xFF10B981),
    ),
    PermissionItem(
      // We'll handle this permission specially
      title: 'Accessibility Service',
      description: 'Required to monitor and block inappropriate apps',
      icon: Icons.accessibility_new,
      color: const Color(0xFFEF4444),
      isAccessibility: true,
    ),
    PermissionItem(
      permission: Permission.ignoreBatteryOptimizations,
      title: 'Battery Optimization',
      description: 'Allow app to run in background for continuous protection',
      icon: Icons.battery_charging_full,
      color: const Color(0xFFF59E0B),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _checkPermissions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    for (var item in _permissions) {
      if (item.permission != null) {
        final status = await item.permission!.status;
        setState(() {
          item.status = status;
        });
      }
    }
  }

  Future<void> _requestPermission(PermissionItem item) async {
    if (item.isAccessibility) {
      // Navigate to the accessibility info page
      Navigator.pushNamed(context, RoutesName.accessibility);
      return;
    }

    if (item.permission != null) {
      final status = await item.permission!.request();
      setState(() {
        item.status = status;
      });
    }
  }

  int get _grantedPermissionsCount {
    return _permissions.where((item) => item.status?.isGranted ?? false).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Permissions',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(AppColors.primary)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildPermissionsContent(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RoutesName.navigation,
              (Route<dynamic> route) => false,
            );
            /*     final allGranted = _permissions.every(
              (item) => item.status?.isGranted ?? false || item.isAccessibility,
            );

            if (allGranted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permissions setup complete!'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            } else {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Permissions Required'),
                      content: const Text(
                        'Some permissions are still required for the app to function properly. Would you like to grant them now?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Later'),
                        ),
                        TextButton(
                          onPressed: () {
                            
                       /*     for (var item in _permissions) {
                              if (!(item.status?.isGranted ?? false) &&
                                  item.permission != null) {
                                _requestPermission(item);
                              }
                               
                              
                            }
                         
                         */ },
                          child: const Text('Grant Now'),
                        ),
                      ],
                    ),
              );
            }
            */
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppColors.primary),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
          child: const Text(
            'Complete Setup',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionsContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Required Permissions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '$_grantedPermissionsCount/${_permissions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value:
                      _permissions.isEmpty
                          ? 0
                          : _grantedPermissionsCount / _permissions.length,
                  backgroundColor: Colors.grey[200],
                  color: const Color(AppColors.primary),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),

          // Info card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(AppColors.secondary), Color(AppColors.primary)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why We Need These Permissions',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'These permissions allow us to provide the core functionality of our app and ensure it works properly.',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Permissions list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _permissions.length,
            itemBuilder: (context, index) {
              final item = _permissions[index];
              final isGranted = item.status?.isGranted ?? false;

              return GestureDetector(
                onTap: () {
                  NotificattionService.requestPermissions();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color:
                          isGranted
                              ? const Color(0xFFD1FAE5)
                              : Colors.grey.withOpacity(0.2),
                      width: isGranted ? 2 : 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => _requestPermission(item),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: item.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item.icon,
                                color: item.color,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (item.isAccessibility)
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(AppColors.secondary),
                                size: 16,
                              )
                            else
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      isGranted
                                          ? const Color(0xFF10B981)
                                          : Colors.grey[300],
                                ),
                                child: Center(
                                  child: Icon(
                                    isGranted
                                        ? Icons.check
                                        : Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: isGranted ? 16 : 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
