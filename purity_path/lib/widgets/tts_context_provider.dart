import 'package:flutter/material.dart';
import 'package:purity_path/data/services/tts_service.dart';

/// Wrapper widget that provides context to TTSService
/// Wrap your main navigation/home with this to enable visual overlays
class TTSContextProvider extends StatefulWidget {
  final Widget child;

  const TTSContextProvider({
    super.key,
    required this.child,
  });

  @override
  State<TTSContextProvider> createState() => _TTSContextProviderState();
}

class _TTSContextProviderState extends State<TTSContextProvider> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provide context to TTS service
    TTSService.setContext(context);
  }

  @override
  void dispose() {
    // Remove context when widget is disposed
    TTSService.removeContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
