import 'dart:io';

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
import '../settings/language_provider.dart';
import 'community_provider.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final colors = context.colors;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text('Community',
            style: Theme.of(context).textTheme.titleLarge),
        leading: canPop
            ? const BackButton()
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/home'),
              ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OfflineBanner(isOffline: provider.isOffline),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CropGuardCard(
                child: Column(
                  children: [
                    CropGuardTextField(
                      value: provider.composerText,
                      onChanged: provider.onComposerChanged,
                      label: 'Share an update',
                      placeholder: "What's happening on your farm?",
                    ),
                    if (provider.selectedImageUri != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: File(provider.selectedImageUri!)
                                      .existsSync()
                                  ? Image.file(
                                      File(provider.selectedImageUri!),
                                      height: 160,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : const SizedBox(
                                      height: 160,
                                      child: Center(
                                          child: Icon(Icons.broken_image)),
                                    ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Material(
                                color: Colors.black54,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: provider.clearSelectedImage,
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.close,
                                        color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (provider.isUploadingImage)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Uploading image…',
                              style: TextStyle(
                                  color: colors.muted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.image_outlined,
                              color: colors.primary),
                          onPressed: provider.isPosting ||
                                  provider.isUploadingImage
                              ? null
                              : () async {
                                  final picker = ImagePicker();
                                  final file = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  provider.onImageSelected(file?.path);
                                },
                        ),
                        IconButton(
                          icon: Icon(
                            provider.isListening ? Icons.mic : Icons.mic_none,
                            color: provider.isListening
                                ? Colors.red
                                : colors.primary,
                          ),
                          onPressed: provider.isPosting
                              ? null
                              : () {
                                  final lang = context
                                      .read<LanguageProvider>()
                                      .currentLanguage
                                      .code;
                                  provider.toggleListening(localeId: lang);
                                },
                        ),
                        const Spacer(),
                        PrimaryButton(
                          text: 'Post',
                          isLoading: provider.isPosting,
                          onPressed: provider.isPosting ? null : provider.postUpdate,
                        ),
                      ],
                    ),
                    if (provider.errorMessage != null)
                      GestureDetector(
                        onTap: provider.clearError,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            provider.errorMessage!,
                            style: TextStyle(
                                color: colors.error, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: provider.posts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.forum_outlined,
                                size: 48, color: colors.muted),
                            const SizedBox(height: 12),
                            Text(
                              'No posts yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Be the first to share an update with other farmers.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: colors.muted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
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

String _relativeTimestamp(int ms) {
  final then = DateTime.fromMillisecondsSinceEpoch(ms);
  final diff = DateTime.now().difference(then);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${then.day}/${then.month}/${then.year}';
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Report Post'),
            content: const Text(
                'Are you sure you want to report this post for inappropriate content?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<CommunityProvider>().reportPost(post.id);
                },
                child:
                    const Text('Report', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: CropGuardCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${post.author} • ${post.tag} • ${_relativeTimestamp(post.timestamp)}',
              style: TextStyle(color: colors.muted, fontSize: 11),
            ),
            const SizedBox(height: 6),
            Text(post.body, style: Theme.of(context).textTheme.bodyMedium),
            if (post.imageUri != null &&
                (post.imageUri!.startsWith('http://') ||
                    post.imageUri!.startsWith('https://')))
              Padding(
                padding: const EdgeInsets.only(top: 8),
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
      ),
    );
  }
}
