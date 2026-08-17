# 🩺 Smart Health Tracker

> A Flutter-based personal health monitoring application for recording, analyzing, and visualizing daily health measurements.

Smart Health Tracker is a personal health management application built with **Flutter and Dart**.
The application allows users to record health measurements, monitor historical data, analyze health status based on personalized thresholds, view statistics and trends, create health reminders, and generate health reports.

---

## 📱 Screenshots

### Dashboard

<p align="center">
  <img src="screenshots/dashboard.png" width="250"/>
</p>

### Health Tracking

<p align="center">
  <img src="screenshots/add-measurement.png" width="250"/>
  <img src="screenshots/health-history.png" width="250"/>
  <img src="screenshots/health-statistics.png" width="250"/>
</p>

### Health Analysis & Monitoring

<p align="center">
  <img src="screenshots/health-analysis.png" width="250"/>
  <img src="screenshots/health-trend.png" width="250"/>
  <img src="screenshots/health-thresholds.png" width="250"/>
</p>

### Profile & Reminders

<p align="center">
  <img src="screenshots/personal-information.png" width="250"/>
  <img src="screenshots/reminders.png" width="250"/>
  <img src="screenshots/health-report.png" width="250"/>
</p>

---

## ✨ Features

### ❤️ Health Measurement

Users can record their daily health measurements:

* Heart Rate — bpm
* Blood Pressure

  * Systolic — mmHg
  * Diastolic — mmHg
* Blood Glucose — mmol/L
* Measurement date and time
* Personal notes

---

### 📋 Health History

View previously recorded measurements in a structured history.

Each measurement displays:

* Measurement time
* Heart rate
* Blood pressure
* Blood glucose
* Health status
* Personal note

Users can also:

* ✏️ Edit measurements
* 🗑️ Delete measurements

---

### 🧠 Health Analysis

The application analyzes health measurements and classifies each metric into different statuses.

The analysis layer is separated from the UI through dedicated components such as:

```text
HealthAnalyzer
HealthAnalysisResult
HealthStatusHelper
HealthThreshold
```

This keeps health-related business logic separate from the presentation layer.

Example:

```text
Heart Rate
     ↓
HealthAnalyzer
     ↓
HealthAnalysisResult
     ↓
NORMAL / WARNING / DANGER
```

---

### ⚙️ Personalized Health Thresholds

Users can configure their own health thresholds.

Supported thresholds include:

| Metric                   | Minimum | Maximum |
| ------------------------ | ------: | ------: |
| Heart Rate               |       ✓ |       ✓ |
| Systolic Blood Pressure  |       ✓ |       ✓ |
| Diastolic Blood Pressure |       ✓ |       ✓ |
| Blood Glucose            |       ✓ |       ✓ |

These thresholds are stored locally and used by the health analysis system.

---

### 📊 Health Statistics

The statistics screen provides an overview of recorded measurements.

It includes:

* Total measurements
* Average heart rate
* Minimum heart rate
* Maximum heart rate
* Average systolic pressure
* Average diastolic pressure
* Average blood glucose
* Minimum blood glucose
* Maximum blood glucose
* Latest measurement
* Statistics summary

---

### 📈 7-Day Health Trend

The application provides visual health trends based on recent measurements.

Users can switch between:

* ❤️ Heart Rate
* 🩸 Blood Pressure
* 💧 Blood Glucose

This makes it easier to observe changes in health measurements over time.

---

### 🔔 Health Reminders

Users can create and manage reminders for health-related activities.

Supported functionality:

* Create reminder
* Edit reminder
* Delete reminder
* Enable / disable reminder
* Select health type
* Set reminder time

Example:

```text
Reminder
├── Name: Blood Pressure
├── Health Type: Blood Pressure
├── Time: 08:00
└── Status: Enabled
```

---

### 📄 Health Report

The application can generate a health report from recorded measurements.

The report includes:

* Latest measurement
* Measurement history
* Blood pressure
* Heart rate
* Blood glucose
* Measurement date and time

The generated report can be previewed and shared/printed through the Flutter printing functionality.

---

### 👤 Personal Information

Users can maintain their personal health profile:

* Name
* Age
* Gender
* Height
* Weight

This information is stored locally and can be updated through the profile section.

---

## 🏗️ Project Architecture

The project follows a feature-based structure with separation between UI, business logic, services, models, and database operations.

```text
lib/
│
├── app/
│   └── theme/
│       ├── app_colors.dart
│       ├── app_spacing.dart
│       └── app_text_styles.dart
│
├── features/
│   │
│   ├── health/
│   │   ├── analysis/
│   │   │   ├── health_analyzer.dart
│   │   │   ├── health_analysis_result.dart
│   │   │   ├── health_status_helper.dart
│   │   │   └── health_threshold.dart
│   │   │
│   │   ├── database/
│   │   │   └── health_database.dart
│   │   │
│   │   ├── models/
│   │   │   └── health_measurement.dart
│   │   │
│   │   ├── screens/
│   │   │   ├── add_health_measurement_screen.dart
│   │   │   ├── health_history_screen.dart
│   │   │   ├── health_stats_screen.dart
│   │   │   └── ...
│   │   │
│   │   ├── stats/
│   │   │   ├── health_stats.dart
│   │   │   ├── health_stats_service.dart
│   │   │   └── health_trend_service.dart
│   │   │
│   │   └── report/
│   │       └── health_report_pdf_service.dart
│   │
│   ├── dashboard/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   ├── profile/
│   │   └── screens/
│   │
│   └── reminder/
│       └── screens/
│
└── main.dart
```

