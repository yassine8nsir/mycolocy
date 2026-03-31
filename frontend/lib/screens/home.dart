import 'package:flutter/material.dart';
import 'package:mon_projet/screens/category_screen.dart';
import 'package:mon_projet/screens/searchscreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Liste des catégories avec l'icône et le titre
  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.search, "title": "Find Housing"},
    {"icon": Icons.groups, "title": "Roommate"},
    {"icon": Icons.add_home_work, "title": "Publish"},
    {"icon": Icons.school, "title": "University"},
    {"icon": Icons.favorite, "title": "Favorites"},
  ];

  // Liste des logements disponibles
  final List<Map<String, String>> availableColocs = [
    {
      "title": "Modern Shared Apartment",
      "price": "420 TND / month",
      "university": "Near University of Tunis",
      "rooms": "3 Rooms",
      "owner": "Mr. Sami",
      "image": "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688"
    },
    {
      "title": "Student Studio",
      "price": "300 TND / month",
      "university": "Near University of Sfax",
      "rooms": "1 Room",
      "owner": "Ms. Leila",
      "image": "https://images.unsplash.com/photo-1493809842364-78817add7ffb"
    },
    {
      "title": "Spacious Shared House",
      "price": "500 TND / month",
      "university": "Near University of Monastir",
      "rooms": "4 Rooms",
      "owner": "Mr. Karim",
      "image": "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2"
    },
  ];

  // Pour savoir quelle catégorie est sélectionnée
  int selectedIndex = 0;

  /// Navigate to the screen for the tapped category.
  void _navigateToCategory(String title, IconData icon) {
    final Widget screen;
    if (title == 'Find Housing') {
      screen = const SearchScreen();
    } else {
      screen = CategoryScreen(title: title, icon: icon);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Couleur de fond de l'écran
      backgroundColor: Colors.grey[100],

      // SafeArea permet d'éviter que le contenu touche le notch, barre de statut ou bord de l'écran
      body: SafeArea(
        // SingleChildScrollView permet de scroller tout le contenu verticalement si l'écran est petit
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16), // padding autour de la colonne
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // aligne les enfants à gauche
            children: [
              /// HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16), // padding gauche et droite
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // espace entre le texte et l'avatar
                  children: [
                    // Nom de l'application
                    const Text(
                      "MyColoc",
                      style: TextStyle(
                        fontSize: 24, // taille du texte
                        fontWeight: FontWeight.bold, // texte en gras
                      ),
                    ),
                    // Avatar utilisateur
                    CircleAvatar(
                      radius: 22, // rayon du cercle
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        icon: const Icon(Icons.person, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12), // espace vertical entre header et description

              // Description
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Find or publish student accommodations in Tunisia",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),

              const SizedBox(height: 20),

              /// CHAMP DE RECHERCHE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search by university, city or owner...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true, // permet de mettre un fond au champ
                    fillColor: Colors.white, // couleur de fond du champ
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15), // arrondi du champ
                      borderSide: BorderSide.none, // pas de bordure
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// LISTE DES CATÉGORIES (HORIZONTAL)
              SizedBox(
                height: 120, // hauteur de la liste horizontale
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // scroll horizontal
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedIndex = index);
                        _navigateToCategory(
                          categories[index]['title'] as String,
                          categories[index]['icon'] as IconData,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300), // animation lors du changement
                        width: 110, // largeur du container catégorie
                        margin: const EdgeInsets.symmetric(horizontal: 8), // espace entre les containers
                        padding: const EdgeInsets.all(12), // padding interne
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.white, // couleur selon sélection
                          borderRadius: BorderRadius.circular(20), // arrondi du container
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.4)
                                  : Colors.black12, // ombre
                              blurRadius: 8, // flou de l'ombre
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, // centrer verticalement le contenu
                          children: [
                            Icon(
                              categories[index]['icon'],
                              color: isSelected ? Colors.white : Colors.black,
                              size: 28, // taille de l'icône
                            ),
                            const SizedBox(height: 10), // espace entre icône et texte
                            Text(
                              categories[index]['title'],
                              textAlign: TextAlign.center, // centrer le texte horizontalement
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              /// TITRE DES LOGEMENTS
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Available Colocations",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 15),

              /// LISTE DES LOGEMENTS
              Column(
                children: availableColocs.map((item) {
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // marge autour du container
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15), // arrondi du container
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6) // ombre
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // aligner à gauche
                      children: [
                        // IMAGE DU LOGEMENT
                        Container(
                          height: 160, // hauteur de l'image
                          width: double.infinity, // largeur maximale
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15)), // arrondi uniquement en haut
                            image: DecorationImage(
                              image: NetworkImage(item["image"]!), // image depuis internet
                              fit: BoxFit.cover, // remplir la zone de l'image
                            ),
                          ),
                        ),

                        // INFORMATIONS DU LOGEMENT
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // aligner texte à gauche
                            children: [
                              // TITRE
                              Text(item["title"]!,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),

                              // UNIVERSITÉ
                              Row(
                                children: [
                                  const Icon(Icons.school,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 5), // espace entre icône et texte
                                  Text(item["university"]!,
                                      style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // NOMBRE DE PIÈCES
                              Row(
                                children: [
                                  const Icon(Icons.meeting_room,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(item["rooms"]!,
                                      style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // NOM DU PROPRIÉTAIRE
                              Row(
                                children: [
                                  const Icon(Icons.person,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(item["owner"]!,
                                      style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // PRIX DU LOGEMENT
                              Text(item["price"]!,
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20), // espace final en bas
            ],
          ),
        ),
      ),
    );
  }
}