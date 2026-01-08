import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'step1_ship_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balai Karantina Kesehatan'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const Gap(20),
              const Text(
                'Selamat Datang Petugas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Gap(10),
              const Text(
                'Silahkan mulai pemeriksaan kapal baru',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Gap(40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Step1ShipForm()),
                    );
                  },
                  icon: const Icon(Icons.add_task),
                  label: const Text('Buat Pemeriksaan Baru'),
                ),
              ),
              const Gap(16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // History functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur Riwayat akan segera hadir')),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Riwayat Pemeriksaan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
