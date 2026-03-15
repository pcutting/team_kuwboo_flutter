#!/bin/bash
set -e

FLUTTER_VERSION="3.41.4"
FLUTTER_DIR="$HOME/flutter"

# Download Flutter SDK if not cached
if [ ! -f "$FLUTTER_DIR/bin/flutter" ]; then
  echo "Installing Flutter $FLUTTER_VERSION..."
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter --version
flutter pub get
cd apps/web
flutter build web --release --no-tree-shake-icons
