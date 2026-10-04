#!/bin/zsh
# Builds the app and merges every localizable string the compiler found into the String
# Catalogs. Xcode does this on build in the IDE; command-line builds do not.
# Run from the repo root: Scripts/sync-strings.sh
set -euo pipefail

xcodegen generate --quiet
xcodebuild -project Kropic.xcodeproj -scheme Kropic -configuration Debug -derivedDataPath build build -quiet

intermediates=build/Build/Intermediates.noindex

sync() {
    local catalog=$1 target=$2
    # Debug-only preview views are not user facing.
    local files=(${(f)"$(find "$intermediates/$target.build" -name '*.stringsdata' \
        ! -name 'TokenSwatchView.stringsdata' ! -name 'PreviewRenderer.stringsdata' \
        ! -name '*Preview*.stringsdata')"})
    xcrun xcstringstool sync "$catalog" --stringsdata "${files[@]}"
    echo "$catalog: $(python3 -c "import json,sys; print(len(json.load(open(sys.argv[1]))['strings']))" "$catalog") strings"
}

sync App/Resources/Localizable.xcstrings Kropic
sync Packages/KropicCore/Sources/KropicCore/Resources/Localizable.xcstrings KropicCore
