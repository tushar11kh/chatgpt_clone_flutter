## screens

### spash_screen.dart

## Widgets & Functions Used

- **StatefulWidget (`SplashScreen`)**  
  Used because the splash screen needs animations and timed navigation, which require state management.

- **SingleTickerProviderStateMixin**  
  Provides a `vsync` for the `AnimationController`, ensuring efficient resource usage during animations.

- **AnimationController**  
  Controls the progress of animations (rotation, scaling). Here it runs for **720ms** and drives both animations.

- **Tween + CurvedAnimation**  
  - `_scaleAnimation`: Shrinks the logo from `1.1 → 0.12` with `Curves.easeInOut`.  
  - `_circleScaleAnimation`: Expands the circle slightly (`0.12 → 0.24`) using `Interval` for a delayed effect.

- **Timer**  
  Waits for **1 second** before navigating to `/home`. Used instead of waiting for full animation to finish.

- **Navigator.pushReplacementNamed**  
  Replaces the splash screen with the Home screen so the user can’t go back.

- **Theme.of(context).brightness**  
  Detects light/dark theme to switch between assets (`chatgpt_light.png` / `chatgpt_dark.png`) and background color.

- **Scaffold**  
  Provides the splash screen structure with a themed background.

- **AnimatedBuilder**  
  Rebuilds UI every frame as the `AnimationController` updates. Used here to apply scaling & rotation dynamically.

- **Transform.rotate**  
  Rotates the icon/circle continuously during animation.

- **ClipOval + Container**  
  Creates a circular shape. Acts as the base for the rotating logo or expanding circle effect.

- **Image.asset**  
  Displays the theme-specific splash logo inside the animated circle.

## Why This Approach?
- **StatefulWidget**: Needed for animations and navigation timing.  
- **Animations**: Provide a smooth scaling + rotation effect for a polished splash experience.  
- **Theme-aware assets**: Keeps UI consistent with dark/light mode.  
- **Navigator**: Ensures seamless transition to the main app without back navigation to splash.  
