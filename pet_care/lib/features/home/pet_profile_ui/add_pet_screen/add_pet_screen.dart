import 'package:flutter/material.dart';
import 'package:pet_care/features/home/pet_profile_ui/add_pet_screen/PetBreedSelectionScreen/PetBreedSelectionScreen.dart';



class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {

  final int currentStep = 1;
  final int totalSteps = 7;
  int selectedIndex = 2; 


  @override
  Widget build(BuildContext context) {
    final double progressValue = currentStep / totalSteps; 

    return Scaffold(
      backgroundColor: Colors.white,
    
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90), 
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,

          title: Column(
            children: const [
              Text(
                "Hồ sơ thú cưng",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Giống",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
          // Hiển thị "Bước 1/7" bên phải
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  "Bước 1/7",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
            )
          ],
          iconTheme: const IconThemeData(color: Colors.black), // Đổi màu nút back
          // Thanh progress bar đặt ở bottom
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nội dung theo chiều dọc
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Chọn loại thú cưng",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              petTypeCard("Mèo", "assets/cat.png"),
              const SizedBox(width: 20),
              petTypeCard("Chó", "assets/dog.png"),
            ],
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: selectedPetType.isEmpty
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PetBreedSelectionScreen(selectedPetType: selectedPetType),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF254EDB),
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Tiếp tục", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  String selectedPetType = ""; // Lưu loại thú cưng đã chọn (Mèo/Chó)

  // Hàm tạo card loại thú cưng
  Widget petTypeCard(String type, String imagePath) {
    bool isSelected = (selectedPetType == type);
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPetType = type;
        });
      },
      child: Container(
        width: 150,
        height: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF254EDB) : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 100, height: 100, fit: BoxFit.contain),
            const SizedBox(height: 8),
            Text(
              type,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
