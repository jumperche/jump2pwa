#' Generate a manifest.json file for a PWA
#'
#' This function generates a manifest.json file for a Progressive Web App (PWA).
#' It includes metadata such as the app's name, icons, start URL, and display options.
#'
#' @param paths The directory where the manifest.json file will be saved (default: "www").
#' @param name The name of the PWA.
#' @param short_name A shorter name for the PWA (for homescreen).
#' @param start_url The start URL of the PWA (usually the root "/").
#' @param display The display mode of the app (e.g., "standalone", "fullscreen", etc.).
#' @param orientation The screen orientation of the app (e.g., "any", "portrait", "landscape").
#' @param background_color The background color of the splash screen (default: "#ffffff").
#' @param theme_color The theme color of the app (default: "#ffffff").
#' @param icons A list of icons with their pathss and sizes, used in the manifest file.
#'
#' @return Generates a manifest.json file at the specified paths.
#' @export
generate_manifest <- function(paths = "www",
                              name = "My PWA",
                              short_name = "PWA",
                              start_url = "/",
                              display = "standalone",
                              orientation = "any",
                              background_color = "#ffffff",
                              theme_color = "#ffffff",
                              icons = list(
                                list(src = "icons/icon-192x192.png", sizes = "192x192", type = "image/png"),
                                list(src = "icons/icon-512x512.png", sizes = "512x512", type = "image/png")
                              )) {
  # Create the directory if it doesn't exist
  if (!dir.exists(paths)) dir.create(paths, recursive = TRUE)

  manifest <- list(
    name = name,
    short_name = short_name,
    start_url = start_url,
    display = display,
    orientation = orientation,
    background_color = background_color,
    theme_color = theme_color,
    icons = icons
  )

  # Convert the manifest list to JSON
  json_manifest <- jsonlite::toJSON(manifest, auto_unbox = TRUE, pretty = TRUE)

  # Write the JSON to the specified file
  write(json_manifest, file = file.path(paths, "manifest.json"))
  message("manifest.json has been generated at: ", file.path(paths, "manifest.json"))
}

#' Create an offline page for PWA
#'
#' This function creates an HTML offline page that will be displayed when the PWA is offline.
#'
#' @param paths The directory where the offline page will be saved (default: "www").
#' @param message The message to display on the offline page.
#' @return The offline page file is generated at the specified paths.
#' @export
create_offline_page <- function(paths = "www", message = "You are currently offline.") {
  # Create the directory if it doesn't exist
  if (!dir.exists(paths)) dir.create(paths, recursive = TRUE)

  # HTML content for the offline page
  offline_page_content <- paste0(
    "<!DOCTYPE html>\n",
    "<html lang='en'>\n",
    "<head>\n",
    "  <meta charset='UTF-8'>\n",
    "  <meta name='viewport' content='width=device-width, initial-scale=1.0'>\n",
    "  <title>Offline</title>\n",
    "  <style>\n",
    "    body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }\n",
    "    h1 { color: #FF0000; }\n",
    "  </style>\n",
    "</head>\n",
    "<body>\n",
    "  <h1>Offline</h1>\n",
    "  <p>", message, "</p>\n",
    "</body>\n",
    "</html>"
  )

  # Write the offline page to the specified paths
  write(offline_page_content, file = file.path(paths, "offline.html"))
  message("Offline page has been generated at: ", file.path(paths, "offline.html"))
}

