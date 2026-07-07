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
; RUNTIME STATE
; ----------------------------------------------------------------------------------------------------------------------
; The runtime state object stores all mutable engine data.
;
; Design Principle:
;     The runtime object is the engine's single source of truth. Subsystems
;     communicate by updating this object rather than creating independent
;     global variables.
; ======================================================================================================================

; Current engine version.
global MM_Version := "0.1.0-dev"

; Runtime state container.
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

; Enables future debug logging without modifying engine code.
MM_Runtime.DebugEnabled := false

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
Config_Version := 1

; ----------------------------------------------------------------------------------------------------------------------
; INPUT
; ----------------------------------------------------------------------------------------------------------------------

; Modifier key used to activate the alternate mouse layer.
Input_ModifierKey := "Alt"

; Mouse button responsible for downward scrolling.
Input_ScrollDownButton := "XButton1"

; Mouse button responsible for upward scrolling.
Input_ScrollUpButton := "XButton2"

; ----------------------------------------------------------------------------------------------------------------------
; SCROLLING
; ----------------------------------------------------------------------------------------------------------------------

; Enables or disables scroll acceleration.
Scroll_AccelerationEnabled := true

; Initial delay (milliseconds) before acceleration begins.
Scroll_StartDelay := 120

; Fastest allowable scroll interval once maximum acceleration is reached.
Scroll_MinimumDelay := 30

; Time (milliseconds) required to reach maximum scrolling speed.
Scroll_AccelerationTime := 1500

; ----------------------------------------------------------------------------------------------------------------------
; CHORDING
; ----------------------------------------------------------------------------------------------------------------------

; Enables simultaneous button combinations.
Chord_Enabled := true

; Mouse button emitted when a valid chord is detected.
Chord_OutputButton := "MButton"

; Duration (milliseconds) of the simulated button press.
Chord_ClickDuration := 50

; ----------------------------------------------------------------------------------------------------------------------
; COMPATIBILITY
; ----------------------------------------------------------------------------------------------------------------------

; Temporarily releases the modifier key when required to avoid application-
; specific conflicts (for example, browser zoom shortcuts).
Compatibility_ReleaseModifier := true

; Enables Windows menu masking during synthetic Alt manipulation.
Compatibility_MenuMask := true

; ----------------------------------------------------------------------------------------------------------------------
; DEBUG
; ----------------------------------------------------------------------------------------------------------------------

; Enables future diagnostic logging and development tools.
Debug_Enabled := false

; ======================================================================================================================
; CONFIGURATION VALIDATION
; ----------------------------------------------------------------------------------------------------------------------
; MM_ValidateConfiguration()
;
; Description:
;     Ensures all configuration values are valid before the engine begins
;     processing input.
;
; Parameters:
;     None.
;
; Returns:
;     None.
;
; Notes:
;     Phase 1 provides the function stub only. Validation rules will be
;     implemented during future development milestones.
; ======================================================================================================================

MM_ValidateConfiguration()
{
    ; TODO:
    ; Implement configuration validation.
}

; ======================================================================================================================
; ENGINE INITIALIZATION
; ----------------------------------------------------------------------------------------------------------------------
; MM_Initialize()
;
; Description:
;     Performs all startup tasks required before ModMouse begins accepting input.
;
; Initialization Order:
;     1. Validate configuration.
;     2. Initialize runtime state.
;     3. Initialize engine subsystems.
;     4. Register input handlers.
;
; Parameters:
;     None.
;
; Returns:
;     None.
;
; Notes:
;     Only configuration validation is performed during Phase 1.
; ======================================================================================================================

MM_Initialize()
{
    MM_ValidateConfiguration()

    ; TODO:
    ; Additional startup tasks will be implemented during future milestones.
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
