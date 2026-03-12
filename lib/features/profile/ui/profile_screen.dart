import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final box = Hive.box('profileBox');

  String name = "John Doe";
  String username = "johndoe";
  String bio = "Flutter developer 🚀";
  Uint8List? avatarBytes;
  bool online = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() {
    final data = box.get('profile');

    if (data != null) {
      setState(() {
        name = data['name'];
        username = data['username'];
        bio = data['bio'];
        avatarBytes = data['avatar'];
        online = data['online'];
      });
    }
  }

  void saveProfile() {
    box.put('profile', {
      'name': name,
      'username': username,
      'bio': bio,
      'avatar': avatarBytes,
      'online': online,
    });
  }

  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      avatarBytes = bytes;
    });

    saveProfile();
  }

  void editProfile() {
    final nameController = TextEditingController(text: name);
    final usernameController = TextEditingController(text: username);
    final bioController = TextEditingController(text: bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit profile",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  labelText: "Bio",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    name = nameController.text;
                    username = usernameController.text;
                    bio = bioController.text;
                  });

                  saveProfile();

                  Navigator.pop(context);
                },
                child: const Text("Save"),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff5C6BC0),
                  Color(0xff3949AB),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Profile",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                GestureDetector(
                                  onTap: pickAvatar,
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundImage: avatarBytes != null
                                        ? MemoryImage(avatarBytes!)
                                        : null,
                                    child: avatarBytes == null
                                        ? const Icon(Icons.person, size: 60)
                                        : null,
                                  ),
                                ),
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: online ? Colors.green : Colors.grey,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "@$username",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              bio,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 25),
                            FilledButton.icon(
                              onPressed: editProfile,
                              icon: const Icon(Icons.edit),
                              label: const Text("Edit profile"),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