---

## 🔄 Application Flow

```text
                 User
                   │
                   ▼
              Dashboard
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼
   Add Data    History     Statistics
        │          │          │
        └──────────┼──────────┘
                   ▼
            Health Database
                   │
                   ▼
             Health Analyzer
                   │
          ┌────────┼────────┐
          ▼        ▼        ▼
       Heart    Blood     Glucose
        Rate    Pressure
          │        │        │
          └────────┼────────┘
                   ▼
          Health Analysis Result
                   │
                   ▼
          NORMAL / WARNING / DANGER
```

---

## 🧩 Main Components

### Health Measurement

Responsible for representing recorded health data.

```text
HealthMeasurement
├── id
├── systolic
├── diastolic
├── heartRate
├── bloodGlucose
├── measuredAt
└── note
```

### Health Database

Handles local data persistence and CRUD operations.

```text
Create
Read
Update
Delete
```

The application uses a local SQLite database for storing health-related information.

### Health Analyzer

Responsible for analyzing measurements according to configured thresholds.

```text
Measurement
      ↓
HealthThreshold
      ↓
HealthAnalyzer
      ↓
HealthAnalysisResult
```

### Health Statistics Service

Calculates statistical information from recorded measurements.

### Health Trend Service

Provides recent measurements used by the trend visualization.

### Health Report PDF Service

Generates a PDF health report from stored measurement data.

---

## 🛠️ Tech Stack

| Technology          | Purpose                                |
| ------------------- | -------------------------------------- |
| **Flutter**         | Cross-platform application development |
| **Dart**            | Programming language                   |
| **SQLite**          | Local data storage                     |
| **sqflite**         | SQLite database access                 |
| **Material Design** | UI components                          |
| **Printing**        | PDF preview / printing / sharing       |
| **PDF**             | Health report generation               |

---

## 💾 Data Management

The application uses a local database to persist health information.

Main data categories include:

```text
Health Measurements
       │
       ├── Heart Rate
       ├── Blood Pressure
       ├── Blood Glucose
       ├── Measurement Time
       └── Notes

User Profile
       │
       ├── Name
       ├── Age
       ├── Gender
       ├── Height
       └── Weight

Health Thresholds
       │
       ├── Heart Rate
       ├── Systolic
       ├── Diastolic
       └── Blood Glucose
```

---

## 🎨 UI / UX

The application uses a dark health-monitoring interface with a consistent visual system.

### Design principles

* Dark navy background
* Card-based layout
* Mint green primary actions
* Clear health status indicators
* Consistent spacing
* Rounded components
* Mobile-first layout
* Clear separation between data and actions

### Status system

```text
NORMAL
   ↓
Healthy range

WARNING
   ↓
Outside preferred range

DANGER
   ↓
Critical range
```

> Health status is intended as an application analysis feature and should not be treated as a medical diagnosis.

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/congtruyen25/Smart_health_tracker_app.git
```

### 2. Open the project

```bash
cd Smart_health_tracker_app
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Check connected devices

```bash
flutter devices
```

### 5. Run the application

```bash
flutter run
```

---

## 🧪 Testing

Run Flutter tests with:

```bash
flutter test
```

Analyze the project with:

```bash
flutter analyze
```

---

## 📌 Current Project Status

### Completed

* [x] Health measurement CRUD
* [x] Local SQLite database
* [x] Health history
* [x] Heart rate tracking
* [x] Blood pressure tracking
* [x] Blood glucose tracking
* [x] Health status analysis
* [x] Personalized health thresholds
* [x] Health statistics
* [x] 7-day health trends
* [x] Personal information
* [x] Health reminders
* [x] PDF health reports
* [x] Dashboard
* [x] Dark UI design

### Future Improvements

* [ ] Authentication
* [ ] Cloud database synchronization
* [ ] Online health data backup
* [ ] More advanced health analytics
* [ ] Export data to CSV
* [ ] More detailed charts
* [ ] Improved notification scheduling
* [ ] Unit and widget test coverage

---

## 🎯 Project Goals

Smart Health Tracker was developed to practice and demonstrate practical software development skills including:

* Flutter application development
* Dart programming
* Object-oriented programming
* CRUD operations
* SQLite database management
* Service-layer architecture
* Business logic separation
* Data visualization
* PDF generation
* Local notification/reminder functionality
* UI/UX design
* Git and GitHub workflow

---

## 📚 What I Learned

Through this project, I practiced:

* Designing a Flutter application from scratch
* Structuring a feature-based Flutter project
* Separating UI from business logic
* Designing reusable widgets
* Working with SQLite
* Implementing CRUD operations
* Handling asynchronous operations with `Future`
* Managing application state
* Building reusable analysis services
* Creating charts and statistics
* Generating PDF reports
* Debugging Flutter runtime and database issues
* Using Git and GitHub for version control

---

## 👨‍💻 Developer

**Truyền**

IT Student
Flutter / Backend / Full-stack Development

This project is developed as a practical learning project to improve software development skills and prepare for an internship / junior developer role.

---

## ⭐ If you find this project useful

Feel free to explore the source code, try the application, or give the repository a ⭐.
