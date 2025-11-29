import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:ui';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:developer';

/// 🔹 Log Type Enum
enum LogType { info, warning, error }

/// 🔹 Log Entry
class LogEntry {
  final String message;
  final LogType type;
  final DateTime timestamp;

  LogEntry(this.message, this.type) : timestamp = DateTime.now();
}

/// 🔹 Main Logger Class (Logic intact)
class DebugLogConsole {
  static final List<LogEntry> _logs = [];
  static final ValueNotifier<List<LogEntry>> logsNotifier =
      ValueNotifier<List<LogEntry>>([]);

  static int maxLogCount = 2000; // ✅ you already have this
  static const int _maxMessageLength = 8000; // 8 KB per log message
  static Timer? _debounce; // for smooth UI updates

  /// ✅ Use this instead of print()
  static void Function(String, {LogType type}) customLog = _defaultLog;

  static void _defaultLog(String message, {LogType type = LogType.info}) {
    if (!kDebugMode) return;
    addLog(message, type: type);
    debugPrint(message);
  }

  /// ✅ Add log with truncation, size limit, and debounce
  static void addLog(String message, {LogType type = LogType.info}) {
    // 🔹 Truncate overly large messages
    if (message.length > _maxMessageLength) {
      message = '${message.substring(0, _maxMessageLength)}... [truncated]';
    }

    // 🔹 Limit total logs to avoid heap growth
    if (_logs.length >= maxLogCount) {
      _logs.removeAt(0);
    }

    _logs.add(LogEntry(message, type));

    // 🔹 Debounce UI rebuilds to prevent jank during spam logging
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      // ✅ trigger safely — no direct notifyListeners()
      logsNotifier.value = List.from(_logs);
    });
  }

  /// ✅ Public method to log easily
  static void log(String message, {LogType type = LogType.info}) {
    if (!kDebugMode) return;
    customLog(message, type: type);
  }

  static List<LogEntry> get logs => _logs;

  /// ✅ Export logs safely as text or JSON
  static Future<String> exportLogs({bool asJson = false}) async {
    if (asJson) {
      final jsonList = _logs
          .map((e) => {
                "message": e.message,
                "type": e.type.name,
                "timestamp": e.timestamp.toIso8601String(),
              })
          .toList();
      return jsonEncode(jsonList);
    } else {
      final buffer = StringBuffer();
      for (var log in _logs) {
        buffer.writeln(
          "[${log.timestamp.toIso8601String()}] (${log.type.name.toUpperCase()}) ${log.message}",
        );
      }
      return buffer.toString();
    }
  }

  static void clear() {
    _logs.clear();
    logsNotifier.value = List.from(_logs);
  }
}

/// 🔹 Floating Console Overlay (UI)
class FloatingConsole {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  static void show(BuildContext context) {
    if (!kDebugMode) return;

    if (_isVisible) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => const _FloatingConsoleWidget(),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    _isVisible = true;
  }

  static void hide() {
    _overlayEntry?.remove();
    _isVisible = false;
  }

  static void toggle(BuildContext context) {
    if (_isVisible) {
      hide();
    } else {
      show(context);
    }
  }

  static bool get isVisible => _isVisible;
}

class _FloatingConsoleWidget extends StatefulWidget {
  const _FloatingConsoleWidget();

  @override
  State<_FloatingConsoleWidget> createState() => _FloatingConsoleWidgetState();
}

class _FloatingConsoleWidgetState extends State<_FloatingConsoleWidget> {
  Offset position = const Offset(20, 100);
  double width = 300;
  double height = 250;
  LogType? filterType;
  final ScrollController _scrollController = ScrollController();
  String _searchKeyword = "";

  bool _autoScrollEnabled = true;

