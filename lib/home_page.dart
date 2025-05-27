import 'package:flutter/material.dart';
import 'package:note_app/colors.dart' as Colors;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home',
            style: TextStyle(fontSize: 24, color: Colors.background)),
        centerTitle: false,
        backgroundColor: Colors.accent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to my App!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildMenucard(
                  icon: Icons.person,
                  title: 'person',
                  onTap: () {
                    //Navigate to person
                  },
                ),
                _buildMenucard(
                  icon: Icons.settings,
                  title: 'settings',
                  onTap: () {
                    //Navigate to settigs
                  },
                ),
                _buildMenucard(
                  icon: Icons.info,
                  title: 'about',
                  onTap: () {
                    //Navigate to about
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenucard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.accent),
                const SizedBox(height: 40),
                Text(title, textAlign: TextAlign.center),
              ],
            ),
          ),
        ));
  }
}
