import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/community_post.dart';
import '../../components/cropguard_card.dart';
import '../../components/cropguard_text_field.dart';
import '../../components/offline_banner.dart';
import '../../components/primary_button.dart';
import 'community_provider.dart';

/// Equivalent of CommunityScreen.kt
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OfflineBanner(isOffline: provider.isOffline),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    child: Text('← Back',
                        style: TextStyle(
                            color: colors.muted, fontSize: 14)),
                  ),
                  const SizedBox(height: 8),
                  Text('Community',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // Composer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CropGuardCard(
                child: Column(
                  children: [
                    CropGuardTextField(
                      value: provider.composerText,
                      onChanged: provider.onComposerChanged,
                      label: 'Share an update',
                      placeholder: 'What's happening on your farm?',
                    ),
                    if (provider.selectedImageUri != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: provider.selectedImageUri!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.image_outlined,
                              color: colors.primary),
                          onPressed: () async {
                            final picker = ImagePicker();
                            final file = await picker.pickImage(
                                source: ImageSource.gallery);
                            provider.onImageSelected(file?.path);
                          },
                        ),
                        PrimaryButton(
                          text: 'Post',
                          isLoading: provider.isPosting,
                          onPressed: provider.postUpdate,
                        ),
                      ],
                    ),
                    if (provider.errorMessage != null)
                      GestureDetector(
                        onTap: provider.clearError,
                        child: Text(provider.errorMessage!,
                            style: TextStyle(
                                color: colors.error, fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Posts list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) =>
                    _PostCard(post: provider.posts[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CropGuardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('${post.author} • ${post.tag}',
              style: TextStyle(color: colors.muted, fontSize: 11)),
          if (post.imageUri != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: post.imageUri!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.broken_image),
                ),
              ),
            ),
          const SizedBox(height: 6),
          Text(post.body,
              style: Theme.of(context).textTheme.bodySmall),
          if (post.expertResponse != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.healthyBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Expert Response',
                      style: TextStyle(
                          color: colors.healthy,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(post.expertResponse!,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
