# Feature Documentation

This directory contains documentation for specific features implemented in Capital Reserve Tracker.

## Available Feature Documentation

### Android Home Widgets
- **[Home Widgets](home-widgets.md)** - Complete guide to native Android widgets
- **[Widget Troubleshooting](widget-troubleshooting.md)** - Debug and troubleshooting guide

### UI Features
- **[Widgets Overview](widgets-overview.md)** - Custom widgets and components
- **[Goal Colors System](goal-colors.md)** - Customizable goal color palettes
- **[Goal Theming](goal-theming.md)** - Dynamic theming for goal screens

## Feature Overview

### 1. Android Home Widgets

Native Android widgets that display financial data on the home screen:
- **Income & Expenses Widget** (4x2) - Monthly comparison with bar chart
- **Reserve Evolution Widget** (4x3) - Reserve tracking with trend line

**Key Files:**
- Documentation: [home-widgets.md](home-widgets.md)
- Troubleshooting: [widget-troubleshooting.md](widget-troubleshooting.md)

### 2. Goal Colors System

10 predefined gradient color schemes for personalizing goals:
- Visual color picker UI
- Dynamic theming system
- Progress bars and stats themed to goal colors
- Backward compatible with existing goals

**Key Files:**
- Implementation: [goal-colors.md](goal-colors.md)
- Theming: [goal-theming.md](goal-theming.md)

### 3. Custom Widgets

Reusable UI components following Clean Architecture:
- Responsive widgets for multi-platform support
- Glass-morphism effects
- Animated components
- Adaptive navigation

**Key Files:**
- Overview: [widgets-overview.md](widgets-overview.md)

## Adding New Feature Documentation

When documenting a new feature:

1. Create a new markdown file in this directory
2. Follow this structure:
   - Overview
   - Implementation details
   - Usage examples
   - Configuration
   - Troubleshooting
3. Add a link in this README
4. Update the main [docs/README.md](../README.md)

## Related Documentation

- [Architecture Overview](../architecture.md)
- [Implementation Summaries](../implementation/)
- [Development Guides](../guides/)

---

**Last Updated:** 2025-11-09
