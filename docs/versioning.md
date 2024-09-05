---
title: "Versioning Guide for TextDAO"
version: 0.1.0
lastUpdated: 2024-09-04
author: TextDAO Development Team
scope: project
type: guide
tags: [versioning, semantic-versioning, release-process]
relatedDocs: [../CONTRIBUTING.md]
changeLog:
  - version: 0.1.0
    date: 2024-09-04
    description: Initial version of the versioning guide
---

# Versioning Guide for TextDAO

This document outlines the versioning strategy for the TextDAO project.

## Semantic Versioning

TextDAO follows [Semantic Versioning 2.0.0](https://semver.org/). The version number is structured as MAJOR.MINOR.PATCH.

- MAJOR version increments for incompatible changes
- MINOR version increments for backwards-compatible functionality additions
- PATCH version increments for backwards-compatible bug fixes

## Version Control

- Each package in the monorepo maintains its own version.
- The monorepo itself has an overall version that increments with significant project-wide changes.

## Release Process

1. Determine the new version number based on the changes since the last release.
2. Update the version number in the package.json file.
3. Update the CHANGELOG.md file with the changes for the new version.
4. Create a git tag for the new version.
5. Push the changes and the new tag to the repository.
6. Create a GitHub release using the new tag.

## Changelogs

Each package maintains its own CHANGELOG.md file. The changelog should include:

- The version number and release date
- A list of new features
- A list of bug fixes
- Any breaking changes

## Pre-release Versions

For pre-release versions, use the following format:

- Alpha: 1.0.0-alpha.1
- Beta: 1.0.0-beta.1
- Release Candidate: 1.0.0-rc.1

## Documentation Versioning

- The documentation site maintains versions that correspond to major releases of the project.
- Each documentation page includes the version number it applies to.

By following these guidelines, we ensure consistent and understandable versioning across the TextDAO project.
