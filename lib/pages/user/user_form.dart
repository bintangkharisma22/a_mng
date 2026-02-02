// pages/user/user_form_page.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/peran.dart';
import '../../models/divisi.dart';
import '../../services/user_service.dart';
import '../../services/peran_service.dart';
import '../../services/divisi_service.dart';

class UserFormPage extends StatefulWidget {
  const UserFormPage({super.key});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();

  String? _userId;
  User? _existingUser;
  Peran? _selectedPeran;
  Divisi? _selectedDivisi;
  bool _statusAktif = true;
  bool _isLoading = false;
  bool _isLoadingData = true;

  List<Peran> _peranList = [];
  List<Divisi> _divisiList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        _userId = args;
        _loadUserData();
      } else {
        _loadInitialData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    try {
      final peranList = await PeranService.getPeranList();
      final divisiList = await DivisiService.getDivisi();

      setState(() {
        _peranList = peranList;
        _divisiList = divisiList;
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = await UserService.getUserById(_userId!);
      final peranList = await PeranService.getPeranList();
      final divisiList = await DivisiService.getDivisi();

      setState(() {
        _existingUser = user;
        _emailController.text = user.email ?? '';
        _teleponController.text = user.telepon ?? '';
        _alamatController.text = user.alamat ?? '';
        _selectedPeran = user.peran;
        _selectedDivisi = user.divisi;
        _statusAktif = user.statusAktif;
        _peranList = peranList;
        _divisiList = divisiList;
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data user: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPeran == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih peran'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_userId == null) {
        // Create new user
        if (_passwordController.text.isEmpty) {
          throw Exception('Password wajib diisi untuk user baru');
        }

        await UserService.createUser(
          email: _emailController.text,
          password: _passwordController.text,
          peranId: _selectedPeran!.id,
          divisiId: _selectedDivisi?.id,
          telepon: _teleponController.text.isEmpty
              ? null
              : _teleponController.text,
          alamat: _alamatController.text.isEmpty
              ? null
              : _alamatController.text,
          statusAktif: _statusAktif,
        );

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User berhasil dibuat')));
        }
      } else {
        // Update existing user
        await UserService.updateUser(
          id: _userId!,
          email: _emailController.text,
          password: _passwordController.text.isEmpty
              ? null
              : _passwordController.text,
          peranId: _selectedPeran!.id,
          divisiId: _selectedDivisi?.id,
          telepon: _teleponController.text.isEmpty
              ? null
              : _teleponController.text,
          alamat: _alamatController.text.isEmpty
              ? null
              : _alamatController.text,
          statusAktif: _statusAktif,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User berhasil diupdate')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userId == null ? 'Tambah User' : 'Edit User'),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email wajib diisi';
                        }
                        if (!value.contains('@')) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: _userId == null
                            ? 'Password'
                            : 'Password (kosongkan jika tidak diubah)',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (_userId == null &&
                            (value == null || value.isEmpty)) {
                          return 'Password wajib diisi untuk user baru';
                        }
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Peran
                    DropdownButtonFormField<Peran>(
                      value: _selectedPeran,
                      decoration: const InputDecoration(
                        labelText: 'Peran',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.admin_panel_settings),
                      ),
                      items: _peranList.map((peran) {
                        return DropdownMenuItem(
                          value: peran,
                          child: Text(peran.namaTampilan ?? peran.nama),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedPeran = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Peran wajib dipilih';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Divisi
                    DropdownButtonFormField<Divisi>(
                      value: _selectedDivisi,
                      decoration: const InputDecoration(
                        labelText: 'Divisi (Opsional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('-- Pilih Divisi --'),
                        ),
                        ..._divisiList.map((divisi) {
                          return DropdownMenuItem(
                            value: divisi,
                            child: Text(divisi.nama),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedDivisi = value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Telepon
                    TextFormField(
                      controller: _teleponController,
                      decoration: const InputDecoration(
                        labelText: 'Telepon (Opsional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Alamat
                    TextFormField(
                      controller: _alamatController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat (Opsional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Status Aktif
                    SwitchListTile(
                      title: const Text('Status Aktif'),
                      subtitle: Text(
                        _statusAktif
                            ? 'User dapat login'
                            : 'User tidak dapat login',
                      ),
                      value: _statusAktif,
                      onChanged: (value) {
                        setState(() => _statusAktif = value);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _userId == null ? 'Tambah User' : 'Update User',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
