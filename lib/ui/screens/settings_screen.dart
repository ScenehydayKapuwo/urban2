import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban2/core/providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.restore_rounded, color: Colors.white),
              tooltip: 'Reset to Defaults',
              onPressed: () => _showResetDialog(context),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customize Your Experience',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Configure settings to optimize your network analysis workflow',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Settings Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Application Settings Section
                    _buildModernSection(
                      'Application Settings',
                      Icons.settings_rounded,
                      [
                        _buildModernSwitchTile(
                          context,
                          title: 'Dark Mode',
                          subtitle: 'Switch to dark theme interface',
                          value: settingsProvider.isDarkMode,
                          onChanged: (value) => settingsProvider.toggleDarkMode(value),
                          icon: Icons.dark_mode_rounded,
                        ),
                        _buildModernListTile(
                          context,
                          title: 'App Language',
                          subtitle: settingsProvider.currentLanguage,
                          icon: Icons.language_rounded,
                          onTap: () => _showLanguageDialog(context),
                        ),
                        _buildModernListTile(
                          context,
                          title: 'Measurement Units',
                          subtitle: settingsProvider.useMetric ? 'Metric (m, kg)' : 'Imperial (ft, lb)',
                          icon: Icons.straighten_rounded,
                          onTap: () => settingsProvider.toggleMeasurementUnits(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Simulation Preferences Section
                    _buildModernSection(
                      'Simulation Preferences',
                      Icons.tune_rounded,
                      [
                        _buildSliderTile(
                          context,
                          title: 'Default Simulation Duration',
                          subtitle: 'Set the standard runtime for simulations',
                          value: settingsProvider.defaultSimulationDuration.toDouble(),
                          displayValue: '${settingsProvider.defaultSimulationDuration}s',
                          min: 5,
                          max: 300,
                          divisions: 59,
                          icon: Icons.timer_rounded,
                          onChanged: (value) => settingsProvider.setSimulationDuration(value.toInt()),
                        ),
                        _buildModernSwitchTile(
                          context,
                          title: 'Auto-save Results',
                          subtitle: 'Automatically save simulation outputs',
                          value: settingsProvider.autoSaveResults,
                          onChanged: (value) => settingsProvider.toggleAutoSave(value),
                          icon: Icons.save_rounded,
                        ),
                        _buildModernListTile(
                          context,
                          title: 'Default Export Format',
                          subtitle: 'Preferred format for data export',
                          icon: Icons.import_export_rounded,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              settingsProvider.exportFormat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          onTap: () => _showExportFormatDialog(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Notification Settings Section
                    _buildModernSection(
                      'Notifications',
                      Icons.notifications_rounded,
                      [
                        _buildModernSwitchTile(
                          context,
                          title: 'Simulation Complete Alerts',
                          subtitle: 'Get notified when simulations finish',
                          value: settingsProvider.simulationAlerts,
                          onChanged: (value) => settingsProvider.toggleSimulationAlerts(value),
                          icon: Icons.notifications_active_rounded,
                        ),
                        _buildModernSwitchTile(
                          context,
                          title: 'Optimization Suggestions',
                          subtitle: 'Receive AI-powered optimization tips',
                          value: settingsProvider.optimizationAlerts,
                          onChanged: (value) => settingsProvider.toggleOptimizationAlerts(value),
                          icon: Icons.auto_awesome_rounded,
                        ),
                        _buildModernSwitchTile(
                          context,
                          title: 'Critical Metrics Alerts',
                          subtitle: 'Alerts for performance threshold breaches',
                          value: settingsProvider.metricAlerts,
                          onChanged: (value) => settingsProvider.toggleMetricAlerts(value),
                          icon: Icons.warning_rounded,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Data Management Section
                    _buildModernSection(
                      'Data Management',
                      Icons.storage_rounded,
                      [
                        _buildModernActionTile(
                          context,
                          title: 'Clear Simulation Cache',
                          subtitle: 'Free up storage space',
                          icon: Icons.cleaning_services_rounded,
                          iconColor: Colors.orange,
                          onTap: () => _showClearCacheDialog(context),
                        ),
                        _buildModernActionTile(
                          context,
                          title: 'Export All Data',
                          subtitle: 'Backup your simulations and settings',
                          icon: Icons.backup_rounded,
                          iconColor: Colors.blue,
                          onTap: () => _exportAllData(context),
                        ),
                        _buildModernActionTile(
                          context,
                          title: 'Privacy Settings',
                          subtitle: 'Manage data collection preferences',
                          icon: Icons.privacy_tip_rounded,
                          iconColor: Colors.green,
                          onTap: () => _showPrivacySettings(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // About Section
                    _buildModernSection(
                      'About',
                      Icons.info_rounded,
                      [
                        _buildModernInfoTile(
                          context,
                          title: 'App Version',
                          subtitle: '1.2.3 (Build 456)',
                          icon: Icons.info_outline_rounded,
                        ),
                        _buildModernActionTile(
                          context,
                          title: 'Terms of Service',
                          subtitle: 'Legal agreement and user terms',
                          icon: Icons.description_rounded,
                          iconColor: Colors.purple,
                          onTap: () => _showTerms(context),
                        ),
                        _buildModernActionTile(
                          context,
                          title: 'Privacy Policy',
                          subtitle: 'Data usage and protection information',
                          icon: Icons.security_rounded,
                          iconColor: Colors.teal,
                          onTap: () => _showPrivacyPolicy(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSection(String title, IconData sectionIcon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    sectionIcon,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ...children.map((child) => Column(
            children: [
              child,
              if (child != children.last)
                Divider(
                  height: 1,
                  color: Colors.grey[200],
                  indent: 20,
                  endIndent: 20,
                ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildModernListTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required VoidCallback onTap,
        Widget? trailing,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
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
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernSwitchTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        required bool value,
        required ValueChanged<bool> onChanged,
        required IconData icon,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
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
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        required double value,
        required String displayValue,
        required double min,
        required double max,
        required int divisions,
        required IconData icon,
        required ValueChanged<double> onChanged,
      }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            displayValue,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Theme.of(context).primaryColor,
              inactiveTrackColor: Theme.of(context).primaryColor.withOpacity(0.2),
              thumbColor: Theme.of(context).primaryColor,
              overlayColor: Theme.of(context).primaryColor.withOpacity(0.1),
              valueIndicatorColor: Theme.of(context).primaryColor,
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: value.round().toString(),
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildModernActionTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color iconColor,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
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
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.grey[600],
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
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dialog methods (keeping the original functionality)
  Future<void> _showResetDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Reset Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text('Are you sure you want to reset all settings to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<SettingsProvider>(context, listen: false).resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Settings reset to defaults'),
                  backgroundColor: Theme.of(context).primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Text(
              'Reset',
              style: TextStyle(
                color: Colors.red[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Select Language',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              return RadioListTile(
                title: Text(languages[index]),
                value: languages[index],
                groupValue: settingsProvider.currentLanguage,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  settingsProvider.setLanguage(value.toString());
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showExportFormatDialog(BuildContext context) async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final formats = ['PDF', 'CSV', 'JSON', 'XML'];

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Select Export Format',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: formats.length,
            itemBuilder: (context, index) {
              return RadioListTile(
                title: Text(formats[index]),
                value: formats[index],
                groupValue: settingsProvider.exportFormat,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  settingsProvider.setExportFormat(value.toString());
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showClearCacheDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear Cache',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text('This will remove all locally stored simulation data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cache cleared successfully'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Text(
              'Clear',
              style: TextStyle(
                color: Colors.orange[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder methods for other actions
  void _exportAllData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exporting all data...'),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening privacy settings...'),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showTerms(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening terms of service...'),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening privacy policy...'),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}