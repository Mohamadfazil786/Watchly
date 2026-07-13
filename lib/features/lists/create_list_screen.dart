import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/custom_list_model.dart';
import '../../core/constants/app_constants.dart';

class CreateListScreen extends ConsumerStatefulWidget {
  const CreateListScreen({super.key});

  @override
  ConsumerState<CreateListScreen> createState() => _CreateListScreenState();
}

class _CreateListScreenState extends ConsumerState<CreateListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _movieSearchCtrl = TextEditingController();

  bool _isPublic = true;
  bool _isRanked = true;
  bool _isSearchingMovies = false;
  bool _isSaving = false;

  final List<Map<String, String>> _selectedMovies = [];
  List<Map<String, String>> _searchResults = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _movieSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchMovies(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearchingMovies = true);
    try {
      final movies = await ref.read(moviesRepositoryProvider).searchMovies(query);
      if (mounted) {
        setState(() {
          _searchResults = movies.take(6).map((m) => {
            'id': m.id,
            'title': m.title,
            'poster': m.posterPath,
            'type': 'movie',
          }).toList();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _searchResults = []);
    } finally {
      if (mounted) setState(() => _isSearchingMovies = false);
    }
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final user = ref.read(currentUserProvider);
    final listName = _nameController.text.trim();

    final mediaItems = _selectedMovies
        .map((m) => CustomListItem(
              mediaId: m['id']!,
              mediaTitle: m['title']!,
              mediaPoster: m['poster']!,
              mediaType: m['type'] ?? 'movie',
            ))
        .toList();

    final list = CustomListModel(
      id: 'list_${DateTime.now().millisecondsSinceEpoch}',
      userId: user?.uid ?? '',
      username: user?.username ?? '',
      name: listName,
      description: _descController.text.trim(),
      isPublic: _isPublic,
      isRanked: _isRanked,
      mediaItems: mediaItems,
      createdAt: DateTime.now(),
    );

    final uid = list.userId;
    try {
      await ref.read(listsRepositoryProvider).createList(list);
      ref.invalidate(userListsProvider(uid));
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create list: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = context.bg;
    final cardBg = context.surface;
    final inputBg = context.surface2;
    final textColor = context.textPrimary;
    final hintColor = context.textSecondary;
    final labelColor = context.textSecondary;
    final dividerColor = context.border;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.close, color: context.textSecondary),
        ),
        title: Text(
          'Create List',
          style: GoogleFonts.outfit(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isSaving ? null : _create,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFE50914),
                      ),
                    )
                  : Text(
                      'Create',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFE50914),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── List Name ──
            Text('List Name', style: GoogleFonts.inter(color: labelColor, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              validator: (v) => (v == null || v.isEmpty) ? 'Enter a list name' : null,
              decoration: _inputDecoration('e.g. Top 10 Sci-Fi Films', inputBg, hintColor),
            ),
            const SizedBox(height: 20),

            // ── Description ──
            Text('Description (optional)', style: GoogleFonts.inter(color: labelColor, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descController,
              style: TextStyle(color: textColor),
              maxLines: 3,
              decoration: _inputDecoration('Describe your list...', inputBg, hintColor),
            ),
            const SizedBox(height: 24),

            // ── Options (Public + Ranked) ──
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.border),
              ),
              child: Column(
                children: [
                  _OptionTile(
                    icon: Icons.public_rounded,
                    title: 'Public List',
                    subtitle: 'Others can discover and follow this list',
                    value: _isPublic,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _isPublic = v),
                  ),
                  Divider(color: dividerColor, height: 0, indent: 56),
                  _OptionTile(
                    icon: Icons.format_list_numbered_rounded,
                    title: 'Ranked',
                    subtitle: 'Display position numbers for each film',
                    value: _isRanked,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _isRanked = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Add Films ──
            Row(
              children: [
                Text('Add Films', style: GoogleFonts.outfit(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                if (_selectedMovies.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_selectedMovies.length}',
                      style: GoogleFonts.outfit(color: const Color(0xFFE50914), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Selected movies strip (reorderable)
            if (_selectedMovies.isNotEmpty) ...[
              SizedBox(
                height: _isRanked ? 158 : 130,
                child: ReorderableListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedMovies.length,
                  onReorder: (oldIdx, newIdx) {
                    setState(() {
                      if (newIdx > oldIdx) newIdx--;
                      final item = _selectedMovies.removeAt(oldIdx);
                      _selectedMovies.insert(newIdx, item);
                    });
                  },
                  itemBuilder: (_, i) {
                    final m = _selectedMovies[i];
                    final poster = m['poster'] ?? '';
                    return Container(
                      key: ValueKey('${m['id']}_$i'),
                      width: 80,
                      margin: const EdgeInsets.only(right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: poster.isNotEmpty
                                      ? Image.network(
                                          AppConstants.posterUrl(poster),
                                          width: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _posterFallback(isDark),
                                        )
                                      : _posterFallback(isDark),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedMovies.removeAt(i)),
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isRanked) ...[
                            const SizedBox(height: 4),
                            Text('#${i + 1}', style: GoogleFonts.outfit(color: const Color(0xFFE50914), fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Movie search field
            TextField(
              controller: _movieSearchCtrl,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Search films to add...',
                hintStyle: TextStyle(color: hintColor),
                filled: true,
                fillColor: inputBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.5)),
                prefixIcon: Icon(Icons.search, color: hintColor),
                suffixIcon: _isSearchingMovies
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE50914))),
                      )
                    : null,
              ),
              onChanged: _searchMovies,
            ),

            // Search results dropdown
            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.border),
                ),
                child: Column(
                  children: _searchResults.map((m) {
                    final alreadyAdded = _selectedMovies.any((s) => s['id'] == m['id']);
                    return ListTile(
                      leading: m['poster']!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                AppConstants.posterUrl(m['poster']!),
                                width: 36,
                                height: 54,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(Icons.movie, color: hintColor, size: 36),
                              ),
                            )
                          : Icon(Icons.movie, color: hintColor),
                      title: Text(m['title']!, style: GoogleFonts.inter(color: textColor, fontSize: 13)),
                      trailing: alreadyAdded
                          ? const Icon(Icons.check_circle, color: Color(0xFF00C853), size: 20)
                          : const Icon(Icons.add_circle_outline, color: Color(0xFFE50914), size: 20),
                      onTap: alreadyAdded
                          ? null
                          : () => setState(() {
                                _selectedMovies.add(m);
                                _movieSearchCtrl.clear();
                                _searchResults = [];
                              }),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _posterFallback(bool isDark) => Container(
        color: context.surface2,
        child: Center(child: Icon(Icons.movie_outlined, color: context.muted, size: 24)),
      );

  InputDecoration _inputDecoration(String hint, Color fillColor, Color hintColor) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: hintColor),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.5)),
    );
  }
}

// ─── Option Toggle Tile ───────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value
                  ? const Color(0xFFE50914).withValues(alpha: 0.15)
                  : (context.border),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: value ? const Color(0xFFE50914) : (context.textSecondary), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: GoogleFonts.inter(color: context.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFFE50914),
            activeTrackColor: const Color(0xFFE50914).withValues(alpha: 0.35),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}



