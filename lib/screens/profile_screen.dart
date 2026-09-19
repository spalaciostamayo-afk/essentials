import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F2),

      appBar: AppBar(
        title: const Text("Mi perfil"),
        centerTitle: true,
      ),

      body: Center(
        child: Container(
          width: 450,
          margin: const EdgeInsets.all(25),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 50,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Usuario",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                user?.email ?? "",
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              ListTile(
                leading: const Icon(Icons.email),
                title: const Text("Correo"),
                subtitle: Text(user?.email ?? ""),
              ),

              const Divider(),

              const ListTile(
                leading: Icon(Icons.info),
                title: Text("Versión"),
                subtitle: Text("ESSENTIALS 1.0"),
              ),

              const Divider(),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text("Cerrar sesión"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {

                    await FirebaseAuth.instance.signOut();

                    if (!context.mounted) return;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (_) => false,
                    );

                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}