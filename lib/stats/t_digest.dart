import 'dart:math';
import 'dart:typed_data';

/// A Dart port of Ted Dunning's T-Digest library.
///
/// This implementation focuses on the `MergingDigest`, which is a high-performance,
/// low-memory data structure for estimating quantiles (like percentiles) from a
/// stream of data.
///
/// It is ideal for use cases like calculating "you are faster than N% of players"
/// without storing every single data point.
abstract class TDigest {
  double _min = double.infinity;
  double _max = double.negativeInfinity;

  TDigest();

  /// The smallest value seen so far.
  double get min => _min;

  /// The largest value seen so far.
  double get max => _max;

  /// The total number of points added to this T-Digest.
  int get size;

  /// The number of centroids currently in the digest.
  int get centroidCount;

  /// The compression factor. A higher value increases accuracy but also memory usage.
  /// Common values are between 50 and 200.
  double get compression;

  /// Creates a high-performance `MergingDigest`.
  ///
  /// [compression] controls the trade-off between accuracy and memory.
  /// Higher values are more accurate. A value of 100 is a good starting point.
  factory TDigest.merging({double compression = 100}) {
    return _MergingDigest(compression: compression);
  }

  /// Deserializes a T-Digest from a byte array.
  ///
  /// This is used to reconstruct a digest that was previously saved, for example,
  /// from a database like Firestore.
  factory TDigest.fromBytes(Uint8List bytes) {
    return _MergingDigest.fromBytes(bytes);
  }

  /// Adds a new data point (e.g., a puzzle solve time) to the digest.
  void add(double value);

  /// Forces a merge of any pending data points and compresses the digest.
  /// This is useful before serialization or querying to ensure all data is incorporated.
  void compress();

  /// Calculates the cumulative distribution function (CDF) for a given value.
  ///
  /// This returns the fraction of data points that are less than or equal to `x`.
  /// To get a percentile, multiply the result by 100.
  ///
  /// Example: `digest.cdf(15.5) * 100` gives the percentage of players who
  /// finished in 15.5 seconds or less.
  double cdf(double x);

  /// Serializes the T-Digest to a compact byte array for storage.
  Uint8List asBytes();
}

/// A single centroid, representing a cluster of points.
class Centroid {
  final double mean;
  final double count;

  Centroid(this.mean, this.count);

  @override
  String toString() => 'Centroid(mean: $mean, count: $count)';
}

/// The scale function determines the size of centroids at different quantiles.
/// K_2 (the default) provides high accuracy near the tails (0th and 100th percentile).
enum ScaleFunction {
  k2;

  double z(double compression, double n) {
    return 4 * log(n / compression) + 24;
  }

  double normalizer(double compression, double n) {
    return compression / z(compression, n);
  }

  double max(double q, double normalizer) {
    return q * (1 - q) / normalizer;
  }
}

class _MergingDigest extends TDigest {
  // Configuration
  final double _publicCompression;
  late final double _internalCompression;
  final ScaleFunction _scale = ScaleFunction.k2;

  // State for Merged Centroids
  int _lastUsedCell = 0;
  double _totalWeight = 0;
  late Float64List _weight;
  late Float64List _mean;

  // State for Unmerged (pending) Centroids
  int _tempUsed = 0;
  double _unmergedWeight = 0;
  late Float64List _tempWeight;
  late Float64List _tempMean;
  late Int32List _order;

  // Internal Flags
  int _mergeCount = 0;
  final bool _useAlternatingSort = true;
  final bool _useTwoLevelCompression = true;

  _MergingDigest({required double compression})
      : _publicCompression = compression {
    double c = max(10, compression);

    // Heuristic for buffer sizing from the original Java library
    double sizeFudge = 10;
    if (c < 30) sizeFudge += 20;

    int size = max(2 * c + sizeFudge, 0).ceil();
    int bufferSize = 5 * size;
    bufferSize = max(bufferSize, 2 * size).toInt();

    final scale = _useTwoLevelCompression ? max(1, bufferSize / size - 1) : 1.0;
    _internalCompression = sqrt(scale) * _publicCompression;

    if (size < _internalCompression + sizeFudge) {
      size = (_internalCompression + sizeFudge).ceil();
    }
    if (bufferSize <= 2 * size) {
      bufferSize = 2 * size;
    }

    _weight = Float64List(size);
    _mean = Float64List(size);

    _tempWeight = Float64List(bufferSize);
    _tempMean = Float64List(bufferSize);
    _order = Int32List(bufferSize);
  }

  /// Internal constructor for deserialization
  _MergingDigest._fromBytes(
    double compression,
    int size,
    int bufferSize,
  ) : _publicCompression = compression {
    _internalCompression = compression;
    _weight = Float64List(size);
    _mean = Float64List(size);
    _tempWeight = Float64List(bufferSize);
    _tempMean = Float64List(bufferSize);
    _order = Int32List(bufferSize);
  }

