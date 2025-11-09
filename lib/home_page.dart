import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Grades"),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('students').doc(uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final grades = Map<String, dynamic>.from(data['grades']);

          // ✨ هنا بنرتب المواد حسب الدرجات
          final sortedGrades = grades.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                data['name'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Your Grades (High → Low):",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ...sortedGrades.map((entry) {
                return Card(
                  child: ListTile(
                    title: Text(entry.key.toUpperCase()),
                    trailing: Text(entry.value.toString(),
                        style: const TextStyle(fontSize: 18)),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
