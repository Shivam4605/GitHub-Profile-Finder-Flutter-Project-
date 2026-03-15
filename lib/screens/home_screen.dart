import 'package:flutter/material.dart';
import 'package:github_repo/api_services/api_service.dart';
import 'package:github_repo/models/profile_model.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();

  ProfileModel? profile;
  bool isLoading = false;
  String error = "";

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _bg = Color(0xFF0D0D0D);
  static const _surface = Color(0xFF161616);
  static const _card = Color(0xFF1C1C1C);
  static const _border = Color(0xFF2A2A2A);
  static const _accent = Color(0xFF00E5A0);
  static const _accentDim = Color(0xFF00B37A);
  static const _textPrimary = Color(0xFFF0F0F0);
  static const _textSecondary = Color(0xFF8A8A8A);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> searchProfile() async {
    FocusScope.of(context).unfocus();
    final username = controller.text.trim();

    if (username.isEmpty) {
      setState(() => error = "Please enter a username");
      return;
    }

    setState(() {
      isLoading = true;
      error = "";
      profile = null;
    });
    _animController.reset();

    try {
      final data = await ApiService().getUser(userName: username);
      setState(() => profile = data);
      _animController.forward();
    } catch (_) {
      setState(() => error = "User not found");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> openGithubProfile({required String username}) async {
    final url = Uri.parse("https://github.com/$username");
    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) _showLaunchError();
    } catch (_) {
      _showLaunchError();
    }
  }

  void _showLaunchError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2A1010),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFFF6B6B),
              size: 18,
            ),
            SizedBox(width: 10),
            Text(
              "Could not open GitHub profile",
              style: TextStyle(
                color: Color(0xFFFF6B6B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _bg,
        colorScheme: const ColorScheme.dark(
          primary: _accent,
          surface: _surface,
        ),
      ),
      child: Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeadline(),
                const SizedBox(height: 28),
                _buildSearchField(),
                const SizedBox(height: 16),
                _buildSearchButton(),
                const SizedBox(height: 28),
                if (isLoading) _buildLoader(),
                if (error.isNotEmpty) _buildError(),
                if (profile != null) ...[
                  _buildProfileCard(),
                  const SizedBox(height: 16),
                  _buildViewProfileButton(userName: profile!.userName ?? ""),
                  SizedBox(height: 20),
                  Text(
                    "Created By : Shivam Kolekar",
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: _accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "GitHub Finder",
            style: TextStyle(
              color: _textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: _border, height: 1),
      ),
    );
  }

  Widget _buildHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SEARCH",
          style: TextStyle(
            color: _textSecondary,
            fontSize: 11,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: "GitHub ",
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: "Profile",
                style: TextStyle(
                  color: _accent,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: _textPrimary, fontSize: 15),
        onSubmitted: (_) => searchProfile(),
        decoration: InputDecoration(
          hintText: "Enter GitHub username…",
          hintStyle: const TextStyle(color: _textSecondary, fontSize: 15),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _textSecondary,
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    setState(() {});
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    color: _textSecondary,
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : searchProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.black,
          disabledBackgroundColor: _accentDim.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Search Profile",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildViewProfileButton({required String userName}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => openGithubProfile(username: userName),
        icon: const Icon(Icons.open_in_new_rounded, size: 17),
        label: const Text(
          "View on GitHub",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _accent,
          side: const BorderSide(color: _accent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(_accent),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1010),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A1515)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFF6B6B),
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            error,
            style: const TextStyle(
              color: Color(0xFFFF6B6B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_accent, Color(0xFF00A8FF)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildAvatar(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile!.name ?? "No Name",
                                style: const TextStyle(
                                  color: _textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "@${controller.text.trim()}",
                                style: const TextStyle(
                                  color: _accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if ((profile!.bio ?? "").isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: Text(
                          profile!.bio!,
                          style: const TextStyle(
                            color: _textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        _buildStat(
                          "Followers",
                          profile!.follower ?? "0",
                          Icons.people_outline_rounded,
                        ),
                        _buildStatDivider(),
                        _buildStat(
                          "Following",
                          profile!.following ?? "0",
                          Icons.person_outline_rounded,
                        ),
                        _buildStatDivider(),
                        _buildStat(
                          "Repos",
                          profile!.repocount ?? "0",
                          Icons.folder_outlined,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: _textSecondary,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Member since  ${profile!.createdAt ?? "—"}",
                          style: const TextStyle(
                            color: _textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final imageUrl = profile!.profileImage ?? "";

    return CircleAvatar(
      radius: 28,
      backgroundColor: _accent.withOpacity(0.15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,

                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(_accent),
                    ),
                  );
                },

                errorBuilder: (_, __, ___) => _avatarFallback(),
              )
            : _avatarFallback(),
      ),
    );
  }

  Widget _avatarFallback() {
    final name = profile!.name ?? "?";
    return Container(
      width: 56,
      height: 56,
      color: _accent.withOpacity(0.15),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : "?",
        style: const TextStyle(
          color: _accent,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _accent, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() => Container(width: 1, height: 44, color: _border);

  Widget _buildDivider() => Container(height: 1, color: _border);
}
