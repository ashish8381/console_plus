library console_plus;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'console_plus_platform_interface.dart';

/// ✅ 1. Add LogType enum at top
enum LogType { info, warning, error }

/// ✅ 2. Add LogEntry class just after enum
class LogEntry {
  final String message;
  final LogType type;
  final DateTime timestamp;

  LogEntry(this.message, this.type) : timestamp = DateTime.now();
}

/// ✅ 3. Main Logger Class
class DebugLogConsole {
  static final List<LogEntry> _logs = [];
  static OverlayEntry? _overlayEntry;
  static int maxLogCount = 2000; // ✅ Limit log memory size

  /// ✅ Use this instead of print()
  static void Function(String, {LogType type}) customLog = _defaultLog;

  static void _defaultLog(String message, {LogType type = LogType.info}) {
    if (!kDebugMode) return;
    addLog(message, type: type);
    debugPrint(message);
  }

  static final ValueNotifier<List<LogEntry>> logsNotifier =
  ValueNotifier<List<LogEntry>>([]);

  static void addLog(String message, {LogType type = LogType.info}) {
    if (_logs.length >= maxLogCount) _logs.removeAt(0);
    _logs.add(LogEntry(message, type));
    logsNotifier.value = List.from(_logs); // 🔥 Notifies UI
  }

  static void log(String message, {LogType type = LogType.info}) {
    if (!kDebugMode) return;
    customLog(message, type: type);
  }

  static List<LogEntry> get logs => _logs;

  static void show(BuildContext context) {
    if (!kDebugMode) return;

    if (_overlayEntry != null) {
      hide();
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => _LogConsoleWidget(),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }



  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// ✅ Export logs to .txt or .json
  static Future<String> exportLogs({bool asJson = false}) async {
    if (asJson) {
      final jsonList = _logs.map((e) => {
        "message": e.message,
        "type": e.type.name,
        "timestamp": e.timestamp.toIso8601String()
      }).toList();
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
}


class _LogConsoleWidget extends StatefulWidget {
  @override
  State<_LogConsoleWidget> createState() => _LogConsoleWidgetState();
}

class _LogConsoleWidgetState extends State<_LogConsoleWidget> {
  Offset position = const Offset(20, 100);
  LogType? filterType;
  bool _isConsoleOpen = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() => position += details.delta);
            },
            // onTap: () => _openConsole(context),
            onTap: () {
              _toggleConsole(context);
              // DebugLogConsole.show(context); // ✅ Now acts as show/hide toggle
            },
            child: const CircleAvatar(
              radius: 23,
              child: Icon(Icons.bug_report),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleConsole(BuildContext context) {
    if (_isConsoleOpen) {
      Navigator.of(context, rootNavigator: true).pop(); // ✅ Safely close sheet
      _isConsoleOpen = false;
      return;
    }

    _isConsoleOpen = true;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.5,
            maxChildSize: 0.9,
            minChildSize: 0.2,
            builder: (_, scrollController) {
              return _buildConsoleContent(scrollController, setSheetState);
            },
          );
        });
      },
    ).whenComplete(() {
      _isConsoleOpen = false;
    });
  }


  Widget _buildConsoleContent(ScrollController scrollController, Function setSheetState) {

    // List<LogEntry> visibleLogs = List.unmodifiable(
    //   filterType == null
    //       ? DebugLogConsole.logs
    //       : DebugLogConsole.logs.where((l) => l.type == filterType),
    // );


    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });


    return SafeArea(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text("Debug Logs",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              DropdownButton<LogType?>(
                dropdownColor: Colors.black87,
                value: filterType,
                icon: const Icon(Icons.filter_alt, color: Colors.white),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text("All", style: TextStyle(color: Colors.white)),
                  ),
                  ...LogType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase(),
                        style: const TextStyle(color: Colors.white)),
                  ))
                ],
                onChanged: (value) {
                  setSheetState(() => filterType = value);
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.download, color: Colors.greenAccent),
                onPressed: () async {
                  final data = await DebugLogConsole.exportLogs();
                  debugPrint(data);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  DebugLogConsole.logs.clear();
                  DebugLogConsole.logsNotifier.value = List.from(DebugLogConsole.logs);
                },
              ),
            ],
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: DebugLogConsole.logsNotifier,
              builder: (_, logs, __) {
                final visibleLogs = filterType == null
                    ? logs
                    : logs.where((l) => l.type == filterType).toList();

                return ListView.builder(
                  controller: scrollController,
                  itemCount: visibleLogs.length,
                  itemBuilder: (_, i) {
                    final log = visibleLogs[i];
                    return Text(
                      "[${log.type.name.toUpperCase()}] ${log.message}",
                      style: TextStyle(
                        color: log.type == LogType.error
                            ? Colors.red
                            : log.type == LogType.warning
                            ? Colors.yellow
                            : Colors.white,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }



}


class ConsolePlus {
  Future<String?> getPlatformVersion() {
    return ConsolePlusPlatform.instance.getPlatformVersion();
  }
}