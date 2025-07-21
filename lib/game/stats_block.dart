import 'package:phrazy/stats/t_digest.dart';
import 'package:phrazy/utility/debug.dart';

class StatsBlock {
  bool isInitialized = false;
  double cdf;

  StatsBlock({required this.cdf});

  factory StatsBlock.empty() {
    return StatsBlock(cdf: -1);
  }

  void initialize(TDigest digest, double timeSeconds) {
    cdf = digest.size > 5 ? digest.cdf(timeSeconds) : -1;
    debug("CDF tested against $timeSeconds, set to $cdf");
    isInitialized = true;
  }

  @override
  String toString() {
    if (!isInitialized) return "";

    final cdfString = cdf >= 0
        ? "Faster than ${((1 - cdf) * 100).toStringAsFixed(1)} % of players!"
        : "You're one of the first to solve this Phrazy!";
    return cdfString;
  }
}
