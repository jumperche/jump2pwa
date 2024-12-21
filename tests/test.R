library(testthat)
library(jump2pwa)

test_check("jump2pwa")
unlink(c("manifest.json", "offline.html", "service-worker.js"), recursive = TRUE)
