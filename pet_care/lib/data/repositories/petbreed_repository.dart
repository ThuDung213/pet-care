import 'package:pet_care/data/model/petbreed.dart';


class PetBreedRepository {
  static final List<PetBreed> dogBreeds = [
    PetBreed(name: 'Chó Akita', image: 'assets/cho_akita.png'),
    PetBreed(name: 'Chó săn thỏ', image: 'assets/cho_san_tho.png'),
    PetBreed(name: 'Chó ta', image: 'assets/cho_ta.png'),
    PetBreed(name: 'Border Collie', image: 'assets/border_collie.png'),
    PetBreed(name: 'Boxer', image: 'assets/boxer.png'),
    PetBreed(name: 'Chow Chow', image: 'assets/chow_chow.png'),
  ];

  static final List<PetBreed> catBreeds = [
    PetBreed(name: 'Mèo Ai Cập', image: 'assets/meoaicap.png'),
    PetBreed(name: 'Mèo Tai Cụp', image: 'assets/meotaicup.png'),
    PetBreed(name: 'Mèo Lai', image: 'assets/meolai.png'),
    PetBreed(name: 'Mèo Ta', image: 'assets/meota.png'),
    PetBreed(name: 'Mèo Xiêm', image: 'assets/meoxiem.png'),
    PetBreed(name: 'Anh Lông Dài', image: 'assets/anhlongdai.png'),
  ];

  static List<PetBreed> getBreeds(String petType) {
    return petType.toLowerCase() == "mèo" ? catBreeds : dogBreeds;
  }
}
