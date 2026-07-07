; ======================================================================================================================
; Project      : ModMouse
; File         : ModMouse.ahk
; Version      : 0.1.0-dev
; Status       : Development (Foundation Complete)
; Author       : Shaun Jacob
; License      : MIT
;
; Repository   : https://github.com/sky-cloutclouds/modmouse
;
; Description  :
;     ModMouse is a lightweight AutoHotkey utility that enhances mouse interaction
;     through configurable modifier layers, accelerated scrolling, and intelligent
;     mouse-button chording.
;
; Philosophy   :
;     Reliability takes priority over feature count. Every subsystem is designed
;     to be deterministic, maintainable, and easy to understand. The codebase
;     favors explicit behavior over hidden complexity.
;
; ======================================================================================================================

#NoEnv
#SingleInstance Force
#Warn

#KeyHistory 0
ListLines Off
SetBatchLines -1
SendMode Input
SetWorkingDir %A_ScriptDir%

; Prevents Windows from activating the Alt menu while the engine temporarily
; manipulates the modifier state during input processing.
#MenuMaskKey vk11

; ======================================================================================================================
; COMPATIBILITY CHECK
; ----------------------------------------------------------------------------------------------------------------------
; Ensures the user is running a supported AutoHotkey version before continuing.
; Future releases may require newer versions as additional language features are
; adopted.
; ======================================================================================================================

if (A_AhkVersion < "1.1.33")
{
    MsgBox, 16, ModMouse, ModMouse requires AutoHotkey v1.1.33 or newer.
    ExitApp
}

; ======================================================================================================================
; PRIVILEGE ELEVATION
; ----------------------------------------------------------------------------------------------------------------------
; Certain input operations require administrative privileges to function
; consistently across all applications. If the script is not already elevated,
; it automatically restarts itself with administrator permissions.
; ======================================================================================================================

if !A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

; ======================================================================================================================
; ENGINE CONSTANTS
; ----------------------------------------------------------------------------------------------------------------------
; Engine-wide constants shared across all ModMouse subsystems.
;
; Design Principle:
;     Constants represent immutable values. Unlike the runtime object, these
;     values never change while the engine is executing.
; ======================================================================================================================

; Current ModMouse engine version.
global MM_Version := "0.1.0-dev"

; Scroll direction identifiers.
global MM_SCROLL_NONE := 0
global MM_SCROLL_UP   := -1
global MM_SCROLL_DOWN := 1

; ======================================================================================================================
; ENGINE RUNTIME
; ----------------------------------------------------------------------------------------------------------------------
; The engine runtime object stores all mutable state used by the engine.
;
; Design Principle:
;     The runtime object is the engine's single source of truth. Subsystems
;     communicate by updating this object rather than creating independent
;     global variables.
; ======================================================================================================================

; Engine runtime container.
global MM_Runtime := {}

; Current lifecycle state of the engine.
;
; Possible values:
;     Initializing
;     Ready
;     Suspended
;     Shutdown
MM_Runtime.EngineState := "Initializing"

; Indicates whether a scrolling operation is currently active.
MM_Runtime.ScrollActive := false

; Current scrolling direction.
MM_Runtime.ScrollDirection := MM_SCROLL_NONE

; Indicates whether the configured modifier key is currently held.
MM_Runtime.ModifierPressed := false

; Tracks whether the modifier was temporarily released by the
; compatibility layer.
MM_Runtime.ModifierReleased := false

; Indicates whether a mouse-button chord is currently active.
MM_Runtime.ChordActive := false

; ======================================================================================================================
; ENGINE CONFIGURATION
; ----------------------------------------------------------------------------------------------------------------------
; All engine configuration is defined within this section.
;
; Design Principle:
;     Configuration represents the engine's behaviour, not its current state.
;     Unlike the runtime object, configuration values remain constant during
;     normal execution and are intended to be modified only by the user or
;     future configuration management systems.
;
; Future Development:
;     Configuration persistence, profile management, and runtime reloading will
;     build upon this section without requiring architectural changes.
; ======================================================================================================================

; ----------------------------------------------------------------------------------------------------------------------
; GENERAL
; ----------------------------------------------------------------------------------------------------------------------

; Configuration schema version.
; Incremented whenever breaking configuration changes are introduced.
MM_Config_Version := 1

