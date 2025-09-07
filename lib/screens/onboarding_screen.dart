import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const String onboardingCompleteKey = 'onboarding_complete';

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingCompleteKey, true);  // Mark onboarding as completed
    
    if (context.mounted) {
      context.go('/auth/signup');  // Navigate to signup page
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF79CBC2);
    final backgroundColor = Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Theme.of(context).scaffoldBackgroundColor;

    return OnBoardingSlider(
      finishButtonText: 'Kom i gang',
      onFinish: () => _completeOnboarding(context),
      finishButtonStyle: FinishButtonStyle(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      // Let the package use its default button
      skipTextButton: Text(
        'Spring over',
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).brightness == Brightness.dark
              ? primaryColor  // Teal for dark mode
              : Colors.black, // Black for light mode
          fontWeight: FontWeight.w600,
        ),
      ),
      controllerColor: primaryColor,
      totalPage: 6,
      headerBackgroundColor: backgroundColor,
      pageBackgroundColor: backgroundColor,
      centerBackground: false, // Don't center the background
      speed: 1.8,
      pageBodies: [
        // Slide 1 - Velkommen til DinnerHelp
        _buildSlideBody(
          context,
          icon: Icons.restaurant_menu,
          title: 'Madlavning gjort enkelt',
          description: 'DinnerHelp forbinder dig med dygtige helpers – passionerede madelskere og professionelle kokke, der kommer hjem til dig og laver mad. Du får mere tid, mindre stress – og lækker mad i hverdagen.',
          showSwipeHint: true,
        ),
        
        // Slide 2 - Vælg din helper
        _buildSlideBody(
          context,
          icon: Icons.person_search,
          title: 'Menuen tilpasses dig',
          description: 'Når du har booket en helper, aftaler du menuen direkte med ham eller hende i chatten. Du kan selv komme med ønsker – eller lade din helper foreslå retter. Herefter får du en indkøbsliste, så du ved præcis, hvad du skal købe ind.',
          showSwipeHint: true,
        ),
        
        // Slide 3 - Indkøb gjort nemt
        _buildSlideBody(
          context,
          icon: Icons.shopping_cart,
          title: 'Du handler selv varerne',
          description: 'Din helper sender en indkøbsliste, så du nemt kan handle ind. På den måde har du fuld kontrol over kvalitet, mærker og pris.',
          showSwipeHint: true,
        ),
        
        // Slide 4 - Alt på plads fra start
        _buildSlideBody(
          context,
          icon: Icons.chat,
          title: 'Chat direkte med din helper',
          description: 'Når du vælger tidspunkt (minimum 3 timer), bruger du chatten til at aftale menuen og få indkøbslisten. Så er alt på plads, inden besøget.',
          showSwipeHint: true,
        ),
        
        // Slide 5 - Tryghed først
        _buildSlideBody(
          context,
          icon: Icons.verified_user,
          title: 'Tryg og sikker booking',
          description: 'Alle helpers er kvalitetssikret og nøje udvalgt. Hver booking er dækket af DinnerHelp-garantien, så du kan trygt overlade køkkenet til os.',
          showSwipeHint: true,
        ),
        
        // Slide 6 - Klar til at komme i gang
        _buildSlideBody(
          context,
          icon: Icons.rocket_launch,
          title: 'Din hjælp i køkkenet er kun ét klik væk',
          description: 'Med DinnerHelp får du en enkel løsning på hverdagsmaden. Book en helper i appen – resten tager vi os af.',
          showSwipeHint: false,
        ),
      ],
      background: [
        // Simple image containers like the example
        _buildSlideBackground(context),
        _buildSlideBackground(context),
        _buildSlideBackground(context),
        _buildSlideBackground(context),
        _buildSlideBackground(context),
        _buildSlideBackground(context),
      ],
    );
  }

  Widget _buildSlideBody(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool showSwipeHint,
  }) {
    final primaryColor = const Color(0xFF79CBC2);
    
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 280), // Space for image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black87
                  : Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black54
                  : Colors.white70,
            ),
          ),
          const Spacer(),
          if (showSwipeHint)
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Text(
                'Swipe til højre for at fortsætte',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black38
                      : Colors.white38,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlideBackground(BuildContext context) {
    // Simple Image.asset like the example
    return Image.asset(
      'assets/images/logo_brand.png',
      width: MediaQuery.of(context).size.width,
      height: 250,
      fit: BoxFit.cover,
    );
  }
}