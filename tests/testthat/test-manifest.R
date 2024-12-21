library(testthat)
library(withr)

test_that("create_offline_page creates a valid offline HTML page", {
  local_dir <- withr::local_tempdir()
  temp_file <- file.path(local_dir, "offline.html")

  create_offline_page(path = temp_file, message = "You are currently offline.")

  expect_true(file.exists(temp_file))

  content <- paste(readLines(temp_file), collapse = " ")
  expect_true(grepl("You are currently offline.", content))
})

test_that("generate_service_worker creates a valid service worker file", {
  local_dir <- withr::local_tempdir()
  temp_file <- file.path(local_dir, "service-worker.js")

  generate_service_worker(path = temp_file,
                          cache_name = "my-pwa-cache-v1",
                          assets = c("/", "/index.html", "/css/style.css"),
                          caching_strategy = "cache-first",
                          offline_page = "offline.html")

  expect_true(file.exists(temp_file))

  content <- paste(readLines(temp_file), collapse = " ")
  expect_true(grepl("my-pwa-cache-v1", content))
  expect_true(grepl("offline.html", content))
})

test_that("generate_manifest creates a valid JSON file", {
  local_dir <- withr::local_tempdir()
  temp_file <- file.path(local_dir, "manifest.json")

  generate_manifest(path = temp_file, name = "Test PWA", short_name = "TestPWA")

  expect_true(file.exists(temp_file))

  json_content <- jsonlite::fromJSON(temp_file)

  expect_equal(json_content$name, "Test PWA")
})
setup_pwa(
  # Directory where manifest.json and service-worker.js will be saved
  pwa_name = "My Shiny PWA",        # The name of the PWA
  short_name = "ShinyPWA",          # Shorter name for the PWA (for home screen)
  start_url = "/",                  # The start URL of the PWA (usually "/")
  display = "standalone",           # Display mode: standalone, fullscreen, minimal-ui, browser
  orientation = "portrait",         # Lock the app in portrait mode
  background_color = "#ffffff",     # Splash screen background color
  theme_color = "#000000",          # Theme color for the app's UI
  icons = list(                     # Icons to include in the manifest
    list(src = "www/icon.png", sizes = "192x192", type = "image/png"),
    list(src = "www/icon_maskable.png", sizes = "512x512", type = "image/png")
  ),
  cache_name = "shiny-pwa-cache-v1",  # Name of the cache
  assets = c("/", "/index.html", "/css/style.css", "/js/app.js"),  # Assets to cache
  caching_strategy = "cache-first",   # Caching strategy (cache-first, network-first, etc.)
  #enable_background_sync = TRUE,      # Enable background sync
  #enable_push_notifications = TRUE    # Enable push notifications
  path = "www"
)
generate_manifest(path = temp_file, name = "Test PWA", short_name = "TestPWA")
