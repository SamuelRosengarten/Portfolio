{{flutter_js}}
{{flutter_build_config}}
_flutter.loader.load({
  // Serve the CanvasKit engine (WebGL/Wasm renderer) from this site's own
  // build/web/canvaskit/ directory instead of the default
  // https://www.gstatic.com/flutter-canvaskit/... CDN — one fewer
  // third-party origin the page depends on to render at all.
  config: {
    canvasKitBaseUrl: "canvaskit/"
  },
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}}
  }
});
