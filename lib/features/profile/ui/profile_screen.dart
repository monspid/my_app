import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final box = Hive.box('profile');

  String get name => box.get('name', defaultValue: 'John Doe');
  String get username => box.get('username', defaultValue: '@johndoe');

  final String avatar =
      "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde";

  void openEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          name: name,
          username: username,
        ),
      ),
    );

    if (result != null) {
      await box.put('name', result['name']);
      await box.put('username', result['username']);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [

        /// 🔥 TELEGRAM HEADER
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: Colors.blue,

          leading: const BackButton(),

          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: openEdit,
            ),
          ],

          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Stack(
              fit: StackFit.expand,
              children: [

                /// BACKGROUND IMAGE
                Image.network(
                  avatar,
                  fit: BoxFit.cover,
                ),

                /// BLUR
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: Colors.blue.withOpacity(0.5),
                  ),
                ),

                /// PROFILE INFO
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(avatar),
                        ),

                        const SizedBox(width: 12),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            Text(
                              username,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        /// 🔥 BODY (исправлено через Material)
        SliverToBoxAdapter(
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [

                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Account"),
                  onTap: () {},
                ),

                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text("Privacy"),
                  onTap: () {},
                ),

                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text("Notifications"),
                  onTap: () {},
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}