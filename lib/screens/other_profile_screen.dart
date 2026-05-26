import 'dart:ui';

import 'package:chat_app/themes/AppColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OtherProfileScreen extends StatelessWidget {
  const OtherProfileScreen({
    super.key,
    required this.otherUid,
    required this.otherUserName,
    this.otherUserPic,
  });

  final String otherUid;
  final String otherUserName;
  final String? otherUserPic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.7),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.borderOrDivider.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        otherUserName,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(otherUid)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            );
          }

          final data = snap.data!.data() as Map<String, dynamic>? ?? {};
          final name = data['name'] ?? otherUserName;
          final pic = data['profilePic'] as String? ?? otherUserPic;
          final isOnline = data['isOnline'] ?? false;
          final lastSeen = data['lastSeen'] as Timestamp?;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 40),
            child: Column(
              children: [
                // ---- Avatar with glow ----
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: pic == null || pic.isEmpty
                          ? const LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : null,
                      image: pic != null && pic.isNotEmpty
                          ? DecorationImage(
                        image: NetworkImage(pic),
                        fit: BoxFit.cover,
                      )
                          : null,
                      border: Border.all(
                        color: AppColors.borderLight.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: pic == null || pic.isEmpty
                        ? Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 48,
                        ),
                      ),
                    )
                        : null,
                  ),
                ),

                const SizedBox(height: 24),

                // ---- Name ----
                Text(
                  name,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 12),

                // ---- Online Status Badge ----
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOnline
                        ? AppColors.onlineOrSuccess.withOpacity(0.12)
                        : AppColors.textMuted.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOnline
                          ? AppColors.onlineOrSuccess.withOpacity(0.2)
                          : AppColors.textMuted.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline
                              ? AppColors.onlineOrSuccess
                              : AppColors.textMuted,
                          boxShadow: isOnline
                              ? [
                            BoxShadow(
                              color: AppColors.onlineOrSuccess
                                  .withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOnline
                            ? 'Online'
                            : lastSeen != null
                            ? 'Last seen ${_formatDate(lastSeen.toDate())}'
                            : 'Offline',
                        style: GoogleFonts.inter(
                          color: isOnline
                              ? AppColors.onlineOrSuccess
                              : AppColors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ---- Info Cards ----
                _buildInfoCard(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: data['email'] ?? 'Not available',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Member since',
                  value: data['createdAt'] != null
                      ? _formatDate((data['createdAt'] as Timestamp).toDate())
                      : 'Unknown',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderOrDivider.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}