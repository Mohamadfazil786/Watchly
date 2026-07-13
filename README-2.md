<div align="center">

<img src="img/poster.png" alt="CineSphere Poster" width="100%"/>

# CineSphere

### An elegant social platform for movie and television enthusiasts

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Gemini](https://img.shields.io/badge/Gemini-AI-8E75B2?style=for-the-badge&logo=googlegemini&logoColor=white)](https://ai.google.dev)

</div>

---

## About

CineSphere is a feature-rich Flutter application that bridges the gap between cataloging databases and community networking, giving users a single place to discover, log, review, and organize cinema while engaging with a community of like-minded film and TV enthusiasts.

Rather than treating movie tracking and social interaction as separate concerns, CineSphere unifies them around a shared data model: a logged movie becomes a feed post, a review becomes a discussion thread, and a curated list becomes something to follow and share. The app is powered by The Movie Database (TMDB) for media metadata and integrates Google's Gemini models directly into the discovery experience, moving beyond simple keyword search toward mood-based and comparative recommendations.

---

## Key Features

### Discovery & Cataloging

- **Comprehensive Search** — Search the extensive database of movies and TV shows, powered by The Movie Database (TMDB).
- **Detailed Media Insights** — Explore ratings, release dates, genres, runtimes, synopses, cast information, and crew details.
- **Smart Watchlists** — Keep track of movies and shows you plan to watch.

### Reviews, Logbooks & Collections

- **Movie Logging** — Log movies you've watched, complete with watch date, personal ratings, and detailed descriptions.
- **Interactive Reviews** — Express your thoughts via reviews and engage in discussions through comment threads.
- **Custom Curated Lists** — Create, edit, and share custom movie/show collections (e.g., "Top Sci-Fi of the 2010s", "Halloween Spooktacular").

### Social Community

- **Interactive Social Feed** — View real-time updates of watched movies, reviews, and lists posted by people you follow.
- **User Profiles** — Customize your profile, choose favorite genres, view other users' lists and reviews, and follow profiles to stay updated.
- **User Search** — Connect with other movie enthusiasts in the community.

### Gemini AI Integration

- **Mood-Based Search** — Find the perfect title by describing your mood or desired vibe in a prompt (e.g., "I want to watch a coding thriller set in Seattle").
- **Title Comparison** — Compare two movies side by side using Gemini AI to analyze differences in tone, themes, pacing, and visual style.
- **Personalized AI Recommendations** — Receive movie and show suggestions tailored to your favorite genres, watch history, and rating habits.

---

## Technology Stack & Architecture

CineSphere uses a modern architecture optimized for scalability, clean state separation, and cross-platform performance.

### Core Architecture

- **Presentation Layer (Flutter)** — Declarative, reusable UI components styled with a customized Material Design theme.
- **State Management (Riverpod)** — `flutter_riverpod` ensures predictable, unidirectional state flows and decouples UI components from repository logic and caching.
- **Navigation (GoRouter)** — Declarative, URL-driven routing supporting nested and transition-friendly navigation paths.

### Backend Infrastructure (Firebase)

- **Firebase Authentication** — Secure user authentication supporting Email/Password login and Google Sign-In.
- **Cloud Firestore** — Real-time database for storing and synchronizing user profiles, social relationships, movie logs, custom lists, and review interactions.
- **Firebase Storage** — Secure media bucket hosting user-generated custom avatars.
- **Firebase Cloud Messaging** — Powers push notifications for social interactions, comments, and new followers.

### Data & Local Caching

- **Hive Database** — High-performance local storage for lightweight user settings, preferences, and onboarding flags.
- **TMDB API Integration** — Consumes REST endpoints from TMDB to deliver up-to-date, rich media metadata.
- **Google Generative AI SDK** — Interfaces directly with Google's Gemini models to handle complex NLP-driven requests, mood searches, and comparative analysis.

---

## Tech Stack Summary

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Framework | Flutter / Dart | Cross-platform UI |
| State | Riverpod | Reactive, decoupled state management |
| Navigation | GoRouter | Declarative routing |
| Backend | Firebase (Auth, Firestore, Storage, FCM) | Auth, real-time data, media, notifications |
| Local Storage | Hive | Fast on-device settings and preferences |
| Media Data | TMDB API | Movie and TV metadata |
| AI | Google Gemini (Generative AI SDK) | Mood search, comparisons, recommendations |

---

## Contact

**Andrew Akram**
Email: andrewakram75@gmail.com
GitHub: [github.com/Andrew-Akram](https://github.com/Andrew-Akram)

<div align="center">

Built with Flutter

</div>