  factory _MergingDigest.fromBytes(Uint8List bytes) {
    final buffer = bytes.buffer;
    final byteData = ByteData.view(buffer);
    int offset = 0;

    // We only implement the SMALL_ENCODING (code 2)
    final encoding = byteData.getInt32(offset, Endian.big);
    offset += 4;
    if (encoding != 2) {
      throw ArgumentError('Invalid or unsupported T-Digest format');
    }

    final min = byteData.getFloat64(offset, Endian.big);
    offset += 8;
    final max = byteData.getFloat64(offset, Endian.big);
    offset += 8;
    final compression = byteData.getFloat32(offset, Endian.big);
    offset += 4;
    final size = byteData.getInt16(offset, Endian.big);
    offset += 2;
    final bufferSize = byteData.getInt16(offset, Endian.big);
    offset += 2;

    final digest = _MergingDigest._fromBytes(compression, size, bufferSize);
    digest._min = min;
    digest._max = max;

    final lastUsedCell = byteData.getInt16(offset, Endian.big);
    offset += 2;
    digest._lastUsedCell = lastUsedCell;

    for (int i = 0; i < lastUsedCell; i++) {
      final w = byteData.getFloat32(offset, Endian.big);
      offset += 4;
      final m = byteData.getFloat32(offset, Endian.big);
      offset += 4;
      digest._weight[i] = w;
      digest._mean[i] = m;
      digest._totalWeight += w;
    }
    return digest;
  }

  @override
  int get size => (_totalWeight + _unmergedWeight).round();

  @override
  int get centroidCount => _lastUsedCell;

  @override
  double get compression => _publicCompression;

  @override
  void add(double x) {
    if (x.isNaN) {
      throw ArgumentError('Cannot add NaN to T-Digest');
    }

    if (_tempUsed >= _tempWeight.length - _lastUsedCell - 1) {
      _mergeNewValues(force: false, compression: _internalCompression);
    }
    int where = _tempUsed++;
    _tempWeight[where] = 1;
    _tempMean[where] = x;
    _unmergedWeight += 1;

    if (x < _min) _min = x;
    if (x > _max) _max = x;
  }

  @override
  void compress() {
    _mergeNewValues(force: true, compression: _publicCompression);
  }

  void _mergeNewValues({required bool force, required double compression}) {
    if (_totalWeight == 0 && _unmergedWeight == 0) {
      return;
    }
    if (force || _unmergedWeight > 0) {
      _merge(
        incomingMean: _tempMean,
        incomingWeight: _tempWeight,
        incomingCount: _tempUsed,
        unmergedWeight: _unmergedWeight,
        runBackwards: _useAlternatingSort && _mergeCount % 2 == 1,
        compression: compression,
      );
      _mergeCount++;
      _tempUsed = 0;
      _unmergedWeight = 0;
    }
  }

  void _merge({
    required Float64List incomingMean,
    required Float64List incomingWeight,
    required int incomingCount,
    required double unmergedWeight,
    required bool runBackwards,
    required double compression,
  }) {
    // Copy existing centroids to the end of the incoming buffer
    incomingMean.setRange(incomingCount, incomingCount + _lastUsedCell, _mean);
    incomingWeight.setRange(
        incomingCount, incomingCount + _lastUsedCell, _weight);
    var currentCount = incomingCount + _lastUsedCell;

    _stableSort(currentCount, incomingMean, _order);

    _totalWeight += unmergedWeight;

    if (runBackwards) {
      _reverse(_order, 0, currentCount);
    }

    // Reset merged centroids
    _lastUsedCell = 0;
    _weight.fillRange(0, _weight.length, 0);
    _mean.fillRange(0, _mean.length, 0);

    if (currentCount == 0) return;

    // Start with the first sorted centroid
    int firstSortedIndex = _order[0];
    _mean[_lastUsedCell] = incomingMean[firstSortedIndex];
    _weight[_lastUsedCell] = incomingWeight[firstSortedIndex];
    double wSoFar = 0;

    final normalizer = _scale.normalizer(compression, _totalWeight);

    for (int i = 1; i < currentCount; i++) {
      int ix = _order[i];
      double proposedWeight = _weight[_lastUsedCell] + incomingWeight[ix];
      bool addThis;

      // Determine if the next centroid can be merged into the current one
      final q0 = wSoFar / _totalWeight;
      final q2 = (wSoFar + proposedWeight) / _totalWeight;
      addThis = proposedWeight <=
          _totalWeight *
              min(_scale.max(q0, normalizer), _scale.max(q2, normalizer));

      // First and last centroids should never be merged
      if (i == 1 || i == currentCount - 1) {
        addThis = false;
      }

      if (addThis) {
        // Merge into the current centroid
        _weight[_lastUsedCell] += incomingWeight[ix];
        _mean[_lastUsedCell] = _weightedAverage(
            _mean[_lastUsedCell],
            _weight[_lastUsedCell] - incomingWeight[ix],
            incomingMean[ix],
            incomingWeight[ix]);
      } else {
        // Create a new centroid
        wSoFar += _weight[_lastUsedCell];
        _lastUsedCell++;
        _mean[_lastUsedCell] = incomingMean[ix];
        _weight[_lastUsedCell] = incomingWeight[ix];
      }
    }
    _lastUsedCell++;

    if (runBackwards) {
      _reverse(_mean, 0, _lastUsedCell);
      _reverse(_weight, 0, _lastUsedCell);
    }

    if (_totalWeight > 0) {
      _min = min(_min, _mean[0]);
      _max = max(_max, _mean[_lastUsedCell - 1]);
    }
  }

