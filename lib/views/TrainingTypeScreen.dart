import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/components/GlassContainer.dart';
import 'package:track_it/controllers/TrainingController.dart';
import 'package:track_it/widgets/CategoryDialog.dart';

import 'HomeScreen.dart';

class TrainingTypeScreen extends StatefulWidget {
  const TrainingTypeScreen({super.key});

  @override
  State<TrainingTypeScreen> createState() => _TrainingTypeScreenState();
}

class _TrainingTypeScreenState extends State<TrainingTypeScreen> {
  bool _isEditingOrder = false;

  @override
  Widget build(BuildContext context) {
    final TrainingController controller = Get.find<TrainingController>();

    return Obx(() {
      if (controller.categories.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: GlassContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.category_rounded,
                      color: AppColors.textTertiary, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'No categories yet',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap + in the top bar to add your first category',
                    style: TextStyle(
                        color: AppColors.textTertiary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      final isListView = controller.crossAxisCount.value == 1;

      if (isListView) {
        if (_isEditingOrder) _isEditingOrder = false;
        return _buildReorderableList(controller);
      }

      return _buildGridSection(controller);
    });
  }

  Widget _buildReorderableList(TrainingController controller) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: controller.categories.length,
      onReorder: (oldIndex, newIndex) =>
          controller.reorderCategories(oldIndex, newIndex),
      proxyDecorator: (child, index, animation) => Material(
        color: Colors.transparent,
        child: Opacity(opacity: 0.85, child: child),
      ),
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        return Obx(
          key: ValueKey(category),
          () {
          final count = controller.getExerciseCountForCategory(category);
          final icon = controller.getCategoryIconData(category);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _CategoryGridTile(
            name: category,
            count: count,
            isListView: true,
            icon: icon,
            onTap: () =>
                Get.to(() => HomePageContent(trainingType: category)),
          ));
        });
      },
    );
  }

  Widget _buildGridSection(TrainingController controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              if (_isEditingOrder) ...[
                const Icon(Icons.drag_indicator_rounded,
                    color: AppColors.accentPurple, size: 20),
                const SizedBox(width: 6),
                Text('Drag to reorder',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() => _isEditingOrder = false),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Done'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.accentPurple),
                ),
              ] else ...[
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() => _isEditingOrder = true),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit Order'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.textTertiary),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: _isEditingOrder
              ? _buildEditGrid(controller)
              : _buildNormalGrid(controller),
        ),
      ],
    );
  }

  Widget _buildNormalGrid(TrainingController controller) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: controller.categories.length,
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        return Obx(() {
          final count = controller.getExerciseCountForCategory(category);
          final icon = controller.getCategoryIconData(category);
          return _CategoryGridTile(
            name: category,
            count: count,
            isListView: false,
            icon: icon,
            onTap: () =>
                Get.to(() => HomePageContent(trainingType: category)),
            onLongPress: () => Get.dialog(
                CategoryOptionsDialog(categoryName: category)),
          );
        });
      },
    );
  }

  Widget _buildEditGrid(TrainingController controller) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: controller.categories.length,
      onReorder: (oldIndex, newIndex) =>
          controller.reorderCategories(oldIndex, newIndex),
      proxyDecorator: (child, index, animation) => Material(
        color: Colors.transparent,
        child: Opacity(opacity: 0.85, child: child),
      ),
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        return Obx(
          key: ValueKey(category),
          () {
          final count = controller.getExerciseCountForCategory(category);
          final icon = controller.getCategoryIconData(category);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: 160,
                child: _CategoryGridTile(
                  name: category,
                  count: count,
                  isListView: false,
                  icon: icon,
                onTap: () {},
              ),
            ),
          );
        });
      },
    );
  }
}

class _CategoryGridTile extends StatelessWidget {
  final String name;
  final int count;
  final bool isListView;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _CategoryGridTile({
    required this.name,
    required this.count,
    required this.isListView,
    required this.icon,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.glassBorder),
            ),
            padding: const EdgeInsets.all(16),
            child: isListView
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accentFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accentBorder),
                        ),
                        child: Icon(icon,
                            color: AppColors.accentPurple, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$count exercise${count == 1 ? '' : 's'}',
                              style: TextStyle(
                                  color: AppColors.textTertiary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accentFill,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.accentBorder),
                            ),
                            child: Icon(icon,
                                color: AppColors.accentPurple, size: 22),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count exercise${count == 1 ? '' : 's'}',
                        style: TextStyle(
                            color: AppColors.textTertiary, fontSize: 12),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
