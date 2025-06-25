// lib/widgets/post_card_widget.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vibe_together_app/models/post_model.dart';
import 'package:vibe_together_app/screens/comment_screen.dart';
import 'package:vibe_together_app/services/post_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatelessWidget {
  final Post post;
  final PostService _postService = PostService();
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final bool isLiked =
        currentUserId != null && post.likes.contains(currentUserId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      clipBehavior: Clip.antiAlias, // Ensures the image respects card corners
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(post.authorPhotoUrl)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      timeago.format(post.timestamp.toDate()),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 12),
            if (post.text.isNotEmpty)
              Text(post.text, style: const TextStyle(fontSize: 16)),
            if (post.text.isNotEmpty && post.imageUrl != null)
              const SizedBox(height: 12),
            if (post.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(post.imageUrl!, fit: BoxFit.cover, width: double.infinity),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => _postService.toggleLike(post.id, post.likes),
                ),
                Text('${post.likes.length}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CommentScreen(postId: post.id)));
                  },
                ),
                Text('${post.commentCount}'),
                const Spacer(),
                IconButton(icon: const Icon(Icons.send_outlined), onPressed: () {}),
              ],
            )
          ],
        ),
      ),
    );
  }
}