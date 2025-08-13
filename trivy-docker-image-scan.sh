#!/bin/bash


# Extract base image from the first line of Dockerfile
dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo "Scanning image: $dockerImageName"


# Scan HIGH severity (no failure)
docker run --rm -e SSL_CERT_DIR=/usr/local/share/ca-certificates \
      -v "$HOME/Zscaler-Root-CA.crt:/usr/local/share/ca-certificates/zscaler.crt:ro" \
      -v "trivy-cache-legacy:/root/.cache/" \
  aquasec/trivy:0.17.2 -q image \
  --exit-code 0 --severity HIGH --light \
  $dockerImageName


# Scan CRITICAL severity (fail on detection)
docker run --rm -e SSL_CERT_DIR=/usr/local/share/ca-certificates \
      -v "$HOME/Zscaler-Root-CA.crt:/usr/local/share/ca-certificates/zscaler.crt:ro" \
      -v "trivy-cache-legacy:/root/.cache/" \
  aquasec/trivy:0.17.2 -q image \
  --exit-code 1 --severity CRITICAL --light \
  $dockerImageName


exit_code=$?
echo "Exit code: $exit_code"


if [ $exit_code -eq 1 ]; then
  echo "Image scanning failed. CRITICAL vulnerabilities found."
  exit 1
else
  echo "Image scanning passed. No CRITICAL vulnerabilities found."
  exit 0
fi
