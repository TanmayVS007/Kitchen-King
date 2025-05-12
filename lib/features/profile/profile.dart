// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_king/features/authentication/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = "/profile_screen";
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    Future<Map<String, dynamic>?> fetchUserData() async {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) return null;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        return snapshot.data();
      } else {
        return null;
      }
    }

    final bgColor = Colors.grey[100];
    const cardColor = Colors.white;
    const textColor = Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile Details'),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator()); // Loading spinner
            }
            if (!snapshot.hasData ||
                snapshot.data == null ||
                snapshot.hasError) {
              return const Center(child: Text("No user data found."));
            }
            final userData = snapshot.data!;
            final timestamp = userData['timestamp'];
            final displayTime = timestamp is Timestamp
                ? timestamp.toDate()
                : timestamp is DateTime
                    ? timestamp
                    : DateTime.tryParse(timestamp.toString()); // Fallback
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: const BoxDecoration(
                      // color: accentColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: Text(
                            userData['name']
                                .split(' ')
                                .map((word) => word[0])
                                .join(),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              // color: accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userData['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            // color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '+91 ${userData['mobile']}',
                          style: const TextStyle(
                            fontSize: 16,
                            // color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          cardColor: cardColor,
                          textColor: textColor,
                          children: [
                            _buildInfoRow(
                              icon: Icons.location_city,
                              title: 'City',
                              value: userData['city'],
                              textColor: textColor,
                            ),
                            _buildInfoRow(
                              icon: Icons.map,
                              title: 'State',
                              value: userData['state'],
                              textColor: textColor,
                            ),
                            _buildInfoRow(
                              icon: Icons.pin_drop,
                              title: 'ZIP Code',
                              value: userData['zip_code'],
                              textColor: textColor,
                            ),
                            _buildInfoRow(
                              icon: Icons.home,
                              title: 'Home',
                              value: userData['home'],
                              textColor: textColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Household Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          cardColor: cardColor,
                          textColor: textColor,
                          children: [
                            _buildInfoRow(
                              icon: Icons.people,
                              title: 'Family Members',
                              value: userData['family_members'].toString(),
                              textColor: textColor,
                            ),
                            _buildInfoRow(
                              icon: Icons.restaurant,
                              title: 'Cooking Frequency',
                              value: '${userData['cooking_frequency']}',
                              textColor: textColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'System Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          cardColor: cardColor,
                          textColor: textColor,
                          children: [
                            _buildInfoRow(
                              icon: Icons.access_time,
                              title: 'Last Updated',
                              value: displayTime.toString(),
                              textColor: textColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          'LOGOUT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacementNamed(
                              context,
                              LoginScreen.routeName,
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Logout failed: $e",
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  Widget _buildInfoCard({
    required Color cardColor,
    required Color textColor,
    required List<Widget> children,
  }) {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