#' Generate a service-worker.js file for a PWA
#'
#' This function generates a service-worker.js file, which defines the caching strategy for offline use
#' and allows the PWA to serve cached content when the network is unavailable.
#'
#' @param paths The directory where the service-worker.js file will be saved (default: "www").
#' @param cache_name The name of the cache where assets will be stored.
#' @param assets A list of assets to cache.
#' @param caching_strategy The caching strategy to use ("cache-first", "network-first", or "stale-while-revalidate").
#' @param offline_page The paths to the offline page that will be served when the app is offline.
#'
#' @return Generates a service-worker.js file at the specified paths.
#' @export
generate_service_worker <- function(paths = "www",
                                    cache_name = "my-pwa-cache-v1",
                                    assets = c("/", "/index.html", "/css/style.css", "/js/app.js"),
                                    caching_strategy = "cache-first",
                                    offline_page = "offline.html") {
  # Create the directory if it doesn't exist
  if (!dir.exists(paths)) dir.create(paths, recursive = TRUE)

  caching_code <- switch(caching_strategy,
                         "cache-first" = "
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
          ",
                         "network-first" = "
            self.addEventListener('fetch', event => {
              event.respondWith(
                fetch(event.request).then(networkResponse => {
                  return caches.open(CACHE_NAME).then(cache => {
                    cache.put(event.request, networkResponse.clone());
                    return networkResponse;
                  });
                }).catch(() => caches.match(OFFLINE_PAGE))
              );
            });
          ",
                         "stale-while-revalidate" = "
            self.addEventListener('fetch', event => {
              event.respondWith(
                caches.open(CACHE_NAME).then(cache => {
                  return cache.match(event.request).then(cachedResponse => {
                    const fetchPromise = fetch(event.request).then(networkResponse => {
                      cache.put(event.request, networkResponse.clone());
                      return networkResponse;
                    });
                    return cachedResponse || fetchPromise;
                  });
                }).catch(() => caches.match(OFFLINE_PAGE))
              );
            });
          ",
                         stop("Invalid caching strategy specified")
  )

  # Create the service worker script
  service_worker_js <- paste0(
    "const CACHE_NAME = '", cache_name, "';\n",
    "const OFFLINE_PAGE = '", offline_page, "';\n",
    "const ASSETS = ", jsonlite::toJSON(assets, auto_unbox = TRUE), ";\n\n",
    "self.addEventListener('install', event => {\n",
    "  event.waitUntil(\n",
    "    caches.open(CACHE_NAME).then(cache => {\n",
    "      return cache.addAll(ASSETS.concat(OFFLINE_PAGE));\n",
    "    })\n",
    "  );\n",
    "});\n\n",
    "self.addEventListener('activate', event => {\n",
    "  event.waitUntil(\n",
    "    caches.keys().then(cacheNames => {\n",
    "      return Promise.all(\n",
    "        cacheNames.filter(cache => cache !== CACHE_NAME).map(cache => caches.delete(cache))\n",
    "      );\n",
    "    })\n",
    "  );\n",
    "});\n\n",
    caching_code
  )

  # Write the service worker script to the specified file
  write(service_worker_js, file = file.path(paths, "service-worker.js"))
  message("service-worker.js with caching strategy '", caching_strategy, "' has been generated at: ", file.path(paths, "service-worker.js"))
}

#' Set up a PWA by generating manifest.json, service-worker.js, and an offline page
#'
#' This function sets up a Progressive Web App (PWA) by generating the necessary manifest.json file,
#' service-worker.js file, and an offline page.
#'
#' @param pwa_name The name of your PWA.
#' @param short_name A short name for your PWA.
#' @param start_url The start URL of the PWA.
#' @param display The display mode of the app (default: "standalone").
#' @param orientation The screen orientation of the app (default: "any").
#' @param background_color The background color of the splash screen (default: "#ffffff").
#' @param theme_color The theme color of the app (default: "#ffffff").
#' @param icons A list of icons for the manifest.json.
#' @param cache_name The name of the cache in the service worker.
#' @param assets A list of assets to cache in the service worker.
#' @param caching_strategy The caching strategy to use ("cache-first", "network-first", etc.).
#' @param offline_message The message to display on the offline page.
#' @param paths The directory where the files will be saved (default: "www").
#'
#' @return Generates all the required files for the PWA.
#' @export
setup_pwa <- function(pwa_name = "My PWA",
                      short_name = "PWA",
                      start_url = "/",
                      display = "standalone",
                      orientation = "any",
                      background_color = "#ffffff",
                      theme_color = "#ffffff",
                      icons = list(
                        list(src = "icons/icon-192x192.png", sizes = "192x192", type = "image/png"),
                        list(src = "icons/icon-512x512.png", sizes = "512x512", type = "image/png")
                      ),
                      cache_name = "my-pwa-cache-v1",
                      assets = c("/", "/index.html", "/css/style.css"),
                      caching_strategy = "cache-first",
                      offline_message = "You are currently offline.",
                      paths = "www") {

  # Generate manifest.json
  generate_manifest(paths = paths,
                    name = pwa_name,
                    short_name = short_name,
                    start_url = start_url,
                    display = display,
                    orientation = orientation,
                    background_color = background_color,
                    theme_color = theme_color,
                    icons = icons)

  # Generate offline page
  create_offline_page(paths = paths, message = offline_message)

  # Generate service-worker.js
  generate_service_worker(paths = paths,
                          cache_name = cache_name,
                          assets = assets,
                          caching_strategy = caching_strategy,
                          offline_page = "offline.html")
}
