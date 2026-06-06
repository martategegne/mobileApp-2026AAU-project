import 'dart:html' as html;

/// Triggers a browser download dialog for the given [url].
void triggerWebDownload(String url, String filename) {
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}
