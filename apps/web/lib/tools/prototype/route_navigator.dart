import 'package:flutter/material.dart';
import '../../prototype/prototype_routes.dart';

/// Collapsible panel listing all 56 routes grouped by module.
class RouteNavigator extends StatelessWidget {
  final ValueChanged<String> onNavigate;

  const RouteNavigator({super.key, required this.onNavigate});

  static const _modules = <_RouteModule>[
    _RouteModule('YoYo', Icons.explore_outlined, [
      _Route('Nearby', ProtoRoutes.yoyoNearby),
      _Route('Profile', ProtoRoutes.yoyoProfile),
      _Route('Connect', ProtoRoutes.yoyoConnect),
      _Route('Wave', ProtoRoutes.yoyoWave),
      _Route('Chat', ProtoRoutes.yoyoChat),
      _Route('Settings', ProtoRoutes.yoyoSettings),
      _Route('Filters', ProtoRoutes.yoyoFilters),
    ]),
    _RouteModule('Video', Icons.play_circle_outline, [
      _Route('Feed', ProtoRoutes.videoFeed),
      _Route('Following', ProtoRoutes.videoFollowing),
      _Route('Comments', ProtoRoutes.videoComments),
      _Route('Record', ProtoRoutes.videoRecord),
      _Route('Edit', ProtoRoutes.videoEdit),
      _Route('Creator', ProtoRoutes.videoCreator),
      _Route('Discover', ProtoRoutes.videoDiscover),
      _Route('Sound', ProtoRoutes.videoSound),
    ]),
    _RouteModule('Dating', Icons.favorite_outline, [
      _Route('Cards', ProtoRoutes.datingCards),
      _Route('Profile', ProtoRoutes.datingProfile),
      _Route('Match', ProtoRoutes.datingMatch),
      _Route('Matches', ProtoRoutes.datingMatches),
      _Route('Filters', ProtoRoutes.datingFilters),
      _Route('Likes', ProtoRoutes.datingLikes),
      _Route('Chat', ProtoRoutes.datingChat),
    ]),
    _RouteModule('Social', Icons.people_outline, [
      _Route('Feed', ProtoRoutes.socialFeed),
      _Route('Stumble', ProtoRoutes.socialStumble),
      _Route('Compose', ProtoRoutes.socialCompose),
      _Route('Story', ProtoRoutes.socialStory),
      _Route('Friends', ProtoRoutes.socialFriends),
      _Route('Events', ProtoRoutes.socialEvents),
    ]),
    _RouteModule('Shop', Icons.storefront_outlined, [
      _Route('Browse', ProtoRoutes.shopBrowse),
      _Route('Product', ProtoRoutes.shopProduct),
      _Route('Create', ProtoRoutes.shopCreate),
      _Route('Seller', ProtoRoutes.shopSeller),
      _Route('Deals', ProtoRoutes.shopDeals),
      _Route('Messages', ProtoRoutes.shopMessages),
      _Route('Auction', ProtoRoutes.shopAuction),
    ]),
    _RouteModule('Chat', Icons.chat_bubble_outline, [
      _Route('Inbox', ProtoRoutes.chatInbox),
      _Route('Conversation', ProtoRoutes.chatConversation),
    ]),
    _RouteModule('Profile', Icons.person_outline, [
      _Route('My Profile', ProtoRoutes.profileMy),
      _Route('Edit', ProtoRoutes.profileEdit),
      _Route('Settings', ProtoRoutes.profileSettings),
      _Route('Notifications', ProtoRoutes.profileNotifications),
    ]),
    _RouteModule('Auth', Icons.lock_outline, [
      _Route('Welcome', ProtoRoutes.authWelcome),
      _Route('Sign Up', ProtoRoutes.authSignup),
      _Route('Onboarding', ProtoRoutes.authOnboarding),
      _Route('Tutorial', ProtoRoutes.authTutorial),
      _Route('Method', ProtoRoutes.authMethod),
      _Route('Phone', ProtoRoutes.authPhone),
      _Route('OTP', ProtoRoutes.authOtp),
      _Route('Birthday', ProtoRoutes.authBirthday),
      _Route('Profile Setup', ProtoRoutes.authProfile),
      _Route('Login', ProtoRoutes.authLogin),
      _Route('Age Block', ProtoRoutes.authAgeBlock),
    ]),
    _RouteModule('Sponsored', Icons.campaign_outlined, [
      _Route('Inline', ProtoRoutes.sponsoredInline),
      _Route('Hub', ProtoRoutes.sponsoredHub),
      _Route('Create', ProtoRoutes.sponsoredCreate),
      _Route('Campaign', ProtoRoutes.sponsoredCampaign),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            'Routes',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ),
        for (final module in _modules)
          _ModuleSection(module: module, onNavigate: onNavigate),
      ],
    );
  }
}

class _ModuleSection extends StatelessWidget {
  final _RouteModule module;
  final ValueChanged<String> onNavigate;

  const _ModuleSection({required this.module, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        childrenPadding: const EdgeInsets.only(left: 8, bottom: 4),
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: Icon(module.icon, size: 14, color: Colors.white.withValues(alpha: 0.4)),
        title: Text(
          module.name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 14,
          color: Colors.white.withValues(alpha: 0.2),
        ),
        children: [
          for (final route in module.routes)
            InkWell(
              onTap: () => onNavigate(route.path),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        route.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                    Text(
                      route.path.split('/').last,
                      style: TextStyle(
                        fontSize: 9,
                        fontFamily: 'monospace',
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RouteModule {
  final String name;
  final IconData icon;
  final List<_Route> routes;
  const _RouteModule(this.name, this.icon, this.routes);
}

class _Route {
  final String label;
  final String path;
  const _Route(this.label, this.path);
}