; ----------------------------------------------------------------------------------------------------------------------
; INPUT
; ----------------------------------------------------------------------------------------------------------------------

; Modifier key used to activate the alternate mouse layer.
MM_Config_Input_ModifierKey := "Alt"

; Mouse button responsible for downward scrolling.
MM_Config_Input_ScrollDownButton := "XButton1"

; Mouse button responsible for upward scrolling.
MM_Config_Input_ScrollUpButton := "XButton2"

; ----------------------------------------------------------------------------------------------------------------------
; SCROLLING
; ----------------------------------------------------------------------------------------------------------------------

; Enables or disables scroll acceleration.
MM_Config_Scroll_AccelerationEnabled := true

; Initial delay (milliseconds) before acceleration begins.
MM_Config_Scroll_StartDelay := 120

; Fastest allowable scroll interval once maximum acceleration is reached.
MM_Config_Scroll_MinimumDelay := 30

; Time (milliseconds) required to reach maximum scrolling speed.
MM_Config_Scroll_AccelerationTime := 1500

; ----------------------------------------------------------------------------------------------------------------------
; CHORDING
; ----------------------------------------------------------------------------------------------------------------------

; Enables or disables mouse-button chording.
MM_Config_Chord_Enabled := true

; Mouse button emitted when a valid chord is detected.
MM_Config_Chord_OutputButton := "MButton"

; Duration (milliseconds) of the simulated button press.
MM_Config_Chord_ClickDuration := 50

; ----------------------------------------------------------------------------------------------------------------------
; COMPATIBILITY
; ----------------------------------------------------------------------------------------------------------------------

; Temporarily releases the modifier key when required to avoid application-
; specific conflicts (for example, browser navigation shortcuts).
MM_Config_Compatibility_ReleaseModifier := true

; Enables Windows menu masking during synthetic Alt manipulation.
MM_Config_Compatibility_MenuMask := true

; ----------------------------------------------------------------------------------------------------------------------
; DEBUG
; ----------------------------------------------------------------------------------------------------------------------

; Enables future diagnostics and development tools.
MM_Config_Debug_Enabled := false

; ======================================================================================================================
; ENGINE UTILITIES
; ----------------------------------------------------------------------------------------------------------------------
; Common utility functions shared across the ModMouse engine.
;
; Design Principle:
;     Utility functions perform common engine operations that may be used by
;     multiple subsystems. They should remain independent of any single
;     subsystem and provide consistent behaviour throughout the engine.
; ======================================================================================================================

; ----------------------------------------------------------------------------------------------------------------------
; MM_FatalError()
;
; Description:
;     Reports a fatal engine error and safely terminates ModMouse.
;
; Parameters:
;     Message
;         A human-readable description of the fatal error.
;
; Returns:
;     None.
;
; Notes:
;     All unrecoverable engine failures should be routed through this
;     function to ensure consistent behaviour and future extensibility.
; ----------------------------------------------------------------------------------------------------------------------

MM_FatalError(Message)
{
    MsgBox, 16, ModMouse, %Message%
    ExitApp
}

; ======================================================================================================================
; DIAGNOSTICS
; ----------------------------------------------------------------------------------------------------------------------
; Provides centralized diagnostic services for the ModMouse engine.
;
; Design Principle:
;     Diagnostics observe engine behaviour without affecting program flow.
;     Future logging backends can be introduced without requiring changes to
;     the engine itself.
; ======================================================================================================================

; ----------------------------------------------------------------------------------------------------------------------
; MM_Log()
;
; Description:
;     Writes a diagnostic message to the active logging backend.
;
; Parameters:
;     Message
;         The message to record.
;
; Returns:
;     None.
;
; Notes:
;     During early development, diagnostics are routed exclusively through
;     OutputDebug. Future releases may additionally support log files,
;     debugging consoles, telemetry, and configurable logging levels.
; ----------------------------------------------------------------------------------------------------------------------

MM_Log(Message)
{
    global MM_Config_Debug_Enabled

    if (!MM_Config_Debug_Enabled)
        return

    OutputDebug, [ModMouse] %Message%
}

; ======================================================================================================================
; CONFIGURATION VALIDATION
; ----------------------------------------------------------------------------------------------------------------------
; Validates engine configuration before ModMouse begins accepting user input.
;
; Design Principle:
;     Validation is divided into subsystem-specific functions to improve
;     maintainability and simplify future expansion. Each configuration
;     category is responsible for validating its own settings.
; ======================================================================================================================

