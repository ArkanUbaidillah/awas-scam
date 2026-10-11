enum RiskLevel { aman, waspada, bahaya }

extension RiskLevelX on RiskLevel {
  String get label => switch (this) {
        RiskLevel.aman => 'Aman',
        RiskLevel.waspada => 'Waspada',
        RiskLevel.bahaya => 'Bahaya',
      };
}

class Reason {
  final String category;
  final int weight;
  final String text;
  const Reason(this.category, this.weight, this.text);
}

class Detection {
  final String message;
  final int score; // gabungan 0..100
  final int ruleScore; // skor mesin pola
  final int mlScore; // skor model AI 0..100
  final RiskLevel level;
  final List<Reason> reasons;
  final DateTime checkedAt;
  final bool? feedback; // true = benar penipuan, false = salah tandai, null = belum

  const Detection({
    required this.message,
    required this.score,
    required this.ruleScore,
    required this.mlScore,
    required this.level,
    required this.reasons,
    required this.checkedAt,
    this.feedback,
  });

  Detection copyWith({bool? feedback}) => Detection(
        message: message,
        score: score,
        ruleScore: ruleScore,
        mlScore: mlScore,
        level: level,
        reasons: reasons,
        checkedAt: checkedAt,
        feedback: feedback,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'score': score,
        'ruleScore': ruleScore,
        'mlScore': mlScore,
        'level': level.index,
        'reasons': reasons.map((r) => [r.category, r.weight, r.text]).toList(),
        'checkedAt': checkedAt.toIso8601String(),
        'feedback': feedback,
      };

  static Detection fromJson(Map<String, dynamic> j) => Detection(
        message: j['message'] as String,
        score: j['score'] as int,
        ruleScore: (j['ruleScore'] ?? j['score']) as int,
        mlScore: (j['mlScore'] ?? 0) as int,
        level: RiskLevel.values[j['level'] as int],
        reasons: ((j['reasons'] as List?) ?? [])
            .map((e) => Reason(e[0] as String, e[1] as int, e[2] as String))
            .toList(),
        checkedAt: DateTime.tryParse(j['checkedAt'] as String? ?? '') ?? DateTime.now(),
        feedback: j['feedback'] as bool?,
      );
}
