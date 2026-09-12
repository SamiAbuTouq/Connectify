import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectify/services/firestore_paths.dart';

/// A reusable bookmark/heart toggle button for providers.
///
/// Listens to `favorites/{currentUid}/providers/{providerId}` in real-time.
/// Tapping it creates or deletes the document accordingly.
class FavoriteButton extends StatefulWidget {
  final String providerId;
  final String? currentUid;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool isHeart;
  final VoidCallback? onToggled;

  const FavoriteButton({
    super.key,
    required this.providerId,
    this.currentUid,
    this.size = 24.0,
    this.activeColor = const Color(0xFF111111),
    this.inactiveColor = const Color(0xFF9CA3AF),
    this.isHeart = true,
    this.onToggled,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String get _uid =>
      widget.currentUid ?? FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentReference<Map<String, dynamic>>? get _favDocRef {
    if (_uid.isEmpty || widget.providerId.isEmpty) return null;
    return FirebaseFirestore.instance
        .collection(FirestorePaths.favorites)
        .doc(_uid)
        .collection(FirestorePaths.favoritedProviders)
        .doc(widget.providerId);
  }

  Future<void> _toggleFavorite(bool isCurrentlyFavorited) async {
    if (_isToggling) return;
    final docRef = _favDocRef;
    if (docRef == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to save bookmarks.')),
        );
      }
      return;
    }

    _animController.forward(from: 0.0);
    _isToggling = true;

    try {
      if (isCurrentlyFavorited) {
        await docRef.delete();
      } else {
        await docRef.set({
          'createdAt': FieldValue.serverTimestamp(),
          'providerId': widget.providerId,
        });
      }
      widget.onToggled?.call();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update bookmark: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isToggling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final docRef = _favDocRef;

    if (docRef == null) {
      return Icon(
        widget.isHeart ? Icons.favorite_border_rounded : Icons.bookmark_border_rounded,
        size: widget.size,
        color: widget.inactiveColor,
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docRef.snapshots(),
      builder: (context, snapshot) {
        final isFavorited = snapshot.data?.exists ?? false;

        final iconData = widget.isHeart
            ? (isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded)
            : (isFavorited ? Icons.bookmark_rounded : Icons.bookmark_border_rounded);

        final iconColor = isFavorited ? widget.activeColor : widget.inactiveColor;

        return ScaleTransition(
          scale: _scaleAnimation,
          child: IconButton(
            iconSize: widget.size,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: widget.size * 1.2,
            icon: Icon(
              iconData,
              color: iconColor,
              size: widget.size,
            ),
            tooltip: isFavorited ? 'Remove from Bookmarks' : 'Add to Bookmarks',
            onPressed: () => _toggleFavorite(isFavorited),
          ),
        );
      },
    );
  }
}
