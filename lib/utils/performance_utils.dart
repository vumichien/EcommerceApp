import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PerformanceUtils {
  static const bool _enableLogging = kDebugMode;
  
  /// Measures execution time of a function
  static Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await operation();
      stopwatch.stop();
      
      if (_enableLogging) {
        dev.log(
          '$operationName completed in ${stopwatch.elapsedMilliseconds}ms',
          name: 'Performance',
        );
      }
      
      return result;
    } catch (e) {
      stopwatch.stop();
      if (_enableLogging) {
        dev.log(
          '$operationName failed after ${stopwatch.elapsedMilliseconds}ms: $e',
          name: 'Performance',
        );
      }
      rethrow;
    }
  }

  /// Measures execution time of a synchronous function
  static T measureSync<T>(
    String operationName,
    T Function() operation,
  ) {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = operation();
      stopwatch.stop();
      
      if (_enableLogging) {
        dev.log(
          '$operationName completed in ${stopwatch.elapsedMilliseconds}ms',
          name: 'Performance',
        );
      }
      
      return result;
    } catch (e) {
      stopwatch.stop();
      if (_enableLogging) {
        dev.log(
          '$operationName failed after ${stopwatch.elapsedMilliseconds}ms: $e',
          name: 'Performance',
        );
      }
      rethrow;
    }
  }

  /// Debounce function calls to improve performance
  static void Function() debounce(
    Duration delay,
    void Function() action,
  ) {
    Timer? timer;
    
    return () {
      timer?.cancel();
      timer = Timer(delay, action);
    };
  }

  /// Throttle function calls to limit execution frequency
  static void Function() throttle(
    Duration delay,
    void Function() action,
  ) {
    bool isThrottled = false;
    
    return () {
      if (isThrottled) return;
      
      isThrottled = true;
      action();
      
      Timer(delay, () {
        isThrottled = false;
      });
    };
  }

  /// Log memory usage (debug mode only)
  static void logMemoryUsage(String context) {
    if (!_enableLogging) return;
    
    // This is a simplified memory check
    // In production, you might want to use more sophisticated monitoring
    dev.log(
      'Memory check at: $context',
      name: 'Memory',
    );
  }
}

/// Mixin for widgets that need performance monitoring
mixin PerformanceMonitor<T extends StatefulWidget> on State<T> {
  Stopwatch? _buildStopwatch;
  
  @override
  void initState() {
    super.initState();
    PerformanceUtils.logMemoryUsage('${widget.runtimeType} initState');
  }

  @override
  Widget build(BuildContext context) {
    _buildStopwatch = Stopwatch()..start();
    
    final widget = buildWidget(context);
    
    _buildStopwatch?.stop();
    if (kDebugMode && _buildStopwatch != null) {
      if (_buildStopwatch!.elapsedMilliseconds > 16) { // More than one frame
        dev.log(
          '${this.widget.runtimeType} build took ${_buildStopwatch!.elapsedMilliseconds}ms',
          name: 'Performance',
        );
      }
    }
    
    return widget;
  }

  @override
  void dispose() {
    PerformanceUtils.logMemoryUsage('${widget.runtimeType} dispose');
    super.dispose();
  }

  /// Override this instead of build method
  Widget buildWidget(BuildContext context);
}

/// Widget that shows performance overlay in debug mode
class PerformanceOverlay extends StatelessWidget {
  final Widget child;
  final bool showFPS;
  final bool showRasterCache;

  const PerformanceOverlay({
    super.key,
    required this.child,
    this.showFPS = true,
    this.showRasterCache = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return child;

    return Stack(
      children: [
        child,
        if (showFPS)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Performance Mode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Cache for expensive computations
class ComputationCache<K, V> {
  final Map<K, V> _cache = {};
  final int maxSize;
  final Duration? ttl;
  final Map<K, DateTime> _timestamps = {};

  ComputationCache({
    this.maxSize = 100,
    this.ttl,
  });

  V? get(K key) {
    if (!_cache.containsKey(key)) return null;

    // Check TTL
    if (ttl != null && _timestamps[key] != null) {
      final age = DateTime.now().difference(_timestamps[key]!);
      if (age > ttl!) {
        _cache.remove(key);
        _timestamps.remove(key);
        return null;
      }
    }

    return _cache[key];
  }

  void put(K key, V value) {
    // Remove oldest entries if cache is full
    if (_cache.length >= maxSize) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
      _timestamps.remove(oldestKey);
    }

    _cache[key] = value;
    if (ttl != null) {
      _timestamps[key] = DateTime.now();
    }
  }

  V getOrCompute(K key, V Function() compute) {
    final cached = get(key);
    if (cached != null) return cached;

    final computed = compute();
    put(key, computed);
    return computed;
  }

  void clear() {
    _cache.clear();
    _timestamps.clear();
  }

  int get size => _cache.length;
}

/// Lazy loading list for better performance with large datasets
class LazyLoadingList<T> {
  final List<T> _items = [];
  final Future<List<T>> Function(int offset, int limit) _loadMore;
  final int _pageSize;
  bool _isLoading = false;
  bool _hasMore = true;

  LazyLoadingList({
    required Future<List<T>> Function(int offset, int limit) loadMore,
    int pageSize = 20,
  }) : _loadMore = loadMore, _pageSize = pageSize;

  List<T> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get length => _items.length;

  Future<void> loadNextPage() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    
    try {
      final newItems = await _loadMore(_items.length, _pageSize);
      
      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        _items.addAll(newItems);
        if (newItems.length < _pageSize) {
          _hasMore = false;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('Error loading next page: $e', name: 'LazyLoading');
      }
    } finally {
      _isLoading = false;
    }
  }

  void clear() {
    _items.clear();
    _hasMore = true;
  }

  T operator [](int index) => _items[index];
}

/// Image caching and optimization utilities
class ImageOptimization {
  static const int _maxCacheSize = 50;
  static final Map<String, ImageProvider> _imageCache = {};

  static ImageProvider? getCachedImage(String url) {
    return _imageCache[url];
  }

  static void cacheImage(String url, ImageProvider image) {
    if (_imageCache.length >= _maxCacheSize) {
      final firstKey = _imageCache.keys.first;
      _imageCache.remove(firstKey);
    }
    _imageCache[url] = image;
  }

  static void clearCache() {
    _imageCache.clear();
  }

  /// Preload images for better UX
  static Future<void> preloadImage(String assetPath, BuildContext context) async {
    await precacheImage(AssetImage(assetPath), context);
  }

  /// Get optimized image size based on device pixel ratio
  static Size getOptimalImageSize(Size displaySize, BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Size(
      displaySize.width * devicePixelRatio,
      displaySize.height * devicePixelRatio,
    );
  }
}

/// Timer utilities
class TimerUtils {
  static Timer? _timer;
  
  static void executeAfter(Duration delay, void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
  
  static void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}