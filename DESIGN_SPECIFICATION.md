# ModMouse Design Specification

Version: 1.0

---

# Purpose

ModMouse exists to enhance mouse interaction while remaining lightweight, deterministic, and highly configurable.

The project aims to provide advanced mouse functionality without replacing or interfering with the operating system's existing input model.

---

# Design Goals

The following goals take priority over all feature requests.

## 1. Performance

Input latency must remain imperceptible.

CPU usage should remain negligible while idle.

Memory footprint should remain minimal.

---

## 2. Predictability

ModMouse should behave consistently.

Every input should produce exactly one expected output.

No hidden state should surprise the user.

---

## 3. Configurability

All user-customisable behaviour must be located in a dedicated configuration section.

Users should never need to modify engine logic.

---

## 4. Single-File Architecture

The core application shall remain contained within a single AutoHotkey script.

Advantages include:

- easier distribution
- simpler maintenance
- easier auditing
- lower complexity

---

## 5. Native Feel

ModMouse should feel like an extension of Windows rather than a macro utility.

Animations, delays, acceleration, and interactions should appear natural.

---

# Project Architecture

The script is organised into logical sections.

Configuration

↓

Initialization

↓

Hotkeys

↓

Input Engine

↓

Timing Engine

↓

Helper Functions

↓

Cleanup

---

# Configuration Philosophy

Every configurable option should exist at the beginning of the script.

Examples include:

- Mouse buttons
- Modifier keys
- Scroll timing
- Feature toggles
- Acceleration behaviour

No engine code should require editing for normal customisation.

---

# Performance Principles

The following principles guide optimisation.

- Optimise latency before throughput.
- Prefer simplicity over micro-optimisations.
- Minimise allocations.
- Avoid unnecessary polling.
- Keep idle CPU usage effectively zero.

---

# Coding Standards

The project follows several internal conventions.

- Clear function names.
- Minimal global state.
- Document intent instead of implementation.
- Avoid duplicated logic.
- Prefer reusable functions.

---

# Compatibility

Primary Target

Windows 10

Windows 11

AutoHotkey v1.1

---

# Non-Goals

ModMouse is not intended to become:

- a macro recorder
- an automation suite
- a scripting framework
- a gaming cheat

Its purpose is input enhancement.

---

# Future Expansion

Future features should preserve the project's core philosophy.

Complexity should only be introduced when justified by measurable benefit.


### Reliability

• ModMouse is state-driven.

• ModMouse never silently changes user input.

• Every state has an explicit exit path.

• Recovery is automatic whenever possible.

• Unexpected input sequences return ModMouse to Idle.

• Reliability is prioritized over feature count.


### Engineering Philosophy

- One responsibility per module.

- One responsibility per function.

- No silent failures.

- No hidden state.

- No magic numbers.

- Configuration is validated before execution.

- Engine modules communicate through events rather than directly accessing hardware state.


# Architecture

## High-Level Architecture

ModMouse is organized into independent modules. Each module has a single responsibility and communicates through well-defined interfaces.

```
                  +------------------+
                  |  Configuration   |
                  +--------+---------+
                           |
                           v
                  +------------------+
                  |   Input Engine   |
                  +--------+---------+
                           |
          +----------------+----------------+
          |                                 |
          v                                 v
+--------------------+           +--------------------+
|   State Machine    |---------->| Event Dispatcher   |
+---------+----------+           +---------+----------+
          |                                  |
          |                                  |
          v                                  v
+--------------------+           +--------------------+
|  Scroll Engine     |           |  Chord Engine      |
+--------------------+           +--------------------+
          |
          v
+--------------------+
| Output Layer       |
+--------------------+
```

The Input Engine is the only subsystem permitted to communicate directly with keyboard and mouse hardware.

All other modules operate exclusively on normalized events.

---

# Core Modules

## Configuration

Responsible for storing user-configurable settings.

Responsibilities:

- Store configuration values.
- Provide configuration to the engine.
- Remain independent from runtime state.

---

## Input Engine

Responsible for translating raw hardware input into normalized events.

Responsibilities:

- Detect modifier state.
- Detect mouse button state.
- Normalize hardware input.
- Notify the Event Dispatcher.

The Input Engine does **not** implement scrolling or chording.

---

## State Machine

Responsible for controlling ModMouse's current operating state.

Only one state may be active at any given time.

Planned states include:

- Idle
- ScrollingUp
- ScrollingDown
- Chording

---

## Event Dispatcher

Routes normalized events to the appropriate subsystem.

This allows engine modules to remain independent.

---

## Scroll Engine

Implements accelerated scrolling.

The Scroll Engine never reads hardware directly.

---

## Chord Engine

Implements simultaneous mouse-button actions.

The Chord Engine never reads hardware directly.

---

## Output Layer

Responsible for sending mouse wheel events, button presses and other output back to Windows.

Keeping output isolated simplifies testing and debugging.

---

# Reliability Requirements

ModMouse is designed with reliability as its primary objective.

The following requirements apply to every subsystem.

- Never silently modify user input.
- Never intentionally leave modifier keys in an altered state.
- Every state must have an explicit exit path.
- Unexpected input sequences must recover automatically.
- Runtime failures should degrade gracefully whenever possible.
- Configuration errors must prevent startup.

---

# Engineering Principles

## Single Responsibility

Every module should perform one clearly defined task.

## Explicit State

Hidden state should be avoided.

All runtime behaviour should be explainable through the active state.

## Event-Driven Design

Modules communicate using events rather than direct polling whenever practical.

## Configuration Before Execution

Configuration must be validated before any hooks or timers are registered.

## Reliability Before Features

Correct behaviour always takes precedence over feature count.

## Performance

CPU and memory usage should remain negligible during normal operation.

## Readability

Readable code is preferred over clever code.

Future maintainability is considered part of the implementation.

---

# Coding Standards

## Naming

Variables follow the format:

Module_Setting

Examples:

Input_ModifierKey

Scroll_StartDelay

Chord_OutputButton

Boolean variables end with:

Enabled

Example:

Debug_Enabled

Functions use PascalCase.

Examples:

Initialize()

ValidateConfiguration()

StartScrolling()

StopScrolling()

---

## Comments

Every public function should include a documentation block describing:

- Purpose
- Parameters
- Return value

Section dividers should remain consistent throughout the project.

---

# Scope

## Included in Version 1

- Accelerated scrolling
- Mouse chording
- Configurable controls
- Multiple compatibility improvements
- Debug mode

## Explicitly Out of Scope

The following features are intentionally excluded until justified.

- Plugin system
- GUI configuration editor
- Cloud synchronization
- Automatic updates
