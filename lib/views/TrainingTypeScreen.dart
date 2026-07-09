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
        return RefreshIndicator(
          onRefresh: () => controller.forceSync(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 200,
              child: Center(
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
    return RefreshIndicator(
      onRefresh: () => controller.forceSync(),
      child: ReorderableListView.builder(
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
            final iconAssetPath = controller.getCategoryIconAssetPath(category);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CategoryGridTile(
              name: category,
              count: count,
              isListView: true,
              iconAssetPath: iconAssetPath,
              showDragHandle: true,
              onTap: () =>
                  Get.to(() => HomePageContent(trainingType: category)),
            ));
          });
        },
      ),
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
    return RefreshIndicator(
      onRefresh: () => controller.forceSync(),
      child: GridView.builder(
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
            final iconAssetPath = controller.getCategoryIconAssetPath(category);
            return _CategoryGridTile(
              name: category,
              count: count,
              isListView: false,
              iconAssetPath: iconAssetPath,
              onTap: () =>
                  Get.to(() => HomePageContent(trainingType: category)),
              onLongPress: () => Get.dialog(
                  CategoryOptionsDialog(categoryName: category)),
            );
          });
        },
      ),
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
          final iconAssetPath = controller.getCategoryIconAssetPath(category);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: 160,
                child: _CategoryGridTile(
                  name: category,
                  count: count,
                  isListView: false,
                  iconAssetPath: iconAssetPath,
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
  final String iconAssetPath;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool showDragHandle;

  const _CategoryGridTile({
    required this.name,
    required this.count,
    required this.isListView,
    required this.iconAssetPath,
    required this.onTap,
    this.onLongPress,
    this.showDragHandle = false,
  });

  Widget _buildIcon({double size = 22}) {
    if (iconAssetPath == 'FLUTTER_ICON:dumbbell') {
      return Icon(
        Icons.fitness_center_rounded,
        size: size,
        color: Colors.white,
      );
    }
    return Image.asset(
      iconAssetPath,
      width: size,
      height: size,
      color: Colors.white,
      colorBlendMode: BlendMode.srcIn,
      fit: BoxFit.contain,
    );
  }

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
                      // Drag handle on the left
                      if (showDragHandle) ...[
                        Icon(
                          Icons.drag_indicator_rounded,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                      ],
                      // Icon container
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accentFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accentBorder),
                        ),
                        child: _buildIcon(),
                      ),
                      const SizedBox(width: 16),
                      // Name and count
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
                      // Chevron arrow on the right
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textTertiary,
                        size: 22,
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
                            child: _buildIcon(),
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