  @override
  double cdf(double x) {
    if (x.isNaN) throw ArgumentError('CDF is not defined for NaN');

    compress();

    if (_lastUsedCell == 0) {
      return double.nan;
    }
    if (_lastUsedCell == 1) {
      if (x < _min) return 0.0;
      if (x > _max) return 1.0;
      return 0.5; // Single point
    }

    if (x < _min) return 0.0;
    if (x > _max) return 1.0;

    // Left tail
    if (x < _mean[0]) {
      if (_mean[0] - _min > 0) {
        return (x == _min)
            ? 0.5 / _totalWeight
            : (1 + (x - _min) / (_mean[0] - _min) * (_weight[0] / 2 - 1)) /
                _totalWeight;
      }
      return 0.0;
    }

    // Right tail
    if (x > _mean[_lastUsedCell - 1]) {
      if (_max - _mean[_lastUsedCell - 1] > 0) {
        return (x == _max)
            ? 1 - 0.5 / _totalWeight
            : 1 -
                (1 +
                        (_max - x) /
                            (_max - _mean[_lastUsedCell - 1]) *
                            (_weight[_lastUsedCell - 1] / 2 - 1)) /
                    _totalWeight;
      }
      return 1.0;
    }

    // Interpolate between centroids
    double weightSoFar = 0;
    for (int i = 0; i < _lastUsedCell - 1; i++) {
      if (_mean[i] <= x && x < _mean[i + 1]) {
        if (_mean[i + 1] - _mean[i] > 0) {
          final double leftUnit = (_weight[i] == 1) ? 0.5 : 0;
          final double rightUnit = (_weight[i + 1] == 1) ? 0.5 : 0;
          final double dw = (_weight[i] + _weight[i + 1]) / 2.0;

          final double dwNoSingleton = dw - leftUnit - rightUnit;
          final double base = weightSoFar + _weight[i] / 2.0 + leftUnit;

          return (base +
                  dwNoSingleton * (x - _mean[i]) / (_mean[i + 1] - _mean[i])) /
              _totalWeight;
        } else {
          // Centroids are at the same location
          return (weightSoFar + _weight[i] / 2.0) / _totalWeight;
        }
      }
      weightSoFar += _weight[i];
    }

    // x must be at the location of the last centroid
    if (x == _mean[_lastUsedCell - 1]) {
      return 1.0 - _weight[_lastUsedCell - 1] / 2.0 / _totalWeight;
    }

    // Should not be reached.
    return 1.0;
  }

  @override
  Uint8List asBytes() {
    compress();

    final sizeInBytes = 4 + 8 + 8 + 4 + 2 + 2 + 2 + (_lastUsedCell * 8);
    final buffer = ByteData(sizeInBytes);
    int offset = 0;

    // Use SMALL_ENCODING format (code 2)
    buffer.setInt32(offset, 2, Endian.big);
    offset += 4;
    buffer.setFloat64(offset, _min, Endian.big);
    offset += 8;
    buffer.setFloat64(offset, _max, Endian.big);
    offset += 8;
    buffer.setFloat32(offset, _publicCompression, Endian.big);
    offset += 4;
    buffer.setInt16(offset, _mean.length, Endian.big);
    offset += 2;
    buffer.setInt16(offset, _tempMean.length, Endian.big);
    offset += 2;
    buffer.setInt16(offset, _lastUsedCell, Endian.big);
    offset += 2;

    for (int i = 0; i < _lastUsedCell; i++) {
      buffer.setFloat32(offset, _weight[i], Endian.big);
      offset += 4;
      buffer.setFloat32(offset, _mean[i], Endian.big);
      offset += 4;
    }

    return buffer.buffer.asUint8List(0, offset);
  }
}

// -Helper Functions-

/// Sorts an index array `order` based on the values in `values`.
void _stableSort(int n, Float64List values, Int32List order) {
  for (int i = 0; i < n; i++) {
    order[i] = i;
  }
  // Dart's sort is stable.
  order.sublist(0, n).sort((a, b) => values[a].compareTo(values[b]));
}

/// Reverses a portion of a list.
void _reverse<T>(List<T> list, int offset, int length) {
  for (int i = 0; i < length / 2; i++) {
    T temp = list[offset + i];
    list[offset + i] = list[offset + length - 1 - i];
    list[offset + length - 1 - i] = temp;
  }
}

/// Computes a weighted average, ensuring the result is between x1 and x2.
double _weightedAverage(double x1, double w1, double x2, double w2) {
  if (x1 <= x2) {
    final double x = (x1 * w1 + x2 * w2) / (w1 + w2);
    return max(x1, min(x, x2));
  } else {
    return _weightedAverage(x2, w2, x1, w1);
  }
}
