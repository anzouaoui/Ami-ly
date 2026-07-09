import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DocusignSignaturePage extends StatefulWidget {
  final String signingUrl;
  final String contractId;
  final String userId;
  final VoidCallback onSigned;
  final VoidCallback? onError;

  const DocusignSignaturePage({
    super.key,
    required this.signingUrl,
    required this.contractId,
    required this.userId,
    required this.onSigned,
    this.onError,
  });

  @override
  State<DocusignSignaturePage> createState() => _DocusignSignaturePageState();
}

class _DocusignSignaturePageState extends State<DocusignSignaturePage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
            _checkUrlForCompletion(url);
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
            widget.onError?.call();
          },
          onNavigationRequest: (request) {
            if (_isCompleted) return NavigationDecision.prevent;
            _checkUrlForCompletion(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.signingUrl));
  }

  void _checkUrlForCompletion(String url) {
    if (url.contains('signing_complete') ||
        url.contains('docusign-callback') && url.contains('event=signing_complete')) {
      if (!_isCompleted) {
        _isCompleted = true;
        widget.onSigned();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (!_isCompleted) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Annuler la signature ?'),
                  content: const Text(
                    'Si vous quittez maintenant, la signature ne sera pas complétée.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Continuer'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Quitter'),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
