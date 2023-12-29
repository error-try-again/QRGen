#!/usr/bin/env bash

set -euo pipefail

#######################################
# Configure the sitemap.xml file
# Globals:
#   ORIGIN_URL
#   SITEMAP_XML
# Arguments:
#  None
#######################################
function configure_frontend_sitemap() {
  local date
  local regularity
  local priority

  date=$(date +%Y-%m-%d)
  regularity="weekly"
  priority="0.8"

  cat <<EOF >"${SITEMAP_XML}"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="https://www.sitemaps.org/schemas/sitemap/0.9">
   <url>
      <loc>${ORIGIN_URL}</loc>
      <lastmod>${date}</lastmod>
      <changefreq>${regularity}</changefreq>
      <priority>${priority}</priority>
   </url>
</urlset>
EOF
}
