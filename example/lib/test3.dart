import 'package:flutter/material.dart';

class FloatingConsole {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  static void show(BuildContext context) {
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
}

class _FloatingConsoleWidget extends StatefulWidget {
  const _FloatingConsoleWidget();

  @override
  State<_FloatingConsoleWidget> createState() => _FloatingConsoleWidgetState();
}

class _FloatingConsoleWidgetState extends State<_FloatingConsoleWidget> {
  Offset position = const Offset(20, 100);
  late double width;
  late double height;

  bool isExpanded = true;

  final List<String> logs = [
    "[INFO] 12:30:01: Initializing network services...",
    "[DEBUG] 12:30:02: Connection established to server.",
    "[WARN] 12:30:05: High memory usage detected: 85%.",
    "[ERROR] 12:30:10: Failed to fetch user data: API timeout.",
    "[INFO] 12:30:15: User login successful for 'alex_doe'.",
    "[DEBUG] 12:30:16: Rendering homepage widget.",
    "[WARN] 12:30:20: Image 'avatar.png' loaded with delay: 350ms.",
    "[INFO] 12:30:22: Analytics event 'page_view' logged.",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        width = MediaQuery.of(context).size.width * 0.8;
        height = MediaQuery.of(context).size.height * 0.5; // starts at 50%
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
          });
        },
        child: IgnorePointer(
          ignoring: false, // set true if you want touches to pass through
          child: Material(
            color: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: width,
              height: height,
              constraints: const BoxConstraints(minWidth: 250, minHeight: 200),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Console Logs",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            _buildActionIcon(Icons.copy, "Copy Logs", () {}),
                            _buildActionIcon(Icons.delete, "Clear Logs", () {
                              setState(() => logs.clear());
                            }),
                            _buildActionIcon(Icons.close, "Hide Panel", () {
                              FloatingConsole.hide();
                            }),
                          ],
                        )
                      ],
                    ),
                  ),

                  // Logs area
                  if (isExpanded)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: ListView.builder(
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            Color color = Colors.grey[400]!;
                            if (log.contains("[ERROR]")) color = Colors.redAccent;
                            if (log.contains("[WARN]")) color = Colors.yellowAccent;
                            if (log.contains("[DEBUG]")) color = Colors.greenAccent;
                            return Text(
                              log,
                              style: TextStyle(
                                fontSize: 12,
                                color: color,
                                fontFamily: "monospace",
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Resize handle
                  Container(
                    height: 22,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          width += details.delta.dx;
                          height += details.delta.dy;
                          width = width.clamp(250, MediaQuery.of(context).size.width - 20);
                          height = height.clamp(150, MediaQuery.of(context).size.height - 100);
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.drag_indicator, color: Colors.white54, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
