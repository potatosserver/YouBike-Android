// PWA Service Worker for YouBike 站點搜尋
// 使用 Cache-First 策略：優先從快取載入，離線時仍可使用

const CACHE_NAME = 'youbike-cache-v1';
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/favicon.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png',
  '/flutter_bootstrap.js',
  '/flutter.js',
];

// 安裝：預先快取靜態資源
self.addEventListener('install', (event) => {
  console.log('[PWA SW] 安裝中...');
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('[PWA SW] 預先快取靜態資源');
      return cache.addAll(STATIC_ASSETS);
    }).then(() => {
      console.log('[PWA SW] 安裝完成，跳過等待');
      return self.skipWaiting();
    })
  );
});

// 啟用：清理舊版快取
self.addEventListener('activate', (event) => {
  console.log('[PWA SW] 啟用中...');
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME)
          .map((name) => {
            console.log('[PWA SW] 刪除舊快取:', name);
            return caches.delete(name);
          })
      );
    }).then(() => {
      console.log('[PWA SW] 立即接管所有頁面');
      return self.clients.claim();
    })
  );
});

// 請求攔截：Network First 策略 (先嘗試網路，失敗時回退快取)
self.addEventListener('fetch', (event) => {
  // 跳過非 GET 請求
  if (event.request.method !== 'GET') return;

  // 跳過 chrome-extension 等非 http(s) 請求
  const url = new URL(event.request.url);
  if (!url.protocol.startsWith('http')) return;

  event.respondWith(
    fetch(event.request)
      .then((response) => {
        // 只快取成功的 GET 回應
        if (response.status === 200) {
          const responseClone = response.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseClone);
          });
        }
        return response;
      })
      .catch(() => {
        // 網路失敗時，嘗試從快取提供
        return caches.match(event.request).then((cachedResponse) => {
          if (cachedResponse) {
            return cachedResponse;
          }
          // 對於導航請求，回退到 index.html (SPA 支援)
          if (event.request.mode === 'navigate') {
            return caches.match('/index.html');
          }
          // 無法提供任何內容
          return new Response('離線狀態，無法載入此資源', {
            status: 503,
            statusText: 'Service Unavailable',
          });
        });
      })
  );
});

// 接收來自主執行緒的訊息
self.addEventListener('message', (event) => {
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
  }
});