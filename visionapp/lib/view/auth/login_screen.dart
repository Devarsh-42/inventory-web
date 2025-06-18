import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visionapp/pallet.dart'; // Add this import
import 'package:visionapp/view/admin/admin_dashboard.dart';
import 'package:visionapp/view/management/dashboard.dart';
import 'package:visionapp/view/production/production_dashboard.dart';
import 'package:visionapp/view/routes/app_routes.dart';
import 'package:visionapp/view/sales/sales_dashboard.dart'; 
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

  @override
  void dispose() {
    _companyIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final userId = _companyIdController.text.trim();
      final email = '$userId@gmail.com';  // Append @gmail.com
      final password = _passwordController.text.trim();

      try {
        // Sign in with Supabase
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: email,  // Use modified email
          password: password,
        );

        if (response.user != null) {
          // Get user role from users table
          final userData = await Supabase.instance.client
              .from('users')
              .select('role')
              .eq('email', email)  // Use modified email
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
          } else if (userData['role'] == 'sales') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SalesDashboardScreen()),
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

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Palette.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Palette.cardBackground,
                borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
                boxShadow: Palette.getShadow(opacity: 0.1),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        Center(
                          child: Image.asset(
                            'assets/images/volcan_vision_logo.png',
                            height: isMobile ? 40 : 48,
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 24),
                        Text(
                          'Supply Chain',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Palette.primaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Management System V1.0',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Palette.primaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User ID',  // Changed from 'Company ID'
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Palette.secondaryTextColor,
                              )
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _companyIdController,
                              decoration: InputDecoration(
                                hintText: 'Enter your user ID',  // Changed from 'Enter your company ID'
                                hintStyle: TextStyle(color: Palette.tertiaryTextColor),
                                fillColor: Palette.surfaceGray,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Palette.borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Palette.borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Palette.primaryBlue),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, 
                                  vertical: 16
                                ),
                              ),
                              validator: (value) => value == null || value.isEmpty 
                                ? 'Please enter your user ID'  // Changed from 'Please enter your company ID'
                                : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password', 
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Palette.secondaryTextColor,
                              )
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                hintStyle: TextStyle(color: Palette.tertiaryTextColor),
                                fillColor: Palette.surfaceGray,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Palette.borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Palette.borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Palette.primaryBlue),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, 
                                  vertical: 16
                                ),
                              ),
                              validator: (value) => value == null || value.isEmpty 
                                ? 'Please enter your password' 
                                : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: Palette.buttonGradient,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: Palette.getButtonShadow(opacity: 0.2),
                          ),
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Palette.transparentColor,
                              foregroundColor: Palette.inverseTextColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}