# Development Guides

This directory contains guides for developing and maintaining Capital Reserve Tracker.

## Available Guides

### Setup & Configuration
- **[Main Setup Guide](main-setup.md)** - Dependency injection and main.dart configuration
- **[Multi-Platform Support](multi-platform.md)** - iOS, Android, Web, Desktop setup
- **[Migration Guide](migration-guide.md)** - Version migration instructions

### UI/UX Development
- **[Responsive Design](responsive-design.md)** - Multi-platform responsive design guide
- **[Responsive Examples](responsive-examples.md)** - Code examples for responsive layouts

### Features
- **[AI Assistant Setup](ai-assistant-setup.md)** - Complete AI integration guide

## Guide Categories

### 1. Setup & Configuration

#### Main Setup
Configuration of the application's dependency injection and initialization.

**Topics Covered:**
- Dependency injection setup
- Provider configuration
- Firebase initialization
- Service initialization

**File:** [main-setup.md](main-setup.md)

#### Multi-Platform Support
Guide for configuring and building for different platforms.

**Topics Covered:**
- Android configuration
- iOS configuration
- Web deployment
- Desktop builds (Windows, Linux, macOS)

**File:** [multi-platform.md](multi-platform.md)

#### Migration Guide
Instructions for migrating between versions.

**Topics Covered:**
- Breaking changes
- Data migration
- Dependency updates
- Code refactoring steps

**File:** [migration-guide.md](migration-guide.md)

### 2. UI/UX Development

#### Responsive Design
Complete guide for implementing responsive layouts.

**Topics Covered:**
- Breakpoint system
- ResponsiveUtils usage
- Adaptive widgets
- Platform-specific layouts

**File:** [responsive-design.md](responsive-design.md)

#### Responsive Examples
Practical code examples for responsive design patterns.

**Topics Covered:**
- Layout examples
- Grid systems
- Adaptive navigation
- Screen size handling

**File:** [responsive-examples.md](responsive-examples.md)

### 3. Feature Integration

#### AI Assistant
Complete setup guide for AI-powered financial insights.

**Topics Covered:**
- API configuration (Gemini/Claude)
- Security setup
- Integration steps
- Usage examples

**File:** [ai-assistant-setup.md](ai-assistant-setup.md)

## Best Practices

### Code Organization
- Follow Clean Architecture principles
- Separate concerns by layer
- Use dependency injection
- Implement repository pattern

### UI Development
- Mobile-first approach
- Use ResponsiveUtils for breakpoints
- Test on multiple screen sizes
- Consider platform conventions

### State Management
- Use Provider pattern
- Keep state localized when possible
- Implement proper error handling
- Use Either pattern for operations

### Testing
- Write unit tests for business logic
- Create widget tests for UI
- Implement integration tests
- Test on multiple platforms

## Development Workflow

1. **Setup**: Follow [Main Setup Guide](main-setup.md)
2. **Architecture**: Review [Architecture Docs](../architecture.md)
3. **Features**: Check [Feature Documentation](../features/)
4. **Implementation**: See [Implementation Summaries](../implementation/)
5. **Testing**: Follow testing best practices

## Code Style Guidelines

### Dart/Flutter
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter format` before committing
- Run `flutter analyze` regularly
- Follow project linting rules

### Documentation
- Document complex logic
- Add dartdoc comments for public APIs
- Keep comments up to date
- Use meaningful variable names

### Git Commits
- Use conventional commits format
- Write descriptive commit messages
- Reference issues when applicable
- Keep commits focused

## Related Documentation

- [Architecture Overview](../architecture.md)
- [Security Guidelines](../security.md)
- [Feature Documentation](../features/)
- [Implementation Summaries](../implementation/)

## Contributing to Guides

When adding a new guide:

1. Create markdown file in this directory
2. Follow existing guide structure:
   - Clear title and overview
   - Table of contents for long guides
   - Step-by-step instructions
   - Code examples
   - Troubleshooting section
3. Add entry in this README
4. Update main [docs/README.md](../README.md)

## Need Help?

- **Setup Issues**: Check [Troubleshooting](../troubleshooting.md)
- **Architecture Questions**: See [Architecture Docs](../architecture.md)
- **Security**: Review [Security Guidelines](../security.md)

---

**Last Updated:** 2025-11-09
