import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/custom_list_model.dart';
import '../../core/constants/app_constants.dart';

class ListDetailScreen extends ConsumerStatefulWidget {
  final String listId;
  const ListDetailScreen({super.key, required this.listId});

  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<ListDetailScreen> {
  CustomListModel? _list;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  Future<void> _loadList() async {
    try {
      final list = await ref.read(listsRepositoryProvider).getListById(widget.listId);
      if (mounted) setState(() { _list = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = context.bg;
    final textColor = context.textPrimary;
    final subColor = context.textSecondary;
    final bodyTextColor = context.textSecondary;
    final dividerColor = context.border;
    final iconColor = context.textSecondary;
    final timeColor = context.muted;
    final placeholderBg = context.surface2;

    if (_loading) {
      return Scaffold(
        backgroundColor: bg,
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
      );
    }
    if (_list == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(backgroundColor: bg),
        body: Center(child: Text('List not found', style: TextStyle(color: subColor))),
      );
    }

    final list = _list!;
    final currentUid = ref.read(currentUserProvider)?.uid ?? '';
    final isOwner = list.userId == currentUid;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios, color: iconColor),
        ),
        title: Text(list.name, style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold)),
        actions: [
          if (isOwner)
            IconButton(
              onPressed: () => _showDeleteDialog(list, isDark),
              icon: Icon(Icons.delete_outline, color: context.textSecondary),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!list.isPublic) ...[
                      Icon(Icons.lock_outline, color: subColor, size: 14),
                      const SizedBox(width: 4),
                      Text('Private', style: GoogleFonts.inter(color: subColor, fontSize: 12)),
                      const SizedBox(width: 12),
                    ],
                    Text('By @${list.username}', style: GoogleFonts.inter(color: subColor, fontSize: 12)),
                    const SizedBox(width: 12),
                    Text('${list.mediaItems.length} films', style: GoogleFonts.inter(color: timeColor, fontSize: 12)),
                  ],
                ),
                if (list.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(list.description, style: GoogleFonts.inter(color: bodyTextColor, fontSize: 13, height: 1.5)),
                ],
              ],
            ),
          ),
          Divider(color: dividerColor, height: 0),
          Expanded(
            child: list.mediaItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.movie_outlined, color: context.muted, size: 64),
                        const SizedBox(height: 16),
                        Text('No films in this list', style: GoogleFonts.inter(color: subColor, fontSize: 16)),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    onReorder: isOwner ? (oldIdx, newIdx) => _reorder(oldIdx, newIdx, list) : (_, __) {},
                    itemCount: list.mediaItems.length,
                    itemBuilder: (ctx, i) {
                      final item = list.mediaItems[i];
                      final posterUrl = AppConstants.posterUrl(item.mediaPoster);
                      return ListTile(
                        key: ValueKey(item.mediaId),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${i + 1}', style: GoogleFonts.outfit(color: timeColor, fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: posterUrl.isNotEmpty
                                  ? Image.network(
                                      posterUrl,
                                      width: 40,
                                      height: 58,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(width: 40, height: 58, color: placeholderBg),
                                    )
                                  : Container(width: 40, height: 58, color: placeholderBg),
                            ),
                          ],
                        ),
                        title: Text(item.mediaTitle, style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w500)),
                        subtitle: Text(item.mediaType.toUpperCase(), style: GoogleFonts.inter(color: timeColor, fontSize: 11)),
                        trailing: isOwner ? Icon(Icons.drag_handle_rounded, color: timeColor) : null,
                        onTap: () => context.push('/movie/${item.mediaId}?tv=${item.mediaType == 'tv'}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _reorder(int oldIdx, int newIdx, CustomListModel list) async {
    if (newIdx > oldIdx) newIdx -= 1;
    final items = List<CustomListItem>.from(list.mediaItems);
    final item = items.removeAt(oldIdx);
    items.insert(newIdx, item);
    final updated = list.copyWith(mediaItems: items);
    setState(() => _list = updated);
    await ref.read(listsRepositoryProvider).updateList(updated);
  }

  void _showDeleteDialog(CustomListModel list, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.surface,
        title: Text(
          'Delete List',
          style: GoogleFonts.outfit(color: context.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${list.name}"?',
          style: GoogleFonts.inter(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: context.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final router = GoRouter.of(context);
              await ref.read(listsRepositoryProvider).deleteList(list.id);
              navigator.pop();
              router.pop();
            },
            child: Text('Delete', style: GoogleFonts.inter(color: const Color(0xFFE50914), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}



