import 'package:flutter/material.dart';
import 'package:pet_care/data/model/petbreed.dart';
import 'package:pet_care/data/repositories/petbreed_repository.dart';
import 'package:pet_care/features/home/pet_profile_ui/add_pet_screen/PetBreedSelectionScreen/pet_name_screen/pet_name_screen.dart';
import 'package:pet_care/widgets/bottom_nav_bar.dart';

class PetBreedSelectionScreen extends StatefulWidget {
  final String selectedPetType;
  const PetBreedSelectionScreen({super.key, required this.selectedPetType});

  @override
  State<PetBreedSelectionScreen> createState() => _PetBreedSelectionScreenState();
}

class _PetBreedSelectionScreenState extends State<PetBreedSelectionScreen> {
  String selectedBreed = "";
  int selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final double progressValue = 2 / 7;
    final List<PetBreed> breeds = PetBreedRepository.getBreeds(widget.selectedPetType);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Column(
            children: [
              const Text("Hồ sơ thú cưng",
                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(widget.selectedPetType, style: const TextStyle(color: Colors.black54, fontSize: 14)),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(child: Text("Bước 2/7", style: TextStyle(color: Colors.black, fontSize: 14))),
            ),
          ],
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
              minHeight: 4,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: breeds.length, 
          itemBuilder: (context, index) {
            final breed = breeds[index];
            final isSelected = selectedBreed == breed.name;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedBreed = breed.name;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF254EDB) : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      breed.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF254EDB) : Colors.black87,
                      ),
                    ),
                    Image.asset(breed.image, width: 180, height: 120),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedBreed.isEmpty ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PetNameScreen(
                        petType: widget.selectedPetType,
                        petBreed: selectedBreed,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF254EDB),
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 15), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Tiếp tục", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ),
          const SizedBox(height: 55), 
          BottomNavBar(
            selectedIndex: selectedIndex,
            onItemTapped: (index) {
              setState(() {
                selectedIndex = index;
              });

              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/home');
                  break;
                case 1:
                  Navigator.pushReplacementNamed(context, '/');
                  break;
                case 2:
                  Navigator.pushReplacementNamed(context, '/profile_screen');
                  break;
                case 3:
                  Navigator.pushReplacementNamed(context, '/');
                  break;
                case 4:
                  Navigator.pushReplacementNamed(context, '/AccountScreen');
                  break;
              }
            },
          ),
        ],
      ),
    );
  }
}
