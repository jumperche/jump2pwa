# jump2pwa


# PWA Utilities for R

This R package provides utilities to set up and manage Progressive Web Apps (PWAs). It includes functions to generate essential files like `manifest.json`, `service-worker.js`, and an offline fallback page (`offline.html`). These files enable your Shiny applications to function offline and be installable on devices.

---

## Features

- **Manifest Generation**: Automatically generate a `manifest.json` file for your PWA with customizable app metadata.
- **Service Worker**: Create a `service-worker.js` file with caching strategies to enable offline functionality.
- **Offline Page**: Generate a user-friendly `offline.html` page to inform users when the app is unavailable.
- **One-Step Setup**: Use the `setup_pwa()` function to generate all required files with a single call.

---

## Prerequisites

Before using this package, ensure you have the following:

- **R** (version ≥ 4.0)
- Required R packages:
  ```r
  install.packages("jsonlite")
  ```

- A directory named `www` in your Shiny project to store the generated files.

---

## Installation

Clone the repository and source the R script into your project:

```r
source("pwa_utilities.R")
```

---

## Getting Started

### Generate a `manifest.json` File

The `manifest.json` file defines metadata for your PWA, such as the app name, icons, start URL, and theme color.

```r
generate_manifest(
  paths = "www",
  name = "My PWA",
  short_name = "PWA",
  start_url = "/",
  display = "standalone",
  orientation = "portrait",
  background_color = "#ffffff",
  theme_color = "#000000",
  icons = list(
    list(src = "icons/icon-192x192.png", sizes = "192x192", type = "image/png"),
    list(src = "icons/icon-512x512.png", sizes = "512x512", type = "image/png")
  )
)
```

---

### Create an Offline Page

The offline page (`offline.html`) is displayed when the app is offline.

```r
create_offline_page(
  paths = "www",
  message = "You are currently offline. Please check your internet connection."
)
```

---

### Generate a Service Worker

The service worker (`service-worker.js`) handles caching and offline access.

```r
generate_service_worker(
  paths = "www",
  cache_name = "my-pwa-cache-v1",
  assets = c("/", "/index.html", "/css/style.css", "/js/app.js"),
  caching_strategy = "cache-first",
  offline_page = "offline.html"
)
```

---

### One-Step Setup

Use the `setup_pwa()` function to generate all required files:

```r
setup_pwa(
  pwa_name = "My PWA",
  short_name = "PWA",
  start_url = "/",
  display = "standalone",
  orientation = "portrait",
  background_color = "#ffffff",
  theme_color = "#000000",
  icons = list(
    list(src = "icons/icon-192x192.png", sizes = "192x192", type = "image/png"),
    list(src = "icons/icon-512x512.png", sizes = "512x512", type = "image/png")
  ),
  cache_name = "my-pwa-cache-v1",
  assets = c("/", "/index.html", "/css/style.css", "/js/app.js"),
  caching_strategy = "cache-first",
  offline_message = "You are currently offline."
)
```

---

## Folder Structure

```plaintext
.
├── pwa_utilities.R      # Main script file
└── www/                 # Directory for PWA files
    ├── manifest.json    # PWA manifest file
    ├── service-worker.js# Service worker script
    ├── offline.html     # Offline fallback page
    └── icons/           # Directory for app icons
```

---

## Customization

### Caching Strategies

- **Cache-First**: Serve cached content first, then update the cache in the background.
- **Network-First**: Always try to fetch content from the network first.
- **Stale-While-Revalidate**: Serve cached content while fetching the latest content in the background.

Specify the desired caching strategy in the `generate_service_worker()` function:

```r
caching_strategy = "cache-first"
```

---

## Future Enhancements

- **Push Notifications**: Support for notifications to users.
- **Background Sync**: Enable syncing data in the background when the app reconnects.
- **Custom Assets**: Automatically detect assets from the app structure.

---

## Contribution

Contributions are welcome! Please submit issues or pull requests with detailed descriptions and test cases.

---

## License

This project is licensed under the BSD 3-Clause License. See the `LICENSE` file for details.

---

Start creating installable and offline-ready PWAs with ease! 🚀
