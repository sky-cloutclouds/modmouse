# ModMouse Development Roadmap

This roadmap outlines the planned development of ModMouse from its initial architecture through future feature releases.

> **Status Legend**
>
> - ⬜ Planned
> - 🟨 In Progress
> - ✅ Complete

---

# Phase 1 — Project Foundation

Status: ✅ Complete

## Repository

- ✅ Create GitHub repository
- ✅ Choose project license (MIT)
- ✅ Create README
- ✅ Create Design Specification
- ✅ Create Roadmap
- ✅ Create Installation Guide
- ✅ Create Changelog

## Architecture

- ✅ Establish project structure
- ✅ Define configuration API
- ✅ Define coding conventions
- ✅ Implement startup pipeline
- ✅ Implement project skeleton

---

# Phase 2 — Core Engine

Status: ⬜ Planned

## Milestone 2.1 — Configuration Validation

- ⬜ Validate configuration values
- ⬜ Validate timing parameters
- ⬜ Validate modifier keys
- ⬜ Validate mouse buttons
- ⬜ Display descriptive configuration errors

---

## Milestone 2.2 — Input Manager

- ⬜ Detect modifier state
- ⬜ Detect mouse button state
- ⬜ Normalize input events
- ⬜ Centralize hardware input

---

## Milestone 2.3 — State Machine

- ⬜ Implement Idle state
- ⬜ Implement Scroll Up state
- ⬜ Implement Scroll Down state
- ⬜ Implement Chording state
- ⬜ State transition validation

---

## Milestone 2.4 — Event Dispatcher

- ⬜ Route normalized events
- ⬜ Notify engine modules
- ⬜ Decouple input from features

---

## Milestone 2.5 — Debug System

- ⬜ Optional debug logging
- ⬜ State transition logging
- ⬜ Input event logging

---

## Milestone 2.6 — Reliability

- ⬜ Automatic recovery
- ⬜ Emergency state reset
- ⬜ Invalid state detection
- ⬜ Runtime safeguards

---

# Phase 3 — Core Features

Status: ⬜ Planned

## Accelerated Scrolling

- ⬜ Scroll acceleration
- ⬜ Adjustable timing
- ⬜ Smooth acceleration

---

## Mouse Chording

- ⬜ Middle-click emulation
- ⬜ Configurable output
- ⬜ Configurable timing

---

## Compatibility Layer

- ⬜ Browser compatibility
- ⬜ Windows compatibility
- ⬜ Application compatibility

---

# Phase 4 — Customization

Status: ⬜ Planned

## Profiles

- ⬜ Multiple profiles
- ⬜ Profile switching
- ⬜ Profile import/export

---

## Configuration

- ⬜ Expanded configuration
- ⬜ Additional modifier keys
- ⬜ Additional mouse actions

---

# Phase 5 — Future Expansion

Status: ⬜ Planned

Potential future additions.

- ⬜ Horizontal scrolling
- ⬜ Media controls
- ⬜ Window management
- ⬜ Productivity shortcuts
- ⬜ CAD workflows
- ⬜ Creative application workflows
- ⬜ Plugin architecture (if justified)

---

# Ongoing Goals

These goals apply to every phase of development.

- Maintain predictable behaviour.
- Prioritize reliability over feature count.
- Minimize CPU usage.
- Keep the codebase modular.
- Avoid unnecessary complexity.
- Preserve backwards compatibility where practical.
