# Rutini

**Rutini** is an accessibility-first daily routine planner and task-management application built with Flutter. Designed for individuals with cognitive, learning, and sensory differences—specifically targeting **ADHD**, **Autism Spectrum Disorder (ASD)**, and **Dyslexia**—Rutini converts overwhelming routine checklists into single-focus, step-by-step visual guides.

This project was built as the final project for our **Human-Computer Interaction (HCI)** university class.

---

## Core Features

### 1. Immersive Focus Mode (Zero Distractions)
* **Single-Task Focus**: Displays exactly one task at a time (e.g. "Brush your teeth") with large visual layouts and soft, rounded elements to avoid cognitive overload.
* **OS-Level Interruption Blocking**: Automatically hides system status and navigation bars (`immersiveSticky`) to prevent distracting notifications, and locks the screen awake during execution.

### 2. Gentle Reminders & Gamification
* **Nudge Escalation Pipeline**: Replaces panic-inducing alarms with soft progressive nudges (5 minutes before, scheduled start, and a gentle late alert).
* **Calming Dopamine Loops**: Gives positive feedback using low-frequency auditory chimes and subtle haptic feedback patterns rather than loud digital beeps.

### 3. Comprehensive Accessibility
* **Dyslexic-Friendly Typography**: Supports dynamic font selection (Atkinson Hyperlegible by the Braille Institute, OpenDyslexic, and Roboto) with optimized line-height and character spacing.
* **Contrast Theme Adaptations**: Easily switch between **Warm Bone Light** (minimizes eye strain), **Soft Dark**, and a strict **High Contrast Mode** (black/white with thick borders).
* **Text-To-Speech (TTS)**: Tap any description to hear instructions read aloud, with adjustable speech rates.

### 4. Caregiver Dashboard
* **Passkey Guarded Area**: Secured by a caregiver PIN block to separate the child/user environment from administrative configurations.
* **Routine & Task Builder**: Create schedules, pick visual icons, and drag-and-drop tasks to reorder steps.
* **Habit Insights**: Tracks completion rates, monthly calendar heatmaps, and displays automatic suggestions for skipped routines.

---

## Technology Stack

* **Framework**: Flutter (Dart 3.x)
* **Target Platforms**: Mobile (Android & iOS)
* **State Management**: BLoC (`flutter_bloc` + `hydrated_bloc` for crash-recovery progress hydration)
* **Backend Database**: Firebase Firestore (configured with **infinite offline caching** so the app works entirely without internet)
* **Authentication**: Firebase Authentication (supports Anonymous sign-in for performers and Email/Password for Caregivers)

