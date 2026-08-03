#!/bin/bash

# ==========================================
# Functions
# ==========================================

run_build_runner() {
    echo ""
    echo "🔧 Running Build Runner..."
    flutter pub run build_runner build --delete-conflicting-outputs
    echo "✅ Build Runner completed!"
}

run_translations() {
    echo ""
    echo "🌍 Generating Translations..."
    flutter pub run easy_localization:generate -S assets/translation -O lib/app/localization -f keys -o locale_keys.g.dart
    echo "✅ Translations generated!"
}

# ==========================================
# Main Menu
# ==========================================

echo "🚀 Generator Script"
echo "=========================="
echo ""
echo "Please select what you want to run:"
echo "1) Build Runner only"
echo "2) Translations only"
echo "3) All commands"
echo "4) Exit"
echo ""
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        run_build_runner
        ;;
    2)
        run_translations
        ;;
    3)
        run_build_runner
        run_translations
        echo ""
        echo "🎉 All commands completed!"
        ;;
    4)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid choice. Please run the script again and select 1-4."
        exit 1
        ;;
esac

echo ""
echo "🎉 Done!"