  final Set<LogType> _selectedTypes = {}; // empty means "show all"

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        width = MediaQuery.of(context).size.width * 0.8;
        height = MediaQuery.of(context).size.height * 0.5;
      });
    });

    // ✅ Track user scrolling
    _scrollController.addListener(_handleScroll);
    // ✅ Auto-scroll listener when logs change
    DebugLogConsole.logsNotifier.addListener(_scrollToBottomIfNeeded);
  }

  @override
  void dispose() {
    DebugLogConsole.logsNotifier.removeListener(_scrollToBottomIfNeeded);
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// ✅ Detect if user scrolls away from bottom
  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final distanceFromBottom = (maxScroll - currentScroll).abs();

    // If user scrolls up more than 80px, disable auto-scroll
    if (distanceFromBottom > 80 && _autoScrollEnabled) {
      setState(() => _autoScrollEnabled = false);
    }

    // If user returns to near bottom, re-enable auto-scroll
    if (distanceFromBottom <= 80 && !_autoScrollEnabled) {
      setState(() => _autoScrollEnabled = true);
    }
  }

  /// ✅ Scrolls to bottom only if user is near it
  void _scrollToBottomIfNeeded() {
    if (!_autoScrollEnabled || !_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) => setState(() => position += details.delta),
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: width,
            height: height,
            constraints: const BoxConstraints(minWidth: 250, minHeight: 200),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 12,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(child: _buildLogsList()),
                _buildResizeHandle(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Updated Header with Type & Tag Filter
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: (0.1))),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Row 1: Filter Checkboxes
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildFilterCheckbox("INFO", LogType.info, Colors.greenAccent),
              _buildFilterCheckbox(
                  "WARN", LogType.warning, Colors.yellowAccent),
              _buildFilterCheckbox("ERROR", LogType.error, Colors.redAccent),
            ],
          ),
          const SizedBox(height: 8),
          // 🔹 Row 2: Search + Action Icons
          Row(
            children: [
              // ✅ Search Field (Flexible)
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "Search logs...",
                    hintStyle:
                        TextStyle(color: Colors.white.withValues(alpha: (0.5))),
                    prefixIcon: const Icon(Icons.search,
                        color: Colors.white70, size: 16),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: (0.05)),
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: (0.2))),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: (0.2))),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: (0.4))),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchKeyword = value.trim().toLowerCase();
                    });
                  },
                ),
              ),

              const SizedBox(width: 8),

              // ✅ Action Icons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionIcon(Icons.copy, "Copy Logs", () async {
                    final data = await DebugLogConsole.exportLogs();
                    await Clipboard.setData(ClipboardData(text: data));
                  }),
                  _buildActionIcon(Icons.download, "Export Logs", () async {
                    try {
                      final jsonData =
                          await DebugLogConsole.exportLogs(asJson: true);
                      final Uint8List bytes =
                          Uint8List.fromList(jsonData.codeUnits);

                      final timestamp =
                          DateTime.now().toIso8601String().replaceAll(':', '-');
                      final fileName = 'debug_logs_$timestamp.json';

                      await FileSaver.instance.saveAs(
                        name: fileName,
                        bytes: bytes,
                        mimeType: MimeType.json,
                        fileExtension: 'json',
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Logs exported as $fileName"),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to export logs: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }),
                  _buildActionIcon(Icons.delete, "Clear Logs", () {
                    DebugLogConsole.clear();
                  }),
                  _buildActionIcon(Icons.close, "Hide Panel", () {
                    FloatingConsole.hide();
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ Checkbox Filter Builder
  Widget _buildFilterCheckbox(String label, LogType type, Color color) {
    final isSelected = _selectedTypes.contains(type);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTypes.remove(type);
          } else {
            _selectedTypes.add(type);
          }
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (_) {
              setState(() {
                if (isSelected) {
                  _selectedTypes.remove(type);
                } else {
                  _selectedTypes.add(type);
                }
              });
            },
            activeColor: color,
            checkColor: Colors.black,
            side: BorderSide(color: color.withValues(alpha: (0.8))),
          ),
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  /// 🔹 Updated Logs List with Type + Tag Filter
  /// 🔹 Logs List with Text Selection Support
  /// ✅ Logs List — full selectable area (multi-line selection supported)
  /// ✅ Logs List — multi-line selectable + persistent selection
  Widget _buildLogsList() {
    return _PersistentSelectableConsole(
      scrollController: _scrollController,
      filterTypes: _selectedTypes, // ✅ Pass the new set of active filters
      keyword: _searchKeyword,
    );
  }

  Widget _buildResizeHandle(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          width += details.delta.dx;
          height += details.delta.dy;
          width = width.clamp(250, MediaQuery.of(context).size.width - 20);
          height = height.clamp(150, MediaQuery.of(context).size.height - 100);
        });
      },
      child: Container(
        height: 22,
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: (0.1))),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.drag_indicator, color: Colors.white54, size: 18),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, size: 18, color: Colors.white70),
        ),
      ),
    );
  }
}

