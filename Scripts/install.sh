#!/bin/zsh
# Builds Kropic in Release and installs it into /Applications, replacing an older copy.
# Run from anywhere: Scripts/install.sh
# KROPIC_INSTALL_DIR overrides the destination; KROPIC_NO_LAUNCH=1 skips starting the app.
set -euo pipefail
cd "${0:A:h}/.."

destination=${KROPIC_INSTALL_DIR:-/Applications}
lsregister=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister

if ! command -v xcodegen >/dev/null; then
    echo "XcodeGen is missing. Install it with: brew install xcodegen" >&2
    exit 1
fi

echo "Building Kropic (Release)…"
xcodegen generate --quiet
xcodebuild -project Kropic.xcodeproj -scheme Kropic -configuration Release -derivedDataPath build/release build -quiet

echo "Installing into $destination…"
# A test install (KROPIC_NO_LAUNCH) leaves a running Kropic alone.
[[ -z "${KROPIC_NO_LAUNCH:-}" ]] && { pkill -x Kropic 2>/dev/null || true; }
rm -rf "$destination/Kropic.app"
cp -R build/release/Build/Products/Release/Kropic.app "$destination/"
"$lsregister" -f "$destination/Kropic.app"

if [[ -z "${KROPIC_NO_LAUNCH:-}" ]]; then
    open "$destination/Kropic.app"
fi
echo "Done. Kropic is in $destination and lives in your menu bar."
