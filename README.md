# 🚀 Orbit: Enter Your Productivity Orbit

![Orbit Mockup](https://via.placeholder.com/1200x600?text=Insert+Your+Aesthetic+Mockup+Here)

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)](https://firebase.google.com/)
[![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-blue?style=for-the-badge)](https://riverpod.dev/)

## 📌 About the Project

**Orbit** is an intelligent productivity management application specifically designed to address the problem of cognitive overload experienced by individuals with highly dynamic and mobile lifestyles. Built using a **Challenge-Based Learning (CBL)** approach, Orbit serves as a real-world, user-centered solution.

Unlike traditional to-do list applications that require users to manually organize rigid calendar blocks, Orbit acts as an assistant that takes over the planning burden, allowing users to stay focused on task execution rather than task scheduling.

## ✨ Key Features

### 🧠 Smart Task Engine

Minimizes user input. Simply provide a **deadline** and **difficulty level**, and the algorithm will automatically:

- Calculate task priority using the **Orbit Score**
- Determine urgency levels
- Recommend the ideal time to work on the task

### 🌊 Daily Priority Flow

A clean and focused daily task flow without overwhelming vertical calendars.

- Automatically sorted tasks based on urgency
- Clear prioritization of daily responsibilities
- A distraction-free productivity experience

### 🎯 Action-Driven Goals

Long-term goals become actionable rather than remaining simple aspirations.

- Create personal visions and goals
- Break goals down into actionable milestones
- Track progress in real time

Progress percentages are automatically calculated based on completed milestones.

## 🛠️ Architecture & Technologies

This project emphasizes clean code architecture, reactive state management, and secure data handling.

- **Frontend / UI:** Flutter & Dart
- **State Management:** Riverpod
- **Backend / Database:** Firebase Authentication & Cloud Firestore (NoSQL)
- **Security:** User-based data isolation (`userId`) and optimized data retrieval using Firestore Composite Indexes

---

## 🚀 Getting Started

This project uses Firebase as a **Backend as a Service (BaaS)**.

For security reasons, the original Firebase configuration files are not included in this repository. To run the application locally, you must connect it to your own Firebase project.

### Prerequisites

1. Install the Flutter SDK:
   https://docs.flutter.dev/get-started/install

2. Install Firebase CLI and log in with your Google account:

```bash
firebase login
```

3. Activate FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

### Installation & Firebase Setup

#### 1. Clone the Repository

```bash
git clone https://github.com/your-username/orbit-app.git
cd orbit-app
```

#### 2. Install Dependencies

```bash
flutter pub get
```

#### 3. Create a Firebase Project

- Open Firebase Console.
- Create a new project.
- Enable:
  - Authentication (Email/Password)
  - Cloud Firestore Database

#### 4. Connect the Application to Firebase

Run the following command from the project root directory:

```bash
flutterfire configure
```

Select:

- Your newly created Firebase project
- Android platform
- iOS platform (optional)

This command will automatically generate:

```text
lib/firebase_options.dart
```

#### 5. Run the Application

```bash
flutter run
```
