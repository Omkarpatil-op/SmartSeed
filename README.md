
-----

# SmartSeed 🌱📚

SmartSeed is an AI-powered, gamified learning app that helps kids improve math and reading skills through interactive exercises, personalized study plans, and a playful, engaging experience—while giving parents tools to track progress and support their child’s growth.

-----

## 🚀 Features

  - **AI-Powered Personalization**: The app adapts to each child's learning pace, strengths, and preferences, providing customized study plans.
  - **Gamified Learning**: Fun and interactive games and quizzes that motivate kids to learn and progress.
  - **Multiplayer Learning**: Kids can learn together, collaborate, and challenge each other in friendly competitions.
  - **Parental Dashboard**: A feature for parents to track their child's progress, manage screen time, and receive AI-powered recommendations.
  - **Reading Comprehension**: Fun reading exercises designed to improve vocabulary, understanding, and fluency.
  - **Math Mastery**: Engaging math problems and challenges designed to build strong foundations in arithmetic and problem-solving.
  - **Speech Recognition**: The app uses speech recognition technology to assist in reading, pronunciation, and math-related activities.

-----

## 🎮 Technologies Used

  - **Flutter**: Cross-platform development for building iOS and Android apps.
  - **TensorFlow**: AI algorithms for personalized learning and recommendations.
  - **Firebase**: For real-time database management, user authentication, and cloud storage.
  - **Google Cloud**: For advanced AI and machine learning services.
  - **Speech Recognition**: For voice-based activities and comprehension tasks.

-----

## 🛠️ Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

  * You need to have Flutter installed on your machine. For instructions, see the [official Flutter documentation](https://flutter.dev/docs/get-started/install).

### Firebase Setup

This project uses Firebase for its backend services. For security reasons, the `google-services.json` file is not included in this repository. You will need to create your own Firebase project to run the app.

1.  **Create a Firebase Project**: Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
2.  **Add an Android App**: Inside your new project, add a new Android application.
      * **Package Name**: Use `com.example.smartseed` as the package name.
      * Follow the on-screen instructions.
3.  **Download Config File**: Download the `google-services.json` file that Firebase provides.
4.  **Place the File**: Move the downloaded `google-services.json` file into the `android/app/` directory of this project.

### 📱 Installation

Now you can install the project dependencies and run the app.

1.  Clone the repository:
    ```bash
    git clone https://github.com/Omkarpatil-op/SmartSeed.git
    ```
2.  Install packages:
    ```bash
    flutter pub get
    ```
3.  Run the app:
    ```bash
    flutter run
    ```
