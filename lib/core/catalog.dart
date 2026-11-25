/// Crop categories and common crops (with Telugu names and a picture emoji)
/// so sellers can tap a picture instead of typing.
class CropCategory {
  const CropCategory(this.key, this.en, this.te, this.emoji);
  final String key;
  final String en;
  final String te;
  final String emoji;

  String name(bool telugu) => telugu ? te : en;
}

class Crop {
  const Crop(this.key, this.category, this.en, this.te, this.emoji,
      {this.unit = 'kg'});
  final String key;
  final String category;
  final String en;
  final String te;
  final String emoji;

  /// Default selling unit for this crop.
  final String unit;

  String name(bool telugu) => telugu ? te : en;
}

class Catalog {
  static const otherCropKey = 'other';

  static const units = ['kg', 'quintal', 'litre', 'dozen', 'piece'];

  static const categories = <CropCategory>[
    CropCategory('vegetables', 'Vegetables', 'కూరగాయలు', '🥕'),
    CropCategory('fruits', 'Fruits', 'పండ్లు', '🍎'),
    CropCategory('grains', 'Grains', 'ధాన్యాలు', '🌾'),
    CropCategory('pulses', 'Pulses & Nuts', 'పప్పు దినుసులు', '🥜'),
    CropCategory('spices', 'Spices', 'మసాలా దినుసులు', '🌶️'),
    CropCategory('dairy_others', 'Dairy & Others', 'పాలు & ఇతరాలు', '🥛'),
  ];

  static const crops = <Crop>[
    // Vegetables
    Crop('tomato', 'vegetables', 'Tomato', 'టమాటా', '🍅'),
    Crop('onion', 'vegetables', 'Onion', 'ఉల్లిపాయ', '🧅'),
    Crop('potato', 'vegetables', 'Potato', 'బంగాళాదుంప', '🥔'),
    Crop('carrot', 'vegetables', 'Carrot', 'క్యారెట్', '🥕'),
    Crop('brinjal', 'vegetables', 'Brinjal', 'వంకాయ', '🍆'),
    Crop('green_chilli', 'vegetables', 'Green Chilli', 'పచ్చిమిర్చి', '🌶️'),
    Crop('okra', 'vegetables', 'Ladies Finger', 'బెండకాయ', '🌿'),
    Crop('cucumber', 'vegetables', 'Cucumber', 'దోసకాయ', '🥒'),
    Crop('bitter_gourd', 'vegetables', 'Bitter Gourd', 'కాకరకాయ', '🥒'),
    Crop('drumstick', 'vegetables', 'Drumstick', 'మునక్కాయ', '🌿'),
    Crop('beans', 'vegetables', 'Beans', 'చిక్కుడుకాయ', '🌱'),
    Crop('cabbage', 'vegetables', 'Cabbage', 'క్యాబేజీ', '🥬'),
    Crop('cauliflower', 'vegetables', 'Cauliflower', 'కాలీఫ్లవర్', '🥦'),
    Crop('garlic', 'vegetables', 'Garlic', 'వెల్లుల్లి', '🧄'),
    Crop('ginger', 'vegetables', 'Ginger', 'అల్లం', '🌿'),
    Crop('leafy_greens', 'vegetables', 'Leafy Greens', 'ఆకుకూరలు', '🥬'),
    // Fruits
    Crop('mango', 'fruits', 'Mango', 'మామిడి', '🥭'),
    Crop('banana', 'fruits', 'Banana', 'అరటి', '🍌', unit: 'dozen'),
    Crop('papaya', 'fruits', 'Papaya', 'బొప్పాయి', '🍈'),
    Crop('guava', 'fruits', 'Guava', 'జామ', '🍐'),
    Crop('watermelon', 'fruits', 'Watermelon', 'పుచ్చకాయ', '🍉'),
    Crop('sweet_lime', 'fruits', 'Sweet Lime', 'బత్తాయి', '🍊'),
    Crop('lemon', 'fruits', 'Lemon', 'నిమ్మకాయ', '🍋'),
    Crop('pomegranate', 'fruits', 'Pomegranate', 'దానిమ్మ', '🍎'),
    Crop('grapes', 'fruits', 'Grapes', 'ద్రాక్ష', '🍇'),
    Crop('coconut', 'fruits', 'Coconut', 'కొబ్బరికాయ', '🥥', unit: 'piece'),
    Crop('sapota', 'fruits', 'Sapota', 'సపోటా', '🥝'),
    Crop('custard_apple', 'fruits', 'Custard Apple', 'సీతాఫలం', '🍏'),
    // Grains
    Crop('paddy', 'grains', 'Paddy', 'వరి ధాన్యం', '🌾', unit: 'quintal'),
    Crop('rice', 'grains', 'Rice', 'బియ్యం', '🍚'),
    Crop('maize', 'grains', 'Maize', 'మొక్కజొన్న', '🌽', unit: 'quintal'),
    Crop('jowar', 'grains', 'Jowar', 'జొన్నలు', '🌾'),
    Crop('ragi', 'grains', 'Ragi', 'రాగులు', '🌾'),
    Crop('bajra', 'grains', 'Bajra', 'సజ్జలు', '🌾'),
    Crop('wheat', 'grains', 'Wheat', 'గోధుమలు', '🌾'),
    // Pulses & nuts
    Crop('red_gram', 'pulses', 'Red Gram (Toor)', 'కందులు', '🟤'),
    Crop('green_gram', 'pulses', 'Green Gram', 'పెసలు', '🟢'),
    Crop('black_gram', 'pulses', 'Black Gram', 'మినుములు', '⚫'),
    Crop('bengal_gram', 'pulses', 'Bengal Gram', 'శనగలు', '🟠'),
    Crop('groundnut', 'pulses', 'Groundnut', 'వేరుశనగ', '🥜', unit: 'quintal'),
    // Spices
    Crop('dry_chilli', 'spices', 'Dry Red Chilli', 'ఎండు మిర్చి', '🌶️', unit: 'quintal'),
    Crop('turmeric', 'spices', 'Turmeric', 'పసుపు', '🟡', unit: 'quintal'),
    Crop('coriander', 'spices', 'Coriander Seeds', 'ధనియాలు', '🌿'),
    Crop('tamarind', 'spices', 'Tamarind', 'చింతపండు', '🟫'),
    // Dairy & others
    Crop('milk', 'dairy_others', 'Milk', 'పాలు', '🥛', unit: 'litre'),
    Crop('curd', 'dairy_others', 'Curd', 'పెరుగు', '🥣'),
    Crop('ghee', 'dairy_others', 'Ghee', 'నెయ్యి', '🧈'),
    Crop('eggs', 'dairy_others', 'Eggs', 'గుడ్లు', '🥚', unit: 'dozen'),
    Crop('honey', 'dairy_others', 'Honey', 'తేనె', '🍯'),
    Crop('cotton', 'dairy_others', 'Cotton', 'పత్తి', '☁️', unit: 'quintal'),
  ];

  static CropCategory categoryByKey(String key) =>
      categories.firstWhere((c) => c.key == key, orElse: () => categories.last);

  static List<Crop> cropsIn(String categoryKey) =>
      crops.where((c) => c.category == categoryKey).toList();

  static Crop? cropByKey(String? key) {
    if (key == null) return null;
    for (final c in crops) {
      if (c.key == key) return c;
    }
    return null;
  }
}
