#!/usr/bin/env bash
# 使い方: materials/incoming/ に素材を置いて実行 → v2/media/ に軽量版を出力
# 画像: 長辺1600px・JPEG(HEICも可) / 動画: 縦横720p以内・音声なし・最大20秒・H.264(mp4)+poster
set -euo pipefail
IN="${1:-materials/incoming}"; OUT="${2:-v2/media}"; mkdir -p "$OUT"
shopt -s nullglob nocaseglob
for f in "$IN"/*.{jpg,jpeg,png,heic}; do
  b=$(basename "${f%.*}"); convert "$f" -auto-orient -resize '1600x1600>' -quality 80 "$OUT/$b.jpg" && echo "img $b"
done
for f in "$IN"/*.{mov,mp4}; do
  b=$(basename "${f%.*}")
  ffmpeg -y -loglevel error -i "$f" -t 20 -an -vf "scale='min(720,iw)':-2" -c:v libx264 -crf 29 -preset slow -movflags +faststart "$OUT/$b.mp4"
  ffmpeg -y -loglevel error -i "$OUT/$b.mp4" -frames:v 1 -q:v 4 "$OUT/$b.poster.jpg"
  echo "vid $b $(du -h "$OUT/$b.mp4" | cut -f1)"
done
