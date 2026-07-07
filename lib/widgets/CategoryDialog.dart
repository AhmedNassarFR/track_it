import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/components/GlassContainer.dart';
import 'package:track_it/controllers/TrainingController.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController nameController = TextEditingController();
  String? errorText;

  @override
  Widget build(BuildContext context) {
    final TrainingController controller = Get.find();

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: GlassContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Category',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(nameController, 'Category name', errorText),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _glassButton('Cancel', () => Get.back()),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _accentButton('Add', () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) {
                          setState(() => errorText = 'Name cannot be empty');
                          return;
                        }
                        if (controller.categories.contains(name)) {
                          setState(() => errorText = 'Category already exists');
                          return;
                        }
                        controller.addCategory(name);
                        Get.back();
                      }),
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

class EditCategoryDialog extends StatefulWidget {
  final String categoryName;
  const EditCategoryDialog({super.key, required this.categoryName});

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  late final TextEditingController nameController;
  String? errorText;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.categoryName);
  }

  @override
  Widget build(BuildContext context) {
    final TrainingController controller = Get.find();

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: GlassContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Rename Category',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(nameController, 'New name', errorText),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _glassButton('Cancel', () => Get.back()),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _accentButton('Save', () {
                        final newName = nameController.text.trim();
                        if (newName.isEmpty) {
                          setState(() => errorText = 'Name cannot be empty');
                          return;
                        }
                        if (newName == widget.categoryName) {
                          Get.back();
                          return;
                        }
                        if (controller.categories.contains(newName)) {
                          setState(() => errorText = 'Category already exists');
                          return;
                        }
                        controller.editCategory(widget.categoryName, newName);
                        Get.back();
                      }),
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

class CategoryOptionsDialog extends StatelessWidget {
  final String categoryName;
  const CategoryOptionsDialog({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final TrainingController controller = Get.find();
    final bool isOthers = categoryName == 'Others';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Material(
          color: Colors.transparent,
          child: GlassContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  categoryName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                // Rename option
                _optionTile(
                  icon: Icons.edit_rounded,
                  label: 'Rename',
                  color: AppColors.accentCyan,
                  enabled: !isOthers,
                  onTap: () {
                    Get.back();
                    Get.dialog(EditCategoryDialog(categoryName: categoryName));
                  },
                ),
                const SizedBox(height: 8),
                // Delete option
                _optionTile(
                  icon: Icons.delete_rounded,
                  label: 'Delete',
                  color: AppColors.accentPink,
                  enabled: !isOthers,
                  onTap: () {
                    Get.back();
                    Get.dialog(_DeleteConfirmDialog(
                      title: 'Delete "$categoryName"?',
                      message:
                          'All exercises in this category will be moved to "Others".',
                      onConfirm: () {
                        controller.deleteCategory(categoryName);
                        Get.back();
                      },
                    ));
                  },
                ),
                if (isOthers) ...[
                  const SizedBox(height: 12),
                  Text(
                    '"Others" cannot be renamed or deleted',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: _glassButton('Close', () => Get.back()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: enabled
              ? color.withOpacity(0.08)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? color.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: enabled ? color : AppColors.textTertiary, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: enabled ? AppColors.white : AppColors.textTertiary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const _DeleteConfirmDialog({
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Material(
          color: Colors.transparent,
          child: GlassContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentPink.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: AppColors.accentPink,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _glassButton('Cancel', () => Get.back()),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: onConfirm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.accentPink.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.accentPink.withOpacity(0.4),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                color: AppColors.accentPink,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
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

// ─── Shared Helpers ───

Widget _buildTextField(
    TextEditingController controller, String hint, String? error) {
  return TextField(
    controller: controller,
    style: const TextStyle(color: AppColors.white),
    textAlign: TextAlign.center,
    decoration: InputDecoration(
      fillColor: Colors.white.withOpacity(0.06),
      filled: true,
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 15),
      errorText: error,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.accentPurple.withOpacity(0.5)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.accentPink.withOpacity(0.5)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.accentPink.withOpacity(0.5)),
      ),
    ),
  );
}

Widget _glassButton(String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    ),
  );
}

Widget _accentButton(String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.accentPurple,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    ),
  );
}
