#!/bin/bash
set -x

for chart in ./*; do
    if [ -f "$chart/Chart.yaml" ]; then
        helm package $chart
    fi
done

helm repo index --url https://nhatminhk63j.github.io/charts .