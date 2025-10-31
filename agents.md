# Agent Instructions

All AI agents working on this project MUST read and follow the steering documentation in the `ai/` directory.

## Required Reading

Before making any changes to this project, agents must review:

1. **[Project Overview](ai/project-overview.md)** - Understanding the LunarOS project structure and conventions
2. **[Build System](ai/build-system.md)** - How to add software via build scripts
3. **[Homebrew Integration](ai/homebrew-integration.md)** - Adding runtime packages via Brewfiles
4. **[Flatpak Integration](ai/flatpak-integration.md)** - Adding GUI applications via Flatpak preinstall
5. **[ujust Commands](ai/ujust-commands.md)** - Creating user-facing convenience commands
6. **[File Naming Conventions](ai/file-naming-conventions.md)** - Proper naming patterns for all files
7. **[Security Guidelines](ai/security-guidelines.md)** - Security best practices and requirements
8. **[Testing Procedures](ai/testing-procedures.md)** - How to test changes before deployment

## Core Principles

- **Follow Universal Blue conventions** - This project extends @ublue-os/bluefin patterns
- **Immutable base system** - Package installation happens at build time, not runtime
- **Declarative configuration** - Use Brewfiles, preinstall files, and ujust commands
- **Security first** - Always follow security guidelines and validate inputs
- **Test everything** - Never commit untested changes

## Making Changes

1. Read the relevant steering documentation first
2. Follow the established patterns and conventions
3. Test changes locally before committing
4. Update documentation when adding new features
5. Follow the security guidelines for all modifications

## Questions?

If you're unsure about any aspect of the project, refer to the specific steering documents in the `ai/` directory. Each document provides detailed guidance for its respective area.
