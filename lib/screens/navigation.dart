import 'package:flutter/material.dart';
import 'package:mon_projet/screens/home.dart';
import 'package:mon_projet/screens/locationscreen.dart';
import 'package:mon_projet/screens/profilescreen.dart';
import 'package:mon_projet/screens/messagescreen.dart';

/// Root widget that hosts the animated bottom navigation bar.
class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  // Index de l'écran actuellement sélectionné
  int _selectedIndex = 0;

  // Screens associated with the four bottom‑navigation tabs.
  final List<Widget> _screens = [
    const HomePage(),
    const Profilescreen(),
    const Locationscreen(),
    const Messagescreen(),
  ];

  // Update the selected tab index when a nav item is tapped.
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // Build one bottom‑nav item: icon only when inactive, icon + label when active.
  Widget _buildNavItem(int index, IconData icon, String label) {
    bool selected = _selectedIndex == index; // Vérifie si cet onglet est sélectionné

    return GestureDetector(
      onTap: () => _onItemTapped(index), // Lorsqu'on appuie, change l'onglet
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), // Animation pour couleur et forme
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade50 : Colors.transparent, // Fond si sélectionné
          borderRadius: BorderRadius.circular(25), // Coins arrondis
        ),
        child: Row(
          children: [
            // Animation pour agrandir l'icône si sélectionnée
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: selected ? 1.2 : 1.0,
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                color: selected ? Colors.blue : Colors.grey.shade600,
                size: 26,
              ),
            ),
            // Afficher le label uniquement si sélectionné
            if (selected) ...[
              const SizedBox(width: 6), // espace entre icône et texte
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: selected ? 1 : 0, // effet fade in
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Total screen width is used to position the animated selection pill.
    double width = MediaQuery.of(context).size.width;
    // Width occupied by each item (4 tabs).
    double itemWidth = (width - 32) / 4;

    return Scaffold(
      // Show the currently selected tab with a subtle transition.
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          // Animation combinée slide + fade
          final slide = Tween<Offset>(
            begin: const Offset(0.1, 0), // départ légèrement à droite
            end: Offset.zero, // fin à sa position normale
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

          return FadeTransition(
            opacity: animation, // fondu en entrée/sortie
            child: SlideTransition(position: slide, child: child), // déplacement
          );
        },
        // Affiche l'écran sélectionné
        child: _screens[_selectedIndex],
      ),

      /// Custom bottom navigation bar with pill‑shaped background.
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16), // marge autour de la nav
        height: 70, // hauteur du container
        decoration: BoxDecoration(
          color: Colors.white, // fond blanc
          borderRadius: BorderRadius.circular(35), // coins arrondis
          boxShadow: const [
            BoxShadow(
              blurRadius: 25,
              color: Colors.black12,
              offset: Offset(0, 10), // ombre portée
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center, // centrer le contenu
          children: [
            /// Indicateur animé de l'onglet sélectionné
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              left: _selectedIndex * itemWidth + 16, // position horizontale selon l'index
              child: Container(
                width: itemWidth - 24,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15), // fond léger bleu
                  borderRadius: BorderRadius.circular(25), // coins arrondis
                ),
              ),
            ),

            // 🔹 Row contenant toutes les icônes et labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // espacement égal
              children: [
                _buildNavItem(0, Icons.home, "Home"),
                _buildNavItem(1, Icons.person, "Profile"),
                _buildNavItem(2, Icons.location_on, "Location"),
                _buildNavItem(3, Icons.message, "Messages"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}