/// Dart equivalent of DiseaseInfo.kt + DiseaseDatabase object.
/// Contains metadata for every disease class the ML model can output.

class DiseaseInfoEntry {
  final String label;
  final String displayName;
  final String cropType;
  final String cause;
  final String severity; // early | moderate | severe | healthy
  final bool isHealthy;
  final List<String> treatments;

  const DiseaseInfoEntry({
    required this.label,
    required this.displayName,
    required this.cropType,
    required this.cause,
    required this.severity,
    required this.isHealthy,
    required this.treatments,
  });
}

class DiseaseDatabase {
  DiseaseDatabase._();

  static const List<DiseaseInfoEntry> _entries = [
    // ─── Apple ────────────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Apple___Apple_scab',
      displayName: 'Apple Scab',
      cropType: 'Apple',
      cause: 'Fungal infection by Venturia inaequalis',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Apply fungicide sprays at bud break.',
        'Remove and destroy fallen leaves.',
        'Prune trees for good air circulation.',
        'Choose scab-resistant apple varieties.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Apple___Black_rot',
      displayName: 'Apple Black Rot',
      cropType: 'Apple',
      cause: 'Fungal infection by Botryosphaeria obtusa',
      severity: 'severe',
      isHealthy: false,
      treatments: [
        'Remove mummified fruits and dead wood.',
        'Apply copper-based fungicide.',
        'Maintain proper tree nutrition.',
        'Sanitize pruning tools between cuts.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Apple___Cedar_apple_rust',
      displayName: 'Cedar Apple Rust',
      cropType: 'Apple',
      cause: 'Fungal pathogen Gymnosporangium juniperi-virginianae',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Apply fungicide at pink bud stage.',
        'Remove nearby cedar trees if possible.',
        'Use rust-resistant apple cultivars.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Apple___healthy',
      displayName: 'Healthy Apple',
      cropType: 'Apple',
      cause: '',
      severity: 'healthy',
      isHealthy: true,
      treatments: [
        'Continue regular watering and fertilization.',
        'Monitor for early signs of disease.',
      ],
    ),
    // ─── Blueberry ────────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Blueberry___healthy',
      displayName: 'Healthy Blueberry',
      cropType: 'Blueberry',
      cause: '',
      severity: 'healthy',
      isHealthy: true,
      treatments: [
        'Keep soil acidic (pH 4.5–5.5).',
        'Mulch around plants to retain moisture.',
      ],
    ),
    // ─── Cherry ───────────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Cherry_(including_sour)___Powdery_mildew',
      displayName: 'Cherry Powdery Mildew',
      cropType: 'Cherry',
      cause: 'Fungal infection by Podosphaera clandestina',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Apply sulfur or potassium bicarbonate fungicide.',
        'Improve air circulation by pruning.',
        'Avoid excessive nitrogen fertilization.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Cherry_(including_sour)___healthy',
      displayName: 'Healthy Cherry',
      cropType: 'Cherry',
      cause: '',
      severity: 'healthy',
      isHealthy: true,
      treatments: [
        'Ensure adequate sunlight and drainage.',
        'Inspect regularly for pests.',
      ],
    ),
    // ─── Corn / Maize ─────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot',
      displayName: 'Maize Gray Leaf Spot',
      cropType: 'Maize',
      cause: 'Fungal infection by Cercospora zeae-maydis',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Plant resistant hybrid varieties.',
        'Apply fungicide at tasseling stage.',
        'Rotate crops annually.',
        'Reduce surface residue by tillage.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Corn_(maize)___Common_rust_',
      displayName: 'Maize Common Rust',
      cropType: 'Maize',
      cause: 'Fungal pathogen Puccinia sorghi',
      severity: 'early',
      isHealthy: false,
      treatments: [
        'Apply foliar fungicide early.',
        'Use rust-resistant hybrid seeds.',
        'Monitor fields after rainy periods.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Corn_(maize)___Northern_Leaf_Blight',
      displayName: 'Maize Northern Leaf Blight',
      cropType: 'Maize',
      cause: 'Fungal infection by Exserohilum turcicum',
      severity: 'severe',
      isHealthy: false,
      treatments: [
        'Apply propiconazole-based fungicide.',
        'Rotate with non-host crops.',
        'Choose resistant hybrids.',
        'Avoid overhead irrigation.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Corn_(maize)___healthy',
      displayName: 'Healthy Maize',
      cropType: 'Maize',
      cause: '',
      severity: 'healthy',
      isHealthy: true,
      treatments: [
        'Maintain proper spacing and soil fertility.',
        'Scout fields weekly during growing season.',
      ],
    ),
    // ─── Grape ────────────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Grape___Black_rot',
      displayName: 'Grape Black Rot',
      cropType: 'Grape',
      cause: 'Fungal infection by Guignardia bidwellii',
      severity: 'severe',
      isHealthy: false,
      treatments: [
        'Apply mancozeb fungicide from bud break.',
        'Remove mummified berries and infected canes.',
        'Ensure good canopy airflow.',
        'Avoid overhead irrigation.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Grape___Esca_(Black_Measles)',
      displayName: 'Grape Esca (Black Measles)',
      cropType: 'Grape',
      cause: 'Fungal complex (Phaeoacremonium, Phaeomoniella)',
      severity: 'severe',
      isHealthy: false,
      treatments: [
        'Remove and destroy infected wood.',
        'Protect pruning wounds with wound sealant.',
        'Avoid water stress on vines.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)',
      displayName: 'Grape Leaf Blight',
      cropType: 'Grape',
      cause: 'Fungal infection by Pseudocercospora vitis',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Apply copper fungicide preventively.',
        'Prune for better canopy airflow.',
        'Remove infected leaves promptly.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Grape___healthy',
      displayName: 'Healthy Grape',
      cropType: 'Grape',
      cause: '',
      severity: 'healthy',
      isHealthy: true,
      treatments: [
        'Prune annually for good airflow.',
        'Monitor for spider mites and downy mildew.',
      ],
    ),
    // ─── Orange ───────────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Orange___Haunglongbing_(Citrus_greening)',
      displayName: 'Citrus Greening (HLB)',
      cropType: 'Orange',
      cause: 'Bacterial infection by Candidatus Liberibacter',
      severity: 'severe',
      isHealthy: false,
      treatments: [
        'Remove and destroy infected trees immediately.',
        'Control Asian citrus psyllid with insecticide.',
        'Use certified disease-free planting material.',
        'There is currently no cure for HLB.',
      ],
    ),
    // ─── Peach ────────────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Peach___Bacterial_spot',
      displayName: 'Peach Bacterial Spot',
      cropType: 'Peach',
      cause: 'Bacterial infection by Xanthomonas arboricola',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Apply copper bactericide during dormancy.',
        'Prune affected branches.',
        'Choose resistant varieties.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Peach___healthy',
      displayName: 'Healthy Peach',
      cropType: 'Peach',
      cause: '',
      severity: 'healthy',
      isHealthy: true,
      treatments: [
        'Thin fruit clusters to avoid overcrowding.',
        'Monitor for brown rot during wet seasons.',
      ],
    ),
    // ─── Pepper ───────────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Pepper,_bell___Bacterial_spot',
      displayName: 'Pepper Bacterial Spot',
      cropType: 'Pepper',
      cause: 'Bacterial infection by Xanthomonas campestris',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Apply copper-based bactericide.',
        'Avoid overhead irrigation.',
        'Use disease-free transplants.',
        'Rotate crops every 2–3 years.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Pepper,_bell___healthy',
      displayName: 'Healthy Pepper',
      cropType: 'Pepper',
      cause: '',
      severity: 'healthy',
      isHealthy: true,
      treatments: [
        'Maintain consistent soil moisture.',
        'Fertilize with balanced NPK.',
      ],
    ),
    // ─── Potato ───────────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Potato___Early_blight',
      displayName: 'Potato Early Blight',
      cropType: 'Potato',
      cause: 'Fungal infection by Alternaria solani',
      severity: 'early',
      isHealthy: false,
      treatments: [
        'Apply chlorothalonil or mancozeb fungicide.',
        'Remove lower infected leaves.',
        'Ensure adequate potassium in soil.',
        'Avoid wetting foliage during irrigation.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Potato___Late_blight',
      displayName: 'Potato Late Blight',
      cropType: 'Potato',
      cause: 'Oomycete pathogen Phytophthora infestans',
      severity: 'severe',
      isHealthy: false,
      treatments: [
        'Apply metalaxyl or cymoxanil fungicide immediately.',
        'Destroy infected plant material.',
        'Improve drainage and reduce humidity.',
        'Plant certified blight-resistant varieties.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Potato___healthy',
      displayName: 'Healthy Potato',
      cropType: 'Potato',
      cause: '',
      severity: 'healthy',
      isHealthy: true,
      treatments: [
        'Hill soil around plants to prevent greening.',
        'Scout regularly for Colorado potato beetle.',
      ],
    ),
    // ─── Raspberry ────────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Raspberry___healthy',
      displayName: 'Healthy Raspberry',
      cropType: 'Raspberry',
      cause: '',
      severity: 'healthy',
      isHealthy: true,
      treatments: [
        'Prune out old canes after fruiting.',
        'Maintain good airflow to prevent mold.',
      ],
    ),
    // ─── Soybean ──────────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Soybean___healthy',
      displayName: 'Healthy Soybean',
      cropType: 'Soybean',
      cause: '',
      severity: 'healthy',
      isHealthy: true,
      treatments: [
        'Inoculate seeds with Bradyrhizobium for nitrogen fixation.',
        'Rotate with corn or small grains.',
      ],
    ),
    // ─── Squash ───────────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Squash___Powdery_mildew',
      displayName: 'Squash Powdery Mildew',
      cropType: 'Squash',
      cause: 'Fungal infection by Podosphaera xanthii',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Apply potassium bicarbonate or neem oil.',
        'Remove severely infected leaves.',
        'Avoid overcrowding plants.',
        'Water at the base to keep foliage dry.',
      ],
    ),
    // ─── Strawberry ───────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Strawberry___Leaf_scorch',
      displayName: 'Strawberry Leaf Scorch',
      cropType: 'Strawberry',
      cause: 'Fungal infection by Diplocarpon earlianum',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Apply captan fungicide.',
        'Remove infected leaves and runners.',
        'Plant in well-drained soils.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Strawberry___healthy',
      displayName: 'Healthy Strawberry',
      cropType: 'Strawberry',
      cause: '',
      severity: 'healthy',
      isHealthy: true,
      treatments: [
        'Replace plants every 3 years.',
        'Mulch with straw to keep fruit clean.',
      ],
    ),
    // ─── Tomato ───────────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Tomato___Bacterial_spot',
      displayName: 'Tomato Bacterial Spot',
      cropType: 'Tomato',
      cause: 'Bacterial infection by Xanthomonas species',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Apply copper bactericide every 7–10 days.',
        'Avoid overhead watering.',
        'Use certified disease-free transplants.',
        'Rotate with non-solanaceous crops.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Tomato___Early_blight',
      displayName: 'Tomato Early Blight',
      cropType: 'Tomato',
      cause: 'Fungal infection by Alternaria solani',
      severity: 'early',
      isHealthy: false,
      treatments: [
        'Remove lower infected leaves immediately.',
        'Apply chlorothalonil fungicide.',
        'Mulch around base to prevent soil splash.',
        'Maintain adequate plant nutrition.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Tomato___Late_blight',
      displayName: 'Tomato Late Blight',
      cropType: 'Tomato',
      cause: 'Oomycete pathogen Phytophthora infestans',
      severity: 'severe',
      isHealthy: false,
      treatments: [
        'Apply metalaxyl fungicide immediately.',
        'Destroy all infected plant material.',
        'Avoid working in field when wet.',
        'Use blight-resistant varieties.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Tomato___Leaf_Mold',
      displayName: 'Tomato Leaf Mold',
      cropType: 'Tomato',
      cause: 'Fungal infection by Passalora fulva',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Improve greenhouse ventilation.',
        'Reduce relative humidity below 85%.',
        'Apply chlorothalonil or mancozeb.',
        'Remove and dispose infected leaves.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Tomato___Septoria_leaf_spot',
      displayName: 'Tomato Septoria Leaf Spot',
      cropType: 'Tomato',
      cause: 'Fungal infection by Septoria lycopersici',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Apply maneb or chlorothalonil fungicide.',
        'Remove infected lower leaves.',
        'Avoid overhead irrigation.',
        'Stake plants for better airflow.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Tomato___Spider_mites Two-spotted_spider_mite',
      displayName: 'Tomato Spider Mites',
      cropType: 'Tomato',
      cause: 'Infestation by Tetranychus urticae',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Apply miticide or insecticidal soap.',
        'Introduce predatory mites (biological control).',
        'Keep plants well-watered to reduce stress.',
        'Remove heavily infested leaves.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Tomato___Target_Spot',
      displayName: 'Tomato Target Spot',
      cropType: 'Tomato',
      cause: 'Fungal infection by Corynespora cassiicola',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Apply azoxystrobin or chlorothalonil.',
        'Reduce canopy density by pruning.',
        'Avoid excessive irrigation.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Tomato___Tomato_Yellow_Leaf_Curl_Virus',
      displayName: 'Tomato Yellow Leaf Curl Virus',
      cropType: 'Tomato',
      cause: 'Viral infection transmitted by whiteflies',
      severity: 'severe',
      isHealthy: false,
      treatments: [
        'Control whitefly populations with insecticide.',
        'Use reflective mulch to repel whiteflies.',
        'Remove and destroy infected plants.',
        'Plant TYLCV-resistant varieties.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Tomato___Tomato_mosaic_virus',
      displayName: 'Tomato Mosaic Virus',
      cropType: 'Tomato',
      cause: 'Viral infection (ToMV), spread by contact',
      severity: 'severe',
      isHealthy: false,
      treatments: [
        'Remove and destroy infected plants.',
        'Disinfect tools with bleach solution.',
        'Wash hands after handling plants.',
        'Use virus-resistant tomato varieties.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Tomato___healthy',
      displayName: 'Healthy Tomato',
      cropType: 'Tomato',
      cause: '',
      severity: 'healthy',
      isHealthy: true,
      treatments: [
        'Water consistently at the base.',
        'Apply balanced fertilizer every 2 weeks.',
        'Stake or cage for support.',
      ],
    ),
    // ─── Cassava ──────────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Cassava___Bacterial_Blight',
      displayName: 'Cassava Bacterial Blight',
      cropType: 'Cassava',
      cause: 'Bacterial infection by Xanthomonas axonopodis',
      severity: 'severe',
      isHealthy: false,
      treatments: [
        'Use disease-free planting material.',
        'Remove and destroy infected stems.',
        'Practice crop rotation.',
        'Plant resistant varieties.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Cassava___Brown_Streak_Disease',
      displayName: 'Cassava Brown Streak Disease',
      cropType: 'Cassava',
      cause: 'Viral infection transmitted by whiteflies',
      severity: 'severe',
      isHealthy: false,
      treatments: [
        'Use certified virus-free cuttings.',
        'Control whitefly vectors with insecticide.',
        'Rogue out and destroy infected plants.',
        'Plant tolerant varieties.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Cassava___Green_Mottle',
      displayName: 'Cassava Green Mottle',
      cropType: 'Cassava',
      cause: 'Viral infection by Cassava green mottle virus',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Use virus-tested planting material.',
        'Control insect vectors.',
        'Avoid inter-planting with infected crops.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Cassava___Mosaic_Disease',
      displayName: 'Cassava Mosaic Disease',
      cropType: 'Cassava',
      cause: 'Begomovirus complex transmitted by whiteflies',
      severity: 'severe',
      isHealthy: false,
      treatments: [
        'Plant CMD-resistant varieties (e.g. IITA mosaic-resistant lines).',
        'Use clean, symptom-free planting stems.',
        'Control whitefly with neem-based spray.',
        'Remove and burn infected plants.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Cassava___Healthy',
      displayName: 'Healthy Cassava',
      cropType: 'Cassava',
      cause: '',
      severity: 'healthy',
      isHealthy: true,
      treatments: [
        'Plant on well-drained soils.',
        'Weed regularly for first 3 months.',
      ],
    ),
    // ─── Rice ─────────────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Rice___Brown_Spot',
      displayName: 'Rice Brown Spot',
      cropType: 'Rice',
      cause: 'Fungal infection by Cochliobolus miyabeanus',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Apply mancozeb or iprodione fungicide.',
        'Ensure adequate potassium fertilization.',
        'Use certified disease-free seed.',
        'Drain and dry fields between irrigations.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Rice___Hispa',
      displayName: 'Rice Hispa (Leaf Miner)',
      cropType: 'Rice',
      cause: 'Insect pest Dicladispa armigera',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Apply chlorpyrifos or carbofuran insecticide.',
        'Use light traps to monitor adult population.',
        'Remove affected leaves manually.',
        'Keep bunds clean of weeds.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Rice___Leaf_Blast',
      displayName: 'Rice Leaf Blast',
      cropType: 'Rice',
      cause: 'Fungal infection by Magnaporthe oryzae',
      severity: 'severe',
      isHealthy: false,
      treatments: [
        'Apply tricyclazole or isoprothiolane fungicide.',
        'Avoid excessive nitrogen fertilizer.',
        'Plant blast-resistant varieties.',
        'Improve field drainage.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Rice___Healthy',
      displayName: 'Healthy Rice',
      cropType: 'Rice',
      cause: '',
      severity: 'healthy',
      isHealthy: true,
      treatments: [
        'Maintain proper water depth (2–5 cm).',
        'Apply split nitrogen doses.',
      ],
    ),
    // ─── Banana ───────────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Banana___Cordana_Leaf_Spot',
      displayName: 'Banana Cordana Leaf Spot',
      cropType: 'Banana',
      cause: 'Fungal infection by Cordana musae',
      severity: 'early',
      isHealthy: false,
      treatments: [
        'Remove and destroy infected leaves.',
        'Apply propiconazole fungicide.',
        'Improve drainage around plants.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Banana___Pestalotiopsis_Leaf_Spot',
      displayName: 'Banana Pestalotiopsis Leaf Spot',
      cropType: 'Banana',
      cause: 'Fungal infection by Pestalotiopsis species',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Remove dead leaves and plant debris.',
        'Apply copper fungicide.',
        'Avoid over-irrigation.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Banana___Sigatoka_Leaf_Spot',
      displayName: 'Banana Sigatoka (Black Leaf Streak)',
      cropType: 'Banana',
      cause: 'Fungal infection by Mycosphaerella fijiensis',
      severity: 'severe',
      isHealthy: false,
      treatments: [
        'Apply systemic fungicide (propiconazole, tebuconazole).',
        'Remove infected leaves regularly.',
        'Plant Sigatoka-resistant varieties.',
        'Improve air circulation by wider spacing.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Banana___Healthy',
      displayName: 'Healthy Banana',
      cropType: 'Banana',
      cause: '',
      severity: 'healthy',
      isHealthy: true,
      treatments: [
        'Ensure adequate potassium supply.',
        'Bunch-protect with polyethylene bags.',
      ],
    ),
    // ─── Groundnut ────────────────────────────────────────────────────────
    DiseaseInfoEntry(
      label: 'Groundnut___Early_Leaf_Spot',
      displayName: 'Groundnut Early Leaf Spot',
      cropType: 'Groundnut',
      cause: 'Fungal infection by Cercospora arachidicola',
      severity: 'early',
      isHealthy: false,
      treatments: [
        'Apply chlorothalonil or mancozeb fungicide.',
        'Remove infected leaves promptly.',
        'Ensure good plant spacing.',
        'Rotate with cereals.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Groundnut___Late_Leaf_Spot',
      displayName: 'Groundnut Late Leaf Spot',
      cropType: 'Groundnut',
      cause: 'Fungal infection by Cercosporidium personatum',
      severity: 'moderate',
      isHealthy: false,
      treatments: [
        'Apply tebuconazole or chlorothalonil.',
        'Avoid dense plant populations.',
        'Use tolerant varieties.',
        'Ensure well-drained, sandy loam soil.',
      ],
    ),
    DiseaseInfoEntry(
      label: 'Groundnut___Healthy',
      displayName: 'Healthy Groundnut',
      cropType: 'Groundnut',
      cause: '',
      severity: 'healthy',
      isHealthy: true,
      treatments: [
        'Inoculate seeds with Rhizobium for nitrogen fixation.',
        'Maintain soil pH between 5.5 and 7.0.',
      ],
    ),
  ];

  static DiseaseInfoEntry getInfo(String label) {
    return _entries.firstWhere(
      (e) => e.label == label,
      orElse: () => DiseaseInfoEntry(
        label: label,
        displayName: label.replaceAll('___', ' ').replaceAll('_', ' '),
        cropType: 'Unknown',
        cause: 'Unknown cause',
        severity: 'unclear',
        isHealthy: false,
        treatments: ['Consult an agricultural extension officer.'],
      ),
    );
  }

  static List<String> getAllLabels() {
    return _entries.map((e) => e.label).toList();
  }

  static List<DiseaseInfoEntry> getAllDiseases() => List.unmodifiable(_entries);

  static List<DiseaseInfoEntry> getByCategory(String cropType) {
    return _entries
        .where((e) =>
            e.cropType.toLowerCase() == cropType.toLowerCase() && !e.isHealthy)
        .toList();
  }
}