/// 🔹 Floating Draggable Debug Button
class FloatingDebugButton {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => const _FloatingDebugButtonWidget(),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _FloatingDebugButtonWidget extends StatefulWidget {
  const _FloatingDebugButtonWidget();

  @override
  State<_FloatingDebugButtonWidget> createState() =>
      _FloatingDebugButtonWidgetState();
}

class _FloatingDebugButtonWidgetState
    extends State<_FloatingDebugButtonWidget> {
  Offset position = const Offset(30, 150);

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) => setState(() => position += details.delta),
        onTap: () => FloatingConsole.toggle(context),
        child: const Material(
          elevation: 6,
          shape: CircleBorder(),
          color: Colors.deepPurpleAccent,
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(Icons.bug_report, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}

class ConsolePlus {
  static bool _initialized = false;

  static Future<void> initApp(
    Widget app, {
    bool interceptPrints = true,
    bool captureFlutterErrors = true,
    bool capturePlatformErrors = true,
  }) async {
    if (_initialized) return;
    _initialized = true;

    // ✅ Step 1: Build the ZoneSpecification for print()
    final spec = ZoneSpecification(
      print: (self, parent, zone, line) {
        if (interceptPrints) {
          DebugLogConsole.addLog(line, type: _detectType(line));
        }
        parent.print(zone, line); // still goes to IDE console
      },
    );

    // ✅ Step 2: Run Flutter initialization + runApp in the SAME zone
    Zone.current.fork(specification: spec).run(() async {
      WidgetsFlutterBinding.ensureInitialized();

      if (captureFlutterErrors) {
        FlutterError.onError = (FlutterErrorDetails details) {
          DebugLogConsole.addLog(
            "[FlutterError] ${details.exceptionAsString()}\n${details.stack ?? ''}",
            type: LogType.error,
          );
          FlutterError.presentError(details);
        };
      }

      if (capturePlatformErrors) {
        PlatformDispatcher.instance.onError = (error, stack) {
          DebugLogConsole.addLog(
            "[PlatformError] $error\n$stack",
            type: LogType.error,
          );
          return true;
        };
      }

      DebugLogConsole.addLog(
        "✅ ConsolePlus initialized — print & debugPrint interception active",
        type: LogType.info,
      );

      runApp(app);
    });
  }

  /// ✅ Intercept dart:developer.log()

  static LogType _detectType(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('error') ||
        lower.contains('exception') ||
        lower.contains('fail')) {
      return LogType.error;
    }
    if (lower.contains('warn')) return LogType.warning;
    return LogType.info;
  }
}

typedef DeveloperLogHandler = void Function(String message,
    {String name, int level, Object? error, StackTrace? stackTrace});

class ConsolePlusLog {
  static DeveloperLogHandler? _customHandler;

  static void overrideLogHandler(DeveloperLogHandler handler) {
    _customHandler = handler;
  }

