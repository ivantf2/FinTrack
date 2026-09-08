import 'package:flutter/material.dart';

import '../../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();

  String _goal = 'Build Muscle';
  String _unit = 'kg / cm';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await DatabaseService.getProfile();

    if (!mounted) return;

    if (profile != null) {
      _name.text = profile['name'] as String;
      _height.text = '${profile['height']}';
      _weight.text = '${profile['weight']}';
      _goal = profile['goal'] as String;
      _unit = profile['unit'] as String;
    }

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await DatabaseService.saveProfile(
      name: _name.text.trim().isEmpty ? 'Athlete' : _name.text.trim(),
      height: double.tryParse(_height.text) ?? 0,
      weight: double.tryParse(_weight.text) ?? 0,
      goal: _goal,
      unit: _unit,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _height,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Height',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _weight,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _goal,
              decoration: const InputDecoration(
                labelText: 'Goal',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Build Muscle',
                  child: Text('Build Muscle'),
                ),
                DropdownMenuItem(
                  value: 'Lose Fat',
                  child: Text('Lose Fat'),
                ),
                DropdownMenuItem(
                  value: 'Maintain',
                  child: Text('Maintain'),
                ),
                DropdownMenuItem(
                  value: 'Strength',
                  child: Text('Strength'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _goal = value);
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _unit,
              decoration: const InputDecoration(
                labelText: 'Units',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'kg / cm',
                  child: Text('kg / cm'),
                ),
                DropdownMenuItem(
                  value: 'lb / in',
                  child: Text('lb / in'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _unit = value);
              },
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
