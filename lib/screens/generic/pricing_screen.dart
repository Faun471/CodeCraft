import 'package:codecraft/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  _PricingScreenState createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  int _selectedCardIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Header(),
              const SizedBox(height: 20),
              PricingCards(
                selectedCardIndex: _selectedCardIndex,
                onCardSelected: _toggleCardActive,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleCardActive(int index) {
    setState(() {
      _selectedCardIndex = index;
    });
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Our Pricing',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class PricingCards extends StatelessWidget {
  final int selectedCardIndex;
  final ValueChanged<int> onCardSelected;

  const PricingCards({
    super.key,
    required this.selectedCardIndex,
    required this.onCardSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double screenWidth = constraints.maxWidth;
        const double minItemWidth = 300.0;
        final int numItemsInRow = (screenWidth / minItemWidth).floor();
        final double cardWidth =
            (screenWidth - (numItemsInRow) * 5) / numItemsInRow <= minItemWidth
                ? screenWidth / numItemsInRow
                : minItemWidth;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              PricingCard(
                title: 'Basic',
                price: '\$9.99',
                features: const [
                  '3 Apprentices',
                  'Up to 10 active challenges',
                  'Up to 3 active quizzes',
                  'Up to 1 active code-clash'
                ],
                width: cardWidth,
                isActive: selectedCardIndex == 0,
                onCardTapped: () => onCardSelected(0),
              ),
              PricingCard(
                title: 'Professional',
                price: '\$24.99',
                features: const [
                  '10 Apprentices',
                  'Up to 50 active challenges',
                  'Up to 10 active quizzes',
                  'Up to 2 active code-clashes'
                ],
                isActive: selectedCardIndex == 1,
                width: cardWidth,
                onCardTapped: () => onCardSelected(1),
              ),
              PricingCard(
                title: 'Master',
                price: '\$39.99',
                features: const [
                  'Unlimited Apprentices',
                  'Unlimited active challenges',
                  'Unlimited active quizzes',
                  'Up to 3 active code-clashes'
                ],
                width: cardWidth,
                isActive: selectedCardIndex == 2,
                onCardTapped: () => onCardSelected(2),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PricingCard extends StatefulWidget {
  final String title;
  final String price;
  final List<String> features;
  final double width;
  final double height;
  final VoidCallback onCardTapped;
  final bool isActive;

  const PricingCard({
    super.key,
    required this.title,
    required this.price,
    required this.features,
    this.height = 400,
    this.isActive = false,
    required this.width,
    required this.onCardTapped,
  });

  @override
  PricingCardState createState() => PricingCardState();
}

class PricingCardState extends State<PricingCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onCardTapped,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          if (widget.isActive) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }

          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Card(
            elevation: widget.isActive ? 10 : 5,
            color: widget.isActive
                ? Theme.of(context).primaryColor
                : Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ThemeUtils.getTextColorForBackground(
                        widget.isActive
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.price,
                    style: TextStyle(
                      fontSize: 28,
                      color: ThemeUtils.getTextColorForBackground(
                        widget.isActive
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardColor,
                      ),
                    ),
                  ),
                  Divider(color: widget.isActive ? Colors.white : Colors.grey),
                  for (var feature in widget.features)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        feature,
                        style: TextStyle(
                          color: ThemeUtils.getTextColorForBackground(
                            widget.isActive
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).cardColor,
                          ),
                        ),
                      ),
                    ),
                  const Expanded(child: SizedBox(height: 10)),
                  ElevatedButton(
                    style:
                        Theme.of(context).elevatedButtonTheme.style!.copyWith(
                              backgroundColor: WidgetStateProperty.all(
                                widget.isActive
                                    ? Colors.white
                                    : Theme.of(context).primaryColor,
                              ),
                            ),
                    onPressed: () {},
                    child: Text(
                      'Learn More',
                      style: TextStyle(
                        color: ThemeUtils.getTextColorForBackground(
                          !widget.isActive
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
