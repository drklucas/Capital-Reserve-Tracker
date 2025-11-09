# Capital Reserve Tracker - Documentation

> **Note:** The app's display name is "MyGoals" (as shown in the UI), while "Capital Reserve Tracker" is the technical/project name.

Welcome to the Capital Reserve Tracker documentation! This guide will help you understand, set up, and contribute to the project.

## 📚 Documentation Index

### Getting Started
- **[Setup Guide](setup.md)** - Complete installation and configuration instructions
- **[Troubleshooting](troubleshooting.md)** - Common issues and solutions
- **[Security Guidelines](security.md)** - Security best practices and guidelines

### Architecture & Design
- **[Architecture Overview](architecture.md)** - Clean Architecture implementation details
- **[Firebase Rules](firebase-rules.md)** - Firestore security rules documentation
- **[Responsive Design](guides/responsive-design.md)** - Multi-platform responsive design guide

### Features
- **[Android Home Widgets](features/home-widgets.md)** - Native Android widget implementation
- **[Widget Troubleshooting](features/widget-troubleshooting.md)** - Widget debugging guide
- **[Goal Colors System](features/goal-colors.md)** - Customizable goal colors implementation
- **[Desktop Adaptation](web-desktop-adaptation/)** - Web/Desktop optimization documentation

### Development
- **[Migration Guides](guides/migration-guide.md)** - Version migration instructions
- **[Responsive Examples](guides/responsive-examples.md)** - Code examples for responsive layouts
- **[Multi-Platform Support](guides/multi-platform.md)** - iOS, Android, Web, Desktop configuration

### Implementation Summaries
- **[Refactoring Summaries](implementation/)** - Detailed refactoring documentation by screen
- **[Desktop Adaptation Progress](implementation/desktop-adaptation.md)** - Desktop implementation status

### Sprint Documentation
- **[Sprint 1](sprints/sprint-1.md)** - Initial setup, authentication, Clean Architecture
- **[Sprint 2](sprints/sprint-2.md)** - Core features, transactions, goals, widgets
- **[Sprint 3](sprints/sprint-3.md)** - Analytics, charts, advanced features (Planned)

## 🏗️ Project Structure

```
Capital-Reserve-Tracker/
├── app/                        # Flutter application
│   ├── lib/
│   │   ├── core/              # Core utilities and configuration
│   │   ├── data/              # Data layer (repositories, models)
│   │   ├── domain/            # Domain layer (entities, use cases)
│   │   └── presentation/      # UI layer (screens, widgets, providers)
│   └── test/                  # Test files
├── docs/                       # Documentation (you are here!)
│   ├── features/              # Feature-specific documentation
│   ├── guides/                # Development guides
│   ├── implementation/        # Implementation summaries
│   ├── sprints/               # Sprint documentation
│   └── web-desktop-adaptation/ # Desktop adaptation docs
├── README.md                  # Main project README
├── CHANGELOG.md               # Version history and changes
└── CLAUDE.md                  # AI assistant context
```

## 🚀 Quick Links

### For New Developers
1. Start with [Setup Guide](setup.md)
2. Read [Architecture Overview](architecture.md)
3. Check [Troubleshooting](troubleshooting.md) if you encounter issues

### For Contributors
1. Follow [Security Guidelines](security.md)
2. Review [Sprint Documentation](sprints/)
3. Check [Migration Guides](guides/migration-guide.md) for breaking changes

### For Feature Development
1. Review [Responsive Design Guide](guides/responsive-design.md)
2. Check [Implementation Summaries](implementation/) for patterns
3. Follow [Clean Architecture](architecture.md) principles

## 📖 Documentation Standards

### File Organization
- **features/** - Documentation specific to features (widgets, colors, etc.)
- **guides/** - How-to guides and best practices
- **implementation/** - Technical implementation details and summaries
- **sprints/** - Sprint planning and progress tracking
- **web-desktop-adaptation/** - Desktop/web optimization documentation

### Naming Conventions
- Use lowercase with hyphens: `responsive-design.md`
- Be descriptive: `goal-colors.md` instead of `colors.md`
- Group related docs in subdirectories

### Document Structure
Each documentation file should include:
1. **Title** - Clear, descriptive title
2. **Overview** - Brief description of the topic
3. **Content** - Organized sections with headers
4. **Code Examples** - When applicable
5. **References** - Links to related documentation

## 🔄 Keeping Documentation Updated

When making changes to the project:
1. Update relevant documentation files
2. Add entries to [CHANGELOG.md](../CHANGELOG.md)
3. Update implementation summaries if refactoring screens
4. Keep sprint documentation current

## 📝 Contributing to Documentation

Documentation improvements are always welcome! Please:
1. Follow the existing structure and style
2. Use clear, concise language
3. Include code examples where helpful
4. Update the index when adding new documents
5. Check for broken links before committing

## 🆘 Need Help?

- **Setup Issues**: Check [Troubleshooting](troubleshooting.md)
- **Widget Problems**: See [Widget Troubleshooting](features/widget-troubleshooting.md)
- **Security Questions**: Review [Security Guidelines](security.md)
- **Architecture Questions**: Read [Architecture Overview](architecture.md)

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Provider Documentation](https://pub.dev/packages/provider)

---

**Last Updated:** 2025-11-09
**Documentation Version:** 2.0
**Project Version:** Sprint 2 Complete
