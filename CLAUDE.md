# Claude Code Rules for Houzou Medical Ecommerce App

## Project Overview
This is a Flutter ecommerce application for medical supplies using Riverpod for state management.

## Key Commands
- **Build**: `flutter build apk` or `flutter build ios`
- **Run**: `flutter run`
- **Test**: `flutter test`
- **Lint**: `flutter analyze`
- **Format**: `dart format .`

## Architecture & Patterns
- **State Management**: Flutter Riverpod (StateNotifier pattern)
- **Navigation**: Material PageRoute with AppWrapper for auth routing
- **Authentication**: Centralized in AppWrapper - never manually navigate on auth success
- **Memory Management**: Always check `mounted` before `setState()` in async functions

## Code Standards
- Use `ConsumerWidget` for widgets that read providers
- Use `ConsumerStatefulWidget` for stateful widgets with providers
- Always dispose controllers in `dispose()`
- Prefix private methods/variables with underscore
- Use `const` constructors where possible

## Authentication Flow
- **AppWrapper** handles all auth routing - never manually navigate after login/register
- Check `mounted` before all `setState()` calls in async auth functions
- Use consistent error handling with SnackBar notifications

## UI/UX Guidelines
- Primary color: `kPrimaryColor` (green medical theme)
- Always use `kBackgroundColor` for screen backgrounds
- Card elevations: 8 for main cards, 10 for overlays
- Border radius: 15px for cards, 25px for buttons, 12px for inputs
- Use `AnimatedCrossFade` for expand/collapse with 300ms duration

## File Structure
- `lib/screens/`: Screen widgets organized by feature
- `lib/providers/`: Riverpod state management
- `lib/models/`: Data models
- `lib/constants.dart`: App-wide constants and colors
- `lib/app_wrapper.dart`: Root authentication router

## Testing Notes
- Test authentication flows thoroughly
- Verify memory leak fixes with mounted checks
- Test expand/collapse animations in order history

## Common Issues to Avoid
- Never call `setState()` after `dispose()` - always check `mounted`
- Don't manually navigate after auth success - let AppWrapper handle it
- Remove unused imports to avoid linting warnings
- Use proper Hero tag prefixes to avoid conflicts between screens