  static void log(String message,
      {String name = '',
      int level = 0,
      Object? error,
      StackTrace? stackTrace}) {
    if (_customHandler != null) {
      _customHandler!(
        message,
        name: name,
        level: level,
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      dev.log(message,
          name: name, level: level, error: error, stackTrace: stackTrace);
    }
  }
}

/// 🟩 NEW: Early Print Capturer
class PrintCapturer {
  static void runAppWithCapture(VoidCallback appRunner) {
    runZonedGuarded(() {
      final spec = ZoneSpecification(
        print: (self, parent, zone, line) {
          DebugLogConsole.addLog(line);
          parent.print(zone, line);
        },
      );
      Zone.current.fork(specification: spec).run(appRunner);
    }, (error, stack) {
      DebugLogConsole.addLog("🔥 Uncaught Error: $error", type: LogType.error);
      DebugLogConsole.addLog("$stack", type: LogType.error);
    });
  }
}

class _PersistentSelectableConsole extends StatefulWidget {
  final ScrollController scrollController;
  final Set<LogType> filterTypes;
  final String keyword;

  const _PersistentSelectableConsole({
    required this.scrollController,
    required this.filterTypes,
    required this.keyword,
  });

  @override
  State<_PersistentSelectableConsole> createState() =>
      _PersistentSelectableConsoleState();
}

class _PersistentSelectableConsoleState
    extends State<_PersistentSelectableConsole> {
  final TextEditingController _controller = TextEditingController();
  static const int _maxVisibleLogs = 500; // ✅ Show only the last 500 logs

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateLogs(List<LogEntry> logs) {
    // ✅ Limit logs to recent subset for performance
    final recentLogs = logs.length > _maxVisibleLogs
        ? logs.sublist(logs.length - _maxVisibleLogs)
        : logs;

    // ✅ Apply filters and keyword
    final filtered = recentLogs.where((log) {
      final matchType =
          widget.filterTypes.isEmpty || widget.filterTypes.contains(log.type);
      final matchKeyword = widget.keyword.isEmpty ||
          log.message.toLowerCase().contains(widget.keyword);
      return matchType && matchKeyword;
    }).toList();

    // ✅ Build efficient text buffer
    final buffer = StringBuffer();
    for (var log in filtered) {
      final ms = log.timestamp.millisecond.toString().padLeft(3, '0');
      final timeString = "${log.timestamp.hour.toString().padLeft(2, '0')}:"
          "${log.timestamp.minute.toString().padLeft(2, '0')}:"
          "${log.timestamp.second.toString().padLeft(2, '0')}."
          "$ms";

      // 🧠 Efficiently truncate overly long lines
      final msg = log.message.length > 4000
          ? '${log.message.substring(0, 4000)}... [truncated]'
          : log.message;

      buffer.writeln("[$timeString] [${log.type.name.toUpperCase()}] $msg");
    }

    // ✅ Only update text if significantly changed
    if (_controller.text != buffer.toString()) {
      _controller.text = buffer.toString();
    }

    // ✅ Maintain scroll position near bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.scrollController.hasClients) return;
      final pos = widget.scrollController.position;
      final distance = (pos.maxScrollExtent - pos.pixels).abs();
      if (distance < 100) {
        widget.scrollController.animateTo(
          pos.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<LogEntry>>(
      valueListenable: DebugLogConsole.logsNotifier,
      builder: (context, logs, _) {
        _updateLogs(logs);

        return Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(10),
          child: Scrollbar(
            thumbVisibility: true,
            controller: widget.scrollController,
            radius: const Radius.circular(8),

            /// ✅ Vertical & horizontal scrolls separated
            child: SingleChildScrollView(
              controller: widget.scrollController,
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 800),
                  child: SelectableText(
                    _controller.text.isEmpty
                        ? "(No logs yet)"
                        : _controller.text,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontFamily: "monospace",
                      height: 1.3,
                    ),
                    cursorColor: Colors.white,
                    enableInteractiveSelection: true,
                    selectionHeightStyle: BoxHeightStyle.tight,
                    selectionWidthStyle: BoxWidthStyle.max,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
