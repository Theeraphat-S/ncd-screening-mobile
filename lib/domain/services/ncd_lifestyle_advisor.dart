import 'package:equatable/equatable.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';

class PlainHealthAdvice extends Equatable {
  final String diseaseName;
  final String conditionSummary;
  final RiskLevel riskLevel;
  final String riskLabelThai;
  final List<String> goodFoods;
  final List<String> avoidFoods;
  final String exerciseTip;
  final String dailyAdvice;
  final String followUpSchedule;

  const PlainHealthAdvice({
    required this.diseaseName,
    required this.conditionSummary,
    required this.riskLevel,
    required this.riskLabelThai,
    required this.goodFoods,
    required this.avoidFoods,
    required this.exerciseTip,
    required this.dailyAdvice,
    required this.followUpSchedule,
  });

  @override
  List<Object?> get props => [
        diseaseName,
        conditionSummary,
        riskLevel,
        riskLabelThai,
        goodFoods,
        avoidFoods,
        exerciseTip,
        dailyAdvice,
        followUpSchedule,
      ];
}

class NcdLifestyleAdvisor {
  /// Generate plain-Thai lifestyle guidance based on screening biometrics and results.
  static List<PlainHealthAdvice> generateAdviceList({
    required Screening screening,
    required List<ScreeningResult> results,
  }) {
    final List<PlainHealthAdvice> adviceList = [];

    for (final result in results) {
      final code = result.diseaseCode.toUpperCase();
      final level = result.riskLevel;

      switch (code) {
        case 'DM':
        case 'DIABETES':
          adviceList.add(_buildDiabetesAdvice(screening.bloodSugar, level));
          break;
        case 'HT':
        case 'HYPERTENSION':
          adviceList.add(_buildHypertensionAdvice(screening.sbp, screening.dbp, level));
          break;
        case 'CVD':
          adviceList.add(_buildCvdAdvice(screening.pulse, level));
          break;
        case 'OBESITY':
        case 'METABOLIC':
          adviceList.add(_buildObesityAdvice(screening.bmi, screening.waistCm, level));
          break;
        default:
          adviceList.add(PlainHealthAdvice(
            diseaseName: result.diseaseName,
            conditionSummary: 'การดูแลสุขภาพทั่วไป',
            riskLevel: level,
            riskLabelThai: _getRiskLabelThai(level),
            goodFoods: const ['ผักสด', 'ผลไม้รสไม่หวาน', 'น้ำเปล่าสะอาด'],
            avoidFoods: const ['ของหวานจัด', 'ของมันจัด', 'ของเค็มจัด'],
            exerciseTip: 'ออกกำลังกายสม่ำเสมออย่างน้อย 150 นาทีต่อสัปดาห์',
            dailyAdvice: result.adviceText,
            followUpSchedule: 'ตรวจคัดกรองประจำปีอย่างต่อเนื่อง',
          ));
      }
    }

    return adviceList;
  }

