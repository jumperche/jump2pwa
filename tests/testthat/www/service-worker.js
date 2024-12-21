const CACHE_NAME = 'shiny-pwa-cache-v1';
const OFFLINE_PAGE = 'offline.html';
const ASSETS = ["/","/index.html","/css/style.css","/js/app.js"];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return cache.addAll(ASSETS.concat(OFFLINE_PAGE));
    })
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.filter(cache => cache !== CACHE_NAME).map(cache => caches.delete(cache))
      );
    })
  );
});


        self.addEventListener('fetch', event => {
          event.respondWith(
            caches.match(event.request).then(cachedResponse => {
              return cachedResponse || fetch(event.request).then(networkResponse => {
                return caches.open(CACHE_NAME).then(cache => {
                  cache.put(event.request, networkResponse.clone());
                  return networkResponse;
                });
              });
            }).catch(() => caches.match(OFFLINE_PAGE))
          );
        });
      
