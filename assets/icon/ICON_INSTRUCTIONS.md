# Icon Creation Instructions

The Weather Buddy app needs two icon files in this directory:

1. `icon.png` (1024x1024 pixels)
   - Main app icon
   - Should feature a weather-related symbol (e.g., sun with clouds)
   - Use a sky blue background (#42A5F5)
   - Keep the design simple and recognizable at small sizes

2. `icon_foreground.png` (1024x1024 pixels)
   - Android adaptive icon foreground
   - Should be the same weather symbol but without the background
   - Should have transparent background
   - Center the design with adequate padding (at least 100px on all sides)

Design Guidelines:
- Use Material Design style
- Keep the design simple and clean
- Ensure good visibility at small sizes
- Use weather-related imagery (sun, cloud, etc.)
- Main colors: Sky Blue (#42A5F5) for background

After creating these icons, run:
```
flutter pub get
flutter pub run flutter_launcher_icons
```
