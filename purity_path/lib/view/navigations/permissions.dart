import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purity_path/data/services/permissions_service.dart';
import 'package:purity_path/utils/consts.dart';
import 'package:purity_path/utils/routes/routes_name.dart';
import '../../data/models/permission_model.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _errorMessage = '';
  bool _isLoading = false;
 

  final List<PermissionItem> _permissions = [
    PermissionItem(
      title: 'Notifications',
      description: 'Allows N Islam to send alerts and reminders.',
      icon: Icons.notifications_active,
      color: const Color(AppColors.primary),
      isNotifications: true,
      status: PermissionStatus.denied, // Initialize status
    ),
    PermissionItem(
      title: 'Accessibility Service',
      description: 'Required to monitor and block inappropriate apps.',
      icon: Icons.accessibility_new,
      color: const Color(0xFFEF4444),
      isAccessibility: true,
      status: PermissionStatus.denied, // Initialize status
    ),

    PermissionItem(
      title: 'Device Administrator',
      description:
          'Prevents unauthorized app removal and ensures continuous protection.',
      icon: Icons.admin_panel_settings,
      color: const Color(0xFFDC2626),
      isAdmin: true,
      status: PermissionStatus.denied, // Initialize status
    ),
    PermissionItem(
      title: 'Overlay',
      description:
          'Prevents unauthorized app removal and ensures continuous protection.',
      icon: Icons.layers,
      color: const Color(0xFFDC2626),
      isOverlay: true, // Renamed from isAdmin
      status: PermissionStatus.denied,
    ),
 
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _checkPermissions(); // Initial permission check
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissions(); // Check all permissions on resume
    }
  }

  Future<void> _refreshPermissions() async {
    await _checkPermissions();
    final accessibilityItem = _permissions.firstWhere(
      (item) => item.isAccessibility,
    );
    if (accessibilityItem.status?.isGranted == true) {}
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _checkPermissions() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      for (var item in _permissions) {
        if (item.isAccessibility) {
          final isEnabled =
              await PermissionService.isAccessibilityServiceEnabled();
          if (mounted) {
            setState(() {
              item.status =
                  isEnabled
                      ? PermissionStatus.granted
                      : PermissionStatus.denied;
            });
          }
        } else if (item.isAdmin) {
          final isEnabled =
              await PermissionService.isDeviceAdminPermissionGranted();
          if (mounted) {
            setState(() {
              item.status =
                  isEnabled
                      ? PermissionStatus.granted
                      : PermissionStatus.denied;
            });
          }
        } 
      else if (item.isNotifications) {
          final isSending =
              await PermissionService.isNotificationPermissionGranted();
          if (mounted) {
            setState(() {
              item.status =
                  isSending
                      ? PermissionStatus.granted
                      : PermissionStatus.denied;
            });
          }
        }
        else if (item.isOverlay) {
          final isSending =
              await PermissionService.isOverlayPermissionGranted();
          if (mounted) {
            setState(() {
              item.status =
                  isSending
                      ? PermissionStatus.granted
                      : PermissionStatus.denied;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error checking permissions: $e';
        });
      }
      print('Permission check error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _requestPermission(PermissionItem item) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      if (item.isAccessibility) {

        await Navigator.pushNamed(context, RoutesName.accessibility);
        await Future.delayed(const Duration(seconds: 2));
        await _checkPermissions();
      }  else if (item.isNotifications) {
        await PermissionService.requestNotificationPermission();
        await Future.delayed(const Duration(seconds: 2));
        await _checkPermissions();
      } else if (item.isOverlay) {
        await PermissionService.requestOverlayPermission();
        await Future.delayed(const Duration(seconds: 2));
        await _checkPermissions();
      }else if (item.isAdmin) {
        await Navigator.pushNamed(context, RoutesName.admin);
        await Future.delayed(const Duration(seconds: 2));
        await _checkPermissions();
      }
 
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error requesting permission: $e';
        });
      }
      print('Permission request error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      await _checkPermissions(); // Ensure UI reflects latest statuses
    }
  }

  int get _grantedPermissionsCount {
    final count =
        _permissions.where((item) => item.status?.isGranted ?? false).length;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Permissions",
          style: const TextStyle(
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
        child: Column(
          children: [
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            Expanded(child: _buildPermissionsContent()),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed:
              _isLoading
                  ? null
                  : () {
                    final allGranted = _permissions.every(
                      (item) => item.status?.isGranted ?? false,
                    );
                    if (allGranted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        RoutesName.navigation,
                        (Route<dynamic> route) => false,
                      );
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(
                      //     content: Text('Permissions setup complete!'),
                      //     backgroundColor: Color(0xFF10B981),
                      //   ),
                      // );
                    } else {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Permissions Required'),
                              content: const Text(
                                'Some permissions are still required for the app to function properly. Please grant them now.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        RoutesName.navigation,
                                        (Route<dynamic> route) => false,
                                      ),
                                  child: const Text('Later'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Grant Now'),
                                ),
                              ],
                            ),
                      );
                    }
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
                onTap: () => _requestPermission(item),
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
