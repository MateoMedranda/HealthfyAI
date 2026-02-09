import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_dialog.dart';
import '../../widgets/common/wave_background.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthdateController = TextEditingController();

  String _selectedGender = 'Masculino';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      print('📋 FORM: Validación del formulario completada');

      // Validar que las contraseñas coincidan
      if (_passwordController.text != _confirmPasswordController.text) {
        print('❌ FORM: Las contraseñas no coinciden');
        ErrorDialog.show(
          context,
          'Contraseñas no coinciden',
          'Las contraseñas ingresadas no son iguales. Por favor verifica e intenta nuevamente.',
        );
        return;
      }

      // Validar fecha de nacimiento
      if (_birthdateController.text.isEmpty) {
        print('❌ FORM: Fecha de nacimiento vacía');
        ErrorDialog.show(
          context,
          'Fecha requerida',
          'Por favor selecciona tu fecha de nacimiento.',
        );
        return;
      }

      print('📝 FORM: Creando UserModel con los siguientes datos:');
      print('  - Nombre: ${_nameController.text.trim()}');
      print('  - Email: ${_emailController.text.trim()}');
      print('  - Password: ${'*' * _passwordController.text.length}');
      print('  - Birthdate: ${_birthdateController.text}');
      print('  - Gender: $_selectedGender');

      final user = UserModel(
        nombre: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        birthdate: _birthdateController.text,
        gender: _selectedGender,
      );

      print('📣 FORM: Iniciando registro en AuthController');
      final authController = context.read<AuthController>();
      final success = await authController.register(user);

      print('📣 FORM: Resultado del registro - Success: $success');

      if (success && mounted) {
        print('✅ FORM: Registro exitoso, navegando a home');
        Navigator.pushReplacementNamed(context, '/home');
      } else if (mounted) {
        print('❌ FORM: Registro falló - ${authController.errorMessage}');
        ErrorDialog.show(
          context,
          'Error al Registrar',
          authController.errorMessage ?? 'Ocurrió un error inesperado',
        );
      }
    } else {
      print('❌ FORM: Validación del formulario falló');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      body: WaveBackground(
        child: Column(
          children: [
            // AppBar personalizado
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.primary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
            // Contenido
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Crear Cuenta', style: AppTextStyles.h1),
                      const SizedBox(height: 8),
                      Text(
                        'Completa tus datos para comenzar',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Nombre
                      CustomTextField(
                        label: 'Nombre completo',
                        controller: _nameController,
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: AppColors.primary,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre completo es obligatorio';
                          }
                          if (value.length < 3) {
                            return 'El nombre debe tener al menos 3 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      CustomTextField(
                        label: 'Correo electrónico',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.primary,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El correo electrónico es obligatorio';
                          }
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Ingresa un correo electrónico válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Fecha de nacimiento
                      CustomTextField(
                        label: 'Fecha de nacimiento',
                        controller: _birthdateController,
                        prefixIcon: const Icon(
                          Icons.cake_outlined,
                          color: AppColors.primary,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor selecciona tu fecha de nacimiento';
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                          ),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Género
                      Text('Género', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedGender,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: ['Masculino', 'Femenino', 'Otro'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedGender = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contraseña
                      CustomTextField(
                        label: 'Contraseña',
                        hint: '**********',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La contraseña es obligatoria';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirmar contraseña
                      CustomTextField(
                        label: 'Confirmar contraseña',
                        hint: '**********',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Debes confirmar tu contraseña';
                          }
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Botón Registro
                      CustomButton(
                        text: 'Registrarse',
                        onPressed: _handleRegister,
                        isLoading: authController.isLoading,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
