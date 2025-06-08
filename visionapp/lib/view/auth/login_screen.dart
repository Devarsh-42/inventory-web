import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visionapp/view/admin/admin_dashboard.dart';
import 'package:visionapp/view/management/dashboard.dart';
import 'package:visionapp/view/production/production_dashboard.dart';
import 'package:visionapp/view/routes/app_routes.dart'; 
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyIdController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedInterface = 'Management';

  @override
  void dispose() {
    _companyIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _companyIdController.text.trim();
      final password = _passwordController.text.trim();

      try {
        // Sign in with Supabase
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user != null) {
          // Get user role from users table
          final userData = await Supabase.instance.client
              .from('users')
              .select('role')
              .eq('email', email)
              .single();

          if (!mounted) return;

          // Handle navigation based on role
          if (userData['role'] == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          } else if (userData['role'] == 'production') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProductionDashboardScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid user role')),
            );
          }
        }
      } on AuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unexpected error occurred')),
        );
      }
    }
  }


  // Future<void> _login() async {
  //   if (_formKey.currentState!.validate()) {
  //     final email = _companyIdController.text.trim();
  //     final password = _passwordController.text.trim();

  //     try {
  //       final response = await Supabase.instance.client.auth.signInWithPassword(
  //         email: email,
  //         password: password,
  //       );

  //       if (response.user != null) {
  //         Navigator.pushReplacementNamed(context, '/managementHome');
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Login successful!')),
  //         );
  //         // Navigate based on interface
  //         if (_selectedInterface == 'Management') {
  //           Navigator.pushReplacementNamed(context, '/managementHome');
  //         } else {
  //           Navigator.pushReplacementNamed(context, '/productionHome');
  //         }
  //       }
  //     } on AuthException catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(e.message)),
  //       );
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Unexpected error occurred')),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 70),
                Center(
                  child: Image.asset(
                    'assets/images/volcan_vision_logo.png',
                    height: 40,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Production',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Management System',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Company ID', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _companyIdController,
                      decoration: InputDecoration(
                        hintText: 'Enter your company ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.deepPurple),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your company ID' : null,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Password', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.deepPurple),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your password' : null,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Interface', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedInterface = 'Management'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedInterface == 'Management' ? Colors.deepPurple : Colors.white,
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                                border: Border.all(color: _selectedInterface == 'Management' ? Colors.deepPurple : Colors.grey.shade300),
                              ),
                              child: Text('Management', textAlign: TextAlign.center, style: TextStyle(color: _selectedInterface == 'Management' ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedInterface = 'Production'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedInterface == 'Production' ? Colors.deepPurple : Colors.white,
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                                border: Border.all(color: _selectedInterface == 'Production' ? Colors.deepPurple : Colors.grey.shade300),
                              ),
                              child: Text('Production', textAlign: TextAlign.center, style: TextStyle(color: _selectedInterface == 'Production' ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: Colors.black54)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
                      child: const Text('Sign Up', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}