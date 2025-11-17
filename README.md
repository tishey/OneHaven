# OneHaven App

A Flutter application for caregivers to manage protected members with screen time controls, built with Riverpod for state management and featuring offline-first architecture.

## 🚀 Features
- **Splash Screen** - Introduce the platform
- **User Authentication** - Mock login and logout
- **Member Dashboard** - View and manage protected members
- **Screen Time Controls** - Toggle screen time restrictions
- **Offline Support** - Hive-based local caching
- **Pull-to-Refresh** - Synchronize with server
- **Responsive Design** - Works on phones and tablets
- **Error Handling** - Graceful fallbacks and user-friendly errors

## 🛠 Tech Stack
- **Flutter** 3.35.7 - UI Framework
- **Riverpod** - State Management
- **Dio** - HTTP Client
- **Hive** - Local Database
- **Express.js** - Mock Server

## 📋 Prerequisites
- Flutter SDK 3.35.7
- Node.js 16+
- Android Studio / Xcode (for emulators)

## 🚀 Quick Start

### 1. Clone and Setup Flutter App

```bash
# Clone the repository
git https://github.com/tishey/OneHaven/tree/master


# Install dependencies
flutter pub get

# Run the app
flutter run

# Navigate to the mock server directory
cd mock_server

# Navigate to the mock server directory
npm install

# Start the mock server
node mock-server.js

# Expected Output
Mock server running at http://localhost:3000
Available endpoints:
  GET  /members
  PATCH /members/:id
  POST /auth/login

# Expected Output
 [ 
    {
    id: "m001",
    firstName: "Emma",
    lastName: "Johnson",
    birthYear: 2010,
    relationship: "Daughter",
    avatar: "https://i.pravatar.cc/150?img=1",
    status: "active",
    screenTimeEnabled: true
  },
  {
    id: "m002",
    firstName: "Liam",
    lastName: "Smith",
    birthYear: 2008,
    relationship: "Son", 
    avatar: "https://i.pravatar.cc/150?img=2",
    status: "active",
    screenTimeEnabled: false
  },]