; ----------------------------------------------------------------------------------------------------------------------
; MM_ValidateConfiguration()
;
; Description:
;     Executes all configuration validation routines.
;
; Parameters:
;     None.
;
; Returns:
;     None.
; ----------------------------------------------------------------------------------------------------------------------

MM_ValidateConfiguration()
{
    MM_ValidateInputConfiguration()
    MM_ValidateScrollConfiguration()
    MM_ValidateChordConfiguration()
    MM_ValidateCompatibilityConfiguration()
    MM_ValidateDebugConfiguration()
}

; ----------------------------------------------------------------------------------------------------------------------
; INPUT CONFIGURATION VALIDATION
; ----------------------------------------------------------------------------------------------------------------------

MM_ValidateInputConfiguration()
{
    global MM_Config_Input_ModifierKey

    if (MM_Config_Input_ModifierKey = "")
        MM_FatalError("MM_Config_Input_ModifierKey cannot be empty.")
}

; ----------------------------------------------------------------------------------------------------------------------
; SCROLL CONFIGURATION VALIDATION
; ----------------------------------------------------------------------------------------------------------------------

MM_ValidateScrollConfiguration()
{
    global MM_Config_Scroll_StartDelay
    global MM_Config_Scroll_MinimumDelay
    global MM_Config_Scroll_AccelerationTime

    if (MM_Config_Scroll_StartDelay < 0)
        MM_FatalError("MM_Config_Scroll_StartDelay must be zero or greater.")

    if (MM_Config_Scroll_MinimumDelay < 0)
        MM_FatalError("MM_Config_Scroll_MinimumDelay must be zero or greater.")

    if (MM_Config_Scroll_AccelerationTime <= 0)
        MM_FatalError("MM_Config_Scroll_AccelerationTime must be greater than zero.")
}

; ----------------------------------------------------------------------------------------------------------------------
; CHORD CONFIGURATION VALIDATION
; ----------------------------------------------------------------------------------------------------------------------

MM_ValidateChordConfiguration()
{
    global MM_Config_Chord_ClickDuration

    if (MM_Config_Chord_ClickDuration < 0)
        MM_FatalError("MM_Config_Chord_ClickDuration must be zero or greater.")
}

; ----------------------------------------------------------------------------------------------------------------------
; COMPATIBILITY CONFIGURATION VALIDATION
; ----------------------------------------------------------------------------------------------------------------------

MM_ValidateCompatibilityConfiguration()
{
    ; Reserved for future validation rules.
}

; ----------------------------------------------------------------------------------------------------------------------
; DEBUG CONFIGURATION VALIDATION
; ----------------------------------------------------------------------------------------------------------------------

MM_ValidateDebugConfiguration()
{
    ; Reserved for future validation rules.
}

; ======================================================================================================================
; ENGINE INITIALIZATION
; ----------------------------------------------------------------------------------------------------------------------
; Responsible for preparing the ModMouse engine before user input is accepted.
;
; Design Principle:
;     Engine initialization follows a deterministic sequence. Every subsystem
;     is initialized in a well-defined order to ensure predictable behaviour
;     and simplify future expansion.
; ======================================================================================================================

; ----------------------------------------------------------------------------------------------------------------------
; MM_Initialize()
;
; Description:
;     Performs all startup tasks required before ModMouse begins accepting
;     user input.
;
; Initialization Order:
;     1. Log engine startup.
;     2. Validate configuration.
;     3. Initialize runtime state.
;     4. Prepare engine subsystems.
;     5. Transition the engine to the Ready state.
;
; Parameters:
;     None.
;
; Returns:
;     None.
; ----------------------------------------------------------------------------------------------------------------------

MM_Initialize()
{
    global MM_Version
    global MM_Runtime

    MM_Log("ModMouse " . MM_Version . " starting.")

    MM_ValidateConfiguration()

    MM_Runtime.EngineState := "Ready"

    MM_Log("Engine initialization complete.")
}

; ======================================================================================================================
; APPLICATION ENTRY POINT
; ----------------------------------------------------------------------------------------------------------------------
; Execution begins here.
;
; The engine is initialized before any runtime logic becomes active. Future
; development will register timers, hotkeys, and subsystem event handlers only
; after successful engine initialization.
; ======================================================================================================================

MM_Initialize()

return
