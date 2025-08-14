#!/bin/bash
#trivy-k8s-scan

echo $imageName #getting Image name from env variable

docker run --rm -e SSL_CERT_DIR=/usr/local/share/ca-certificates \
      -v "$HOME/Zscaler-Root-CA.crt:/usr/local/share/ca-certificates/zscaler.crt:ro" \
      -v "trivy-cache-legacy:/root/.cache/" \
  aquasec/trivy:0.17.2 -q image \
  --exit-code 0 --severity LOW,MEDIUM,HIGH --light \
  $imageName


# Scan CRITICAL severity (fail on detection)
docker run --rm -e SSL_CERT_DIR=/usr/local/share/ca-certificates \
      -v "$HOME/Zscaler-Root-CA.crt:/usr/local/share/ca-certificates/zscaler.crt:ro" \
      -v "trivy-cache-legacy:/root/.cache/" \
  aquasec/trivy:0.17.2 -q image \
  --exit-code 1 --severity CRITICAL --light \
  $imageName
    # Trivy scan result processing
exit_code=$?
echo "Exit Code : $exit_code"

# Check scan results
if [[ ${exit_code} == 1 ]]; then
    echo "Image scanning failed. Vulnerabilities found"
    exit 1;
else
    echo "Image scanning passed. No vulnerabilities found"
fi;