  static String _getRiskLabelThai(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'ระดับปกติ / เสี่ยงต่ำ';
      case RiskLevel.moderate:
        return 'ระดับเสี่ยงปานกลาง';
      case RiskLevel.high:
        return 'ระดับเสี่ยงสูง (ควรพบแพทย์)';
    }
  }

  static PlainHealthAdvice _buildDiabetesAdviceWithoutReading(RiskLevel level) {
    if (level == RiskLevel.high) {
      return const PlainHealthAdvice(
        diseaseName: 'โรคเบาหวาน (ระดับน้ำตาลในเลือด)',
        conditionSummary: 'มีประวัติเป็นโรคเบาหวาน (ยังไม่ได้ตรวจระดับน้ำตาลครั้งนี้)',
        riskLevel: RiskLevel.high,
        riskLabelThai: 'เสี่ยงสูง (มีประวัติเบาหวาน)',
        goodFoods: ['ข้าวกล้อง / ข้าวไรซ์เบอร์รี่', 'ผักใบเขียวต้ม', 'ต้มจืดเต้าหู้ปลา'],
        avoidFoods: ['น้ำอัดลม ชาเขียวหวาน ชานม', 'ขนมหวาน ขนมเชื่อม', 'ผลไม้หวานจัด'],
        exerciseTip: 'เดินเร็วหรือแกว่งแขนวันละ 30 นาที หลังมื้ออาหาร',
        dailyAdvice: 'ควบคุมอาหารหวาน มัน เค็ม และรับประทานยาตามแพทย์สั่ง',
        followUpSchedule: 'ควรมาตรวจระดับน้ำตาลและพบแพทย์ที่ รพ.สต. ตามนัด',
      );
    }
    return const PlainHealthAdvice(
      diseaseName: 'โรคเบาหวาน (ระดับน้ำตาลในเลือด)',
      conditionSummary: 'ยังไม่ได้ตรวจระดับน้ำตาลในเลือด (ข้อมูลไม่ครบ)',
      riskLevel: RiskLevel.low,
      riskLabelThai: 'ข้อมูลไม่ครบ',
      goodFoods: ['อาหารครบ 5 หมู่', 'ผักผลไม้ตามฤดูกาล'],
      avoidFoods: ['เครื่องดื่มและขนมหวานจัด'],
      exerciseTip: 'ออกกำลังกายสม่ำเสมอ รักษาน้ำหนักตัวให้คงที่',
      dailyAdvice: 'ลดอาหารหวาน มัน เค็ม ระหว่างรอตรวจน้ำตาล',
      followUpSchedule: 'ขอให้ อสม. หรือ รพ.สต. ตรวจน้ำตาลในเลือด (FBS) เพื่อประเมินให้ครบถ้วน',
    );
  }

  static PlainHealthAdvice _buildDiabetesAdvice(double? bloodSugar, RiskLevel level) {
    if (bloodSugar == null) {
      return _buildDiabetesAdviceWithoutReading(level);
    }
    if (level == RiskLevel.high || bloodSugar >= 126) {
      return PlainHealthAdvice(
        diseaseName: 'โรคเบาหวาน (ระดับน้ำตาลในเลือด)',
        conditionSummary: 'ค่าน้ำตาลในเลือด $bloodSugar มก./ดล. (อยู่ในเกณฑ์สูง)',
        riskLevel: RiskLevel.high,
        riskLabelThai: 'เสี่ยงสูง (พบแพทย์ รพ.สต.)',
        goodFoods: const ['ข้าวกล้อง / ข้าวไรซ์เบอร์รี่', 'ผักใบเขียวต้ม', 'ต้มจืดเต้าหู้ปลา', 'ฝรั่ง / แอปเปิ้ลเขียว'],
        avoidFoods: const ['น้ำอัดลม ชาเขียวหวาน ชานม', 'ขนมหวาน ขนมเชื่อม ทองหยอด', 'ผลไม้หวานจัด ทุเรียน ลำไย'],
        exerciseTip: 'เดินเร็วหรือแกว่งแขนวันละ 30 นาที หลังมื้ออาหาร',
        dailyAdvice: 'งดกินน้ำตาลทราย ไม่ดื่มน้ำหวานทุกชนิด ดื่มน้ำเปล่าอย่างน้อย 8 แก้วต่อวัน',
        followUpSchedule: 'ควรมาพบแพทย์ที่ รพ.สต. เพื่อตรวจยืนยันค่าน้ำตาลอดอาหาร (FPG) ภายใน 2 สัปดาห์',
      );
    } else if (level == RiskLevel.moderate || bloodSugar >= 100) {
      return PlainHealthAdvice(
        diseaseName: 'โรคเบาหวาน (ระดับน้ำตาลในเลือด)',
        conditionSummary: 'ค่าน้ำตาลในเลือด $bloodSugar มก./ดล. (เริ่มมีแนวโน้มสูง)',
        riskLevel: RiskLevel.moderate,
        riskLabelThai: 'เริ่มมีความเสี่ยง',
        goodFoods: const ['ผักสด ผักลวก', 'ปลาต้ม ปลานึ่ง', 'ถั่วธัญพืชไม่ทอด'],
        avoidFoods: const ['เครื่องดื่มใส่น้ำตาล', 'ขนมปังขาว เบเกอรี่', 'ผลไม้กระป๋อง'],
        exerciseTip: 'เดินออกกำลังกายต่อเนื่องวันละ 20-30 นาที สัปดาห์ละ 3-5 วัน',
        dailyAdvice: 'ลดปริมาณข้าวลง 1 ทัพพี เพิ่มผักในทุกมื้ออาหาร',
        followUpSchedule: 'ตรวจซ้ำที่ รพ.สต. ในอีก 3 เดือน',
      );
    } else {
      return PlainHealthAdvice(
        diseaseName: 'โรคเบาหวาน (ระดับน้ำตาลในเลือด)',
        conditionSummary: 'ค่าน้ำตาลในเลือด $bloodSugar มก./ดล. (เกณฑ์ปกติสมบูรณ์)',
        riskLevel: RiskLevel.low,
        riskLabelThai: 'สุขภาพดี ปกติ',
        goodFoods: const ['อาหารครบ 5 หมู่', 'ผักผลไม้ตามฤดูกาล', 'เนื้อสัตว์ไม่ติดมัน'],
        avoidFoods: const ['อาหารรสหวานจัดสะสม'],
        exerciseTip: 'ออกกำลังกายสม่ำเสมอ รักษาน้ำหนักตัวให้คงที่',
        dailyAdvice: 'รักษาสุขภาพและรับประทานอาหารให้หลากหลาย',
        followUpSchedule: 'ตรวจคัดกรองประจำปีตามนัด อสม.',
      );
    }
  }

  static PlainHealthAdvice _buildHypertensionAdvice(double sbp, double dbp, RiskLevel level) {
    final bpText = '${sbp.toInt()}/${dbp.toInt()} มม.ปรอท';
    if (level == RiskLevel.high || sbp >= 140 || dbp >= 90) {
      return PlainHealthAdvice(
        diseaseName: 'โรคความดันโลหิตสูง',
        conditionSummary: 'ความดันโลหิต $bpText (สูงกว่าเกณฑ์มาตรฐาน)',
        riskLevel: RiskLevel.high,
        riskLabelThai: 'เสี่ยงสูง (ต้องระวัง)',
        goodFoods: const ['แกงส้ม ผักลวกจิ้มแจ่วไม่เค็ม', 'ผลไม้มีโพแทสเซียม กล้วยน้ำว้า ส้ม', 'ปลาทูสดนึ่ง'],
        avoidFoods: const ['น้ำปลา ซีอิ๊ว กะปิ ปลาร้าเข้มข้น', 'ของหมักดอง ไข่เค็ม กุนเชียง', 'บะหมี่กึ่งสำเร็จรูป ผงชูรส'],
        exerciseTip: 'เดินผ่อนคลาย ไม่ควรหักโหมหรือยกของหนัก',
        dailyAdvice: 'ลดเค็มครึ่งหนึ่ง ปรุงอาหารรสจืด งดอาหารแปรรูป นอนหลับพักผ่อนให้เพียงพอ',
        followUpSchedule: 'วัดความดันซ้ำที่ รพ.สต. ภายใน 1 สัปดาห์',
      );
    } else if (level == RiskLevel.moderate || sbp >= 130 || dbp >= 85) {
      return PlainHealthAdvice(
        diseaseName: 'โรคความดันโลหิตสูง',
        conditionSummary: 'ความดันโลหิต $bpText (เริ่มสูงปานกลาง)',
        riskLevel: RiskLevel.moderate,
        riskLabelThai: 'เริ่มมีความเสี่ยง',
        goodFoods: const ['ผักต้ม ผักนึ่ง', 'อาหารปรุงรสอ่อน', 'น้ำเต้าหู้ไม่หวาน'],
        avoidFoods: const ['ขนมกรุบกรอบรสเค็ม', 'น้ำจิ้มสุกี้ น้ำจิ้มไก่ปริมาณมาก'],
        exerciseTip: 'เดินเร็ว ปั่นจักรยานเบาๆ วันละ 25 นาที',
        dailyAdvice: 'ชิมก่อนปรุง ไม่เติมน้ำปลาพริกเพิ่มในจานอาหาร',
        followUpSchedule: 'ตรวจวัดความดันซ้ำในอีก 1-3 เดือน',
      );
    } else {
      return PlainHealthAdvice(
        diseaseName: 'โรคความดันโลหิตสูง',
        conditionSummary: 'ความดันโลหิต $bpText (เกณฑ์ปกติยอดเยี่ยม)',
        riskLevel: RiskLevel.low,
        riskLabelThai: 'ปกติ แข็งแรงดี',
        goodFoods: const ['อาหารรสธรรมชาติ', 'ผักผลไม้สด'],
        avoidFoods: const ['อาหารเค็มจัดต่อเนื่อง'],
        exerciseTip: 'ออกกำลังกายแอโรบิกเบาๆ เป็นประจำ',
        dailyAdvice: 'รักษาระดับความดันด้วยการพักผ่อนและดื่มน้ำเพียงพอ',
        followUpSchedule: 'ตรวจคัดกรองประจำปีตามรอบ',
      );
    }
  }

  static PlainHealthAdvice _buildCvdAdvice(double pulse, RiskLevel level) {
    if (level == RiskLevel.high) {
      return const PlainHealthAdvice(
        diseaseName: 'โรคหลอดเลือดหัวใจและสมอง',
        conditionSummary: 'ประเมินความเสี่ยงโรคหลอดเลือดหัวใจอยู่ในระดับสูง',
        riskLevel: RiskLevel.high,
        riskLabelThai: 'เสี่ยงสูง (ควรพบแพทย์)',
        goodFoods: ['ปลาทะเล ปลาน้ำจืดสด', 'กระเทียม หอมแดง', 'น้ำมันรำข้าว น้ำมันมะกอก'],
        avoidFoods: ['ไขมันทรานส์ ครีมเทียม เนยเทียม', 'หมูกรอบ หนังไก่ทอด แคบหมูติดมัน', 'เครื่องในสัตว์ ไข่แดงเกินวันละ 1 ฟอง'],
        exerciseTip: 'ปรึกษาแพทย์ก่อนเริ่มโปรแกรมออกกำลังกายหนัก เน้นเดินราบเบาๆ',
        dailyAdvice: 'งดสูบบุหรี่และงดดื่มแอลกอฮอล์เด็ดขาด หลีกเลี่ยงความเครียด',
        followUpSchedule: 'นัดพบแพทย์ รพ.สต. เพื่อตรวจคลื่นไฟฟ้าหัวใจและประเมินเชิงลึก',
      );
    } else if (level == RiskLevel.moderate) {
      return const PlainHealthAdvice(
        diseaseName: 'โรคหลอดเลือดหัวใจและสมอง',
        conditionSummary: 'ประเมินความเสี่ยงโรคหลอดเลือดอยู่ในเกณฑ์ปานกลาง',
        riskLevel: RiskLevel.moderate,
        riskLabelThai: 'เสี่ยงปานกลาง',
        goodFoods: ['เนื้อปลา', 'ผักใบเขียว', 'ถั่วอัลมอนด์ เม็ดมะม่วงไม่ทอด'],
        avoidFoods: ['แกงกะทิเข้มข้น', 'ของทอดน้ำมันซ้ำ'],
        exerciseTip: 'เดินเร็วหรือแกว่งแขนวันละ 30 นาที',
        dailyAdvice: 'เลี่ยงอาหารมัน ทอด และควบคุมอารมณ์ไม่ให้เครียดสะสม',
        followUpSchedule: 'ตรวจติดตามอาการทุก 6 เดือน',
      );
    } else {
      return const PlainHealthAdvice(
        diseaseName: 'โรคหลอดเลือดหัวใจและสมอง',
        conditionSummary: 'สุขภาพหลอดเลือดและหัวใจอยู่ในเกณฑ์ดีมาก',
        riskLevel: RiskLevel.low,
        riskLabelThai: 'ปกติ ปลอดภัย',
        goodFoods: ['ปลา ผัก ธัญพืช', 'น้ำมันพืชปรุงอาหาร'],
        avoidFoods: ['ของมันของทอดปริมาณมาก'],
        exerciseTip: 'ออกกำลังกายกระตุ้นหัวใจสม่ำเสมอ',
        dailyAdvice: 'รักษาสุขภาพจิตแจ่มใส และนอนหลับ 7-8 ชั่วโมง',
        followUpSchedule: 'ตรวจคัดกรองประจำปี',
      );
    }
  }

  static PlainHealthAdvice _buildObesityAdvice(double bmi, double waistCm, RiskLevel level) {
    final bmiText = 'BMI ${bmi.toStringAsFixed(1)} (รอบเอว ${waistCm.toInt()} ซม.)';
    if (level == RiskLevel.high || bmi >= 25.0) {
      return PlainHealthAdvice(
        diseaseName: 'ภาวะอ้วนลงพุงและเมแทบอลิก',
        conditionSummary: '$bmiText เกินเกณฑ์มาตรฐาน',
        riskLevel: RiskLevel.high,
        riskLabelThai: 'น้ำหนักเกินเกณฑ์',
        goodFoods: const ['ผักต้ม ผักสดเต็มจาน', 'อกไก่ต้ม ปลานึ่ง', 'ไข่ต้ม เต้าหู้'],
        avoidFoods: const ['ข้าวมันไก่ ขาหมู ข้าวเหนียวปริมาณมาก', 'ชานมไข่มุก ขนมซอง', 'ของทอดทุกชนิด'],
        exerciseTip: 'เดินเร็ววันละ 30-45 นาที หรือว่ายน้ำ/ปั่นจักรยานเพื่อลดแรงกระแทกข้อเข่า',
        dailyAdvice: 'ใช้จานสุขภาพ: ผัก 2 ส่วน ข้าว 1 ส่วน เนื้อสัตว์ 1 ส่วน',
        followUpSchedule: 'ชั่งน้ำหนักและวัดรอบเอวติดตามผลทุกเดือน',
      );
    } else if (level == RiskLevel.moderate || bmi >= 23.0) {
      return PlainHealthAdvice(
        diseaseName: 'ภาวะอ้วนลงพุงและเมแทบอลิก',
        conditionSummary: '$bmiText น้ำหนักตัวเริ่มท้วม',
        riskLevel: RiskLevel.moderate,
        riskLabelThai: 'เริ่มท้วม',
        goodFoods: const ['ผักสด ผลไม้หวานน้อย', 'เนื้อไม่ติดมัน'],
        avoidFoods: const ['น้ำหวาน น้ำอัดลม', 'ของทอด'],
        exerciseTip: 'ขยับร่างกายบ่อยขึ้น เดินขึ้นบันไดแทนลิฟต์',
        dailyAdvice: 'ลดมื้อดึก ไม่กินอาหารก่อนนอน 3 ชั่วโมง',
        followUpSchedule: 'ตรวจติดตามน้ำหนักทุก 3 เดือน',
      );
    } else {
      return PlainHealthAdvice(
        diseaseName: 'ภาวะอ้วนลงพุงและเมแทบอลิก',
        conditionSummary: '$bmiText สมส่วน สุขภาพดี',
        riskLevel: RiskLevel.low,
        riskLabelThai: 'น้ำหนักสมส่วน',
        goodFoods: const ['อาหารครบ 5 หมู่ตามปกติ'],
        avoidFoods: const ['อาหารแปรรูปสะสม'],
        exerciseTip: 'ออกกำลังกายรักษามวลกล้ามเนื้อ',
        dailyAdvice: 'รักษาน้ำหนักตัวให้อยู่ในเกณฑ์มาตรฐานต่อไป',
        followUpSchedule: 'ตรวจวัดประจำปี',
      );
    }
  }
}
