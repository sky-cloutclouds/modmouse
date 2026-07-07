; ======================================================================================================================
; Project      : ModMouse
; File         : ModMouse.ahk
; Version      : 0.1.0-dev
; Author       : Shaun Jacob
; License      : MIT
;
; Repository   : https://github.com/sky-cloutclouds/modmouse
;
; Description  :
;     ModMouse is a lightweight AutoHotkey utility that enhances mouse interaction through configurable modifier
;     layers, accelerated scrolling, and intelligent mouse-button chording.
;
; Philosophy   :
;     Reliability takes priority over feature count. Every subsystem is designed to be deterministic,
;     maintainable, and easy to understand. The codebase favors explicit behavior over hidden complexity.
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

; Prevents Windows from activating the Alt menu while the script temporarily
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
; it will automatically restart itself with administrator permissions.
; ======================================================================================================================

if !A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

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

; Current ModMouse engine version.
global MM_Version := "0.1.0-dev"

; Engine runtime container.
global MM_Runtime := {}

; Indicates whether engine initialization completed successfully.
MM_Runtime.Initialized := false

; Indicates whether a scrolling operation is currently active.
MM_Runtime.ScrollActive := false

; Current scrolling direction.
;  1  = Down
; -1  = Up
;  0  = Idle
MM_Runtime.ScrollDirection := 0

; Indicates whether the configured modifier key is currently held.
MM_Runtime.ModifierPressed := false

; Tracks whether the modifier was temporarily released by the compatibility layer.
MM_Runtime.ModifierReleased := false

; Indicates whether a mouse-button chord is currently active.
MM_Runtime.ChordActive := false

; ======================================================================================================================
; USER CONFIGURATION
; ----------------------------------------------------------------------------------------------------------------------
; All user-adjustable behavior is defined within this section.
;
; Future configuration validation will ensure values remain within supported
; ranges before engine initialization begins.
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

; Enables simultaneous button combinations.
MM_Config_Chord_Enabled := true

; Mouse button emitted when a valid chord is detected.
MM_Config_Chord_OutputButton := "MButton"

; Duration (milliseconds) of the simulated button press.
MM_Config_Chord_ClickDuration := 50

; ----------------------------------------------------------------------------------------------------------------------
; COMPATIBILITY
; ----------------------------------------------------------------------------------------------------------------------

; Temporarily releases the modifier key when required to avoid application-
; specific conflicts (for example, browser zoom shortcuts).
MM_Config_Compatibility_ReleaseModifier := true

; Enables Windows menu masking during synthetic Alt manipulation.
MM_Config_Compatibility_MenuMask := true

; ----------------------------------------------------------------------------------------------------------------------
; DEBUG
; ----------------------------------------------------------------------------------------------------------------------

; Enables future Diagnostics and development tools.
MM_Config_Debug_Enabled := false

; ======================================================================================================================
; CONFIGURATION VALIDATION
; ----------------------------------------------------------------------------------------------------------------------
; MM_ValidateConfiguration()
;
; Description:
;     Validates all user configuration before the engine begins accepting input.
;
; Parameters:
;     None.
;
; Returns:
;     None.
;
; Notes:
;     Validation is divided into subsystem-specific functions to keep the
;     engine modular and maintainable. Each configuration category is
;     responsible for validating its own settings.
; ======================================================================================================================

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
    if (MM_Config_Input_ModifierKey = "")
        MM_FatalError("Input_ModifierKey cannot be empty.")
}

; ----------------------------------------------------------------------------------------------------------------------
; SCROLL CONFIGURATION VALIDATION
; ----------------------------------------------------------------------------------------------------------------------

MM_ValidateScrollConfiguration()
{
    if (MM_Config_Scroll_StartDelay < 0)
        MM_FatalError("MM_Config_Scroll_StartDelay must be zero or greater.")

    if (MM_Config_Scroll_MinimumDelay < 0)
        MM_FatalError("Scroll_MinimumDelay must be zero or greater.")

    if (MM_Config_Scroll_AccelerationTime <= 0)
        MM_FatalError("Scroll_AccelerationTime must be greater than zero.")
}

; ----------------------------------------------------------------------------------------------------------------------
; CHORD CONFIGURATION VALIDATION
; ----------------------------------------------------------------------------------------------------------------------

MM_ValidateChordConfiguration()
{
    if (MM_Config_Chord_ClickDuration < 0)
        MM_FatalError("Chord_ClickDuration must be zero or greater.")
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
; DIAGNOSTICS
; ----------------------------------------------------------------------------------------------------------------------
; MM_Log()
;
; Description:
;     Provides centralized diagnostic services for ModMouse.
;
; Parameters:
;     Message
;         The message to write to the diagnostic backend.
;
; Returns:
;     None.
;
; Notes:
;     During early development, diagnostics are routed exclusively through
;     OutputDebug. Future releases may additionally support log files,
;     debugging consoles, or telemetry without requiring engine changes.
; ======================================================================================================================

MM_Log(Message)
{
    if (!MM_Config_Debug_Enabled)
        return

    OutputDebug, [ModMouse] %Message%
}

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
; ENGINE INITIALIZATION
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
;
; Parameters:
;     None.
;
; Returns:
;     None.
; ======================================================================================================================

MM_Initialize()
{
    MM_Log("ModMouse " . MM_Version . " starting.")

    MM_ValidateConfiguration()

    MM_Runtime.Initialized := true

    MM_Log("Engine initialization complete.")
}

; ======================================================================================================================
; APPLICATION ENTRY POINT
; ----------------------------------------------------------------------------------------------------------------------
; The engine is initialized before any runtime logic becomes active.
;
; Execution remains here until every required subsystem has successfully
; completed initialization.
; ======================================================================================================================

MM_Initialize()

return
