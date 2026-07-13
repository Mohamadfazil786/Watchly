# CineSphere

[![Flutter](https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Language-Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Gemini](https://img.shields.io/badge/AI-Google%20Gemini-4285F4?logo=googlegemini&logoColor=white)](https://deepmind.google/technologies/gemini/)

CineSphere is an elegant, feature-rich social platform designed for movie and television enthusiasts. Built with Flutter, it bridges the gap between cataloging databases and community networking, allowing users to discover, log, review, and organize cinema while interacting with a community of like-minded cinephiles. 

---

## 🌟 Key Features

### 🔍 Discovery & Cataloging
* **Comprehensive Search:** Search the extensive database of movies and TV shows, powered by The Movie Database (TMDB).
* **Detailed Media Insights:** Explore ratings, release dates, genres, runtimes, synopses, cast information, and crew details.
* **Smart Watchlists:** Keep track of movies and shows you plan to watch.

### ✍️ Reviews, Logbooks & Collections
* **Movie Logging:** Log movies you've watched, complete with watch date, personal ratings, and detailed descriptions.
* **Interactive Reviews:** Express your thoughts via reviews and engage in discussions through comment threads.
* **Custom Curated Lists:** Create, edit, and share custom movie/show collections (e.g., *"Top Sci-Fi of the 2010s"*, *"Halloween Spooktacular"*).

### 👥 Social Community
* **Interactive Social Feed:** View real-time updates of watched movies, reviews, and lists posted by people you follow.
* **User Profiles:** Customize your profile, choose favorite genres, view other users' lists/reviews, and follow profiles to stay updated.
* **User Search:** Connect with other movie enthusiasts in the community.

### 🤖 Gemini AI Integration
* **Mood-Based Search:** Find the perfect title by typing in a prompt describing your mood or desired vibe (e.g., *"I want to watch a coding thriller set in Seattle"*).
* **Title Comparison:** Compare two movies side-by-side using Gemini AI to analyze differences in tone, themes, pacing, and visual style.
* **Personalized AI Recommendations:** Receive movie and show suggestions tailored specifically to your favorite genres, watched history, and rating habits.

---

## 🛠️ Technology Stack & Architecture

CineSphere utilizes a modern, robust architecture optimized for scalability, clean state separation, and cross-platform performance.

### Core Architecture
* **Presentation Layer (Flutter):** Built using declarative, reusable UI components styled with customized material design themes.
* **State Management (Riverpod):** Implements `flutter_riverpod` to ensure predictable state flows, decoupling UI components from repository logic and caching.
* **Navigation (GoRouter):** Declarative, URL-driven routing system supporting nested and transition-friendly navigation paths.

### Backend Infrastructure (Firebase)
* **Firebase Authentication:** Handles secure user authentication, supporting Email/Password logins and Google Sign-In integrations.
* **Cloud Firestore:** Real-time database for storing and synchronizing user profiles, social relationships, movie logs, custom lists, and review interactions.
* **Firebase Storage:** Secure media bucket hosting user-generated custom avatars.
* **Firebase Cloud Messaging:** Powering push notifications to alert users of social interactions, comments, and followers.

### Data & Local Caching
* **Hive Database:** High-performance local storage for lightweight user settings, preferences, and onboarding flags.
* **TMDB API Integration:** Consumes REST endpoints from TMDB to deliver up-to-date, rich media metadata.
* **Google Generative AI SDK:** Interfaces directly with Google's Gemini models to handle complex NLP-driven requests, mood searches, and comparative analysis.
