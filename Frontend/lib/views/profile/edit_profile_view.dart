import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _birthdateController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _medicalConditionsController;
  late TextEditingController _medicationsController;
  late TextEditingController _allergiesController;

  String _selectedGender = 'Prefiero no decirlo';
  final List<String> _genders = [
    'Masculino',
    'Femenino',
    'Otro',
    'Prefiero no decirlo',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().currentUser;
    _nameController = TextEditingController(text: user?.nombre ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _birthdateController = TextEditingController(text: user?.birthdate ?? '');
    _weightController = TextEditingController(
      text: user?.weight?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: user?.height?.toString() ?? '',
    );
    _medicalConditionsController = TextEditingController(
      text: user?.medicalConditions ?? '',
    );
    _medicationsController = TextEditingController(
      text: user?.medications ?? '',
    );
    _allergiesController = TextEditingController(text: user?.allergies ?? '');

    if (user?.gender != null && _genders.contains(user!.gender)) {
      _selectedGender = user.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _medicalConditionsController.dispose();
    _medicationsController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthdateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authController = context.read<AuthController>();
      final currentUser = authController.currentUser;

      if (currentUser == null) return;

      final updatedUser = UserModel(
        id: currentUser.id,
        nombre: _nameController.text.trim(),
        email: currentUser
            .email, // Email no editable por seguridad/consistencia key
        password: currentUser
            .password, // Mantenemos password actual en modelo (no se envia si no cambia en backend logic pero aqui lo requiere el modelo)
        birthdate: _birthdateController.text.trim(),
        gender: _selectedGender,
        weight: double.tryParse(_weightController.text.trim()),
        height: double.tryParse(_heightController.text.trim()),
        medicalConditions: _medicalConditionsController.text.trim(),
        medications: _medicationsController.text.trim(),
        allergies: _allergiesController.text.trim(),
      );

      final success = await authController.updateProfile(updatedUser);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado correctamente')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authController.errorMessage ?? 'Error al actualizar',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AuthController>(
        builder: (context, authController, child) {
          if (authController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle('Información Básica'),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Nombre Completo',
                    hint: 'Ingresa tu nombre',
                    prefixIcon: Icon(Icons.person_outline),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Correo Electrónico',
                    hint: 'Ingresa tu correo',
                    prefixIcon: Icon(Icons.email_outlined),
                    readOnly: true, // No editable
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.withOpacity(0.1)
                        : Colors.grey.shade200,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: CustomTextField(
                        controller: _birthdateController,
                        label: 'Fecha de Nacimiento',
                        hint: 'YYYY-MM-DD',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        validator: (value) =>
                            value!.isEmpty ? 'Campo requerido' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Género',
                      prefixIcon: const Icon(Icons.people_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).inputDecorationTheme.fillColor,
                    ),
                    items: _genders.map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Datos Médicos (Opcional)'),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _weightController,
                          label: 'Peso (kg)',
                          hint: 'Ej: 70.5',
                          prefixIcon: Icon(Icons.monitor_weight_outlined),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _heightController,
                          label: 'Altura (cm)',
                          hint: 'Ej: 175',
                          prefixIcon: Icon(Icons.height_outlined),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _medicalConditionsController,
                    label: 'Condiciones Médicas',
                    hint: 'Ej: Diabetes, Hipertensión',
                    prefixIcon: Icon(Icons.medical_services_outlined),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _medicationsController,
                    label: 'Medicamentos',
                    hint: 'Ej: Ibuprofeno, Insulina',
                    prefixIcon: Icon(Icons.medication_outlined),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _allergiesController,
                    label: 'Alergias',
                    hint: 'Ej: Penicilina, Nueces',
                    prefixIcon: Icon(Icons.warning_amber_rounded),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 40),
                  CustomButton(
                    text: 'Guardar Cambios',
                    onPressed: _saveProfile,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h3.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
