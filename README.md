<div align="center">

<!-- LEAVE SPACE FOR YOUR LOGO HERE -->
<!-- Replace the src with the path to your logo once you have it -->
<!-- For example: <img src="assets/logo/app_logo.png" alt="Vibe Together Logo" width="200"/> -->
<img src="https://res.cloudinary.com/dr8g09icb/image/upload/v1750832781/ChatGPT_Image_Jun_25_2025_05_20_20_AM_qzzfl4.png" alt="Vibez Logo" width="200"/>
<br/>
<br/>

# Vibez

**Find your tribe. Share your vibe.**

_Vibez is a Flutter-based mobile application designed to connect like-minded individuals through shared interests, events, and spontaneous social interactions. It's more than just a social network; it's a community platform built on the idea of finding people who match your "vibe"._

</div>

---

## 🧠 The Vibe System: Our Core Philosophy

At the heart of Vibez is a unique approach to matchmaking that goes beyond superficial profiles. We believe that true connections start with understanding personality.

Every new user is welcomed with a **conversational, audio-led quiz**. Instead of a boring form, the app asks a series of questions in a natural, friendly tone, making the onboarding process feel like a chat with a friend.

Based on their answers, each user is branded with one of **five core Vibe Attributes**:

-   **🌍 The Explorer:** Craves new experiences, travel, and spontaneity. They are adventurous and always ready for the next thrill.

-   **🎨 The Creator:** Artistic, imaginative, and sees the world through a unique lens. They express themselves through building, designing, writing, or making music.

-   **🤔 The Thinker:** Loves deep conversation, learning new things, and intellectual curiosity. They are drawn to puzzles, documentaries, and understanding how things work.

-   **🤝 The Connector:** Thrives on social interaction, community building, and empathy. They are the life of the party and the heart of their social circles.

-   **🧘 The Harmonizer:** Values peace, comfort, and creating a sense of balance. They enjoy relaxing activities, nature, and a calm, stable environment.

This initial "Vibe" is the foundation of our entire ecosystem. It powers in-app notifications for new matches and helps foster more meaningful initial connections by introducing you to people who genuinely share your outlook on life.

---

## ✨ Features

Vibez is packed with features designed to foster genuine connections and community engagement.

| Feature             | Description                                                                                                                             | Status      |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| **Vibe Onboarding** | A unique, conversational quiz with audio questions that assigns users one of five core "vibes" to kickstart the matching process.         | ✅ Complete |
| **Dynamic Home Feed** | A unified, real-time feed showing the latest public posts and "Vibe" events, sorted chronologically.                                    | ✅ Complete |
| **Post Creation**   | Users can create text-based posts and enrich them with image uploads (powered by Cloudinary) to share their thoughts and experiences.   | ✅ Complete |
| **Post Interaction**| Engage with posts through a fully functional Like and Comment system.                                                                 | ✅ Complete |
| **Vibe Events**     | Create and discover user-generated events with images, details on location, time, attendees, and a dedicated comment section.             | ✅ Complete |
| **Event Interaction** | A dynamic Join/Leave system for Vibe Events, with logic to handle full capacity.                                                        | ✅ Complete |
| **Groups**          | Create and join public or private groups based on hobbies, location, or any shared interest. Each group has its own dedicated feed.       | ✅ Complete |
| **User Profiles**     | View other users' profiles, see their primary vibe, and browse the content they've created.                                             | ✅ Complete |
| **Profile Editing**   | Users can edit their own display name and profile picture, with changes reflected across all their past content.                          | ✅ Complete |
| **Real-time Chat**    | A full chat system with a request/accept flow, ensuring users consent to conversations.                                                 | ✅ Complete |
| **Live Search**     | A multi-tabbed search screen to discover Posts, Vibes, Groups, and other Users in real-time.                                           | ✅ Complete |
| **In-App Notifications** | Receive notifications for new vibe matches directly in the app.                                                                    | ✅ Complete |
| **Light Theme UI**    | A clean, modern, and branded light-mode user interface designed around the app's new logo and color scheme.                               | ✅ Complete |

---

## 📸 App Screenshots

<div align="center">
  <img src="https://res.cloudinary.com/dr8g09icb/image/upload/v1750848125/WhatsApp_Image_2025-06-25_at_16.07.15_d5bcd9fe_roo1zr.jpg" width="200" alt="Home Screen"/>
  <img src="https://res.cloudinary.com/dr8g09icb/image/upload/v1750848125/WhatsApp_Image_2025-06-25_at_16.07.15_61f358d2_nr61ae.jpg" width="200" alt="Search Screen"/>
  <img src="https://res.cloudinary.com/dr8g09icb/image/upload/v1750833127/WhatsApp_Image_2025-06-25_at_11.59.17_cb20e113_jmr9tw.jpg" width="200" alt="Chat Screen"/>
  <img src="https://res.cloudinary.com/dr8g09icb/image/upload/v1750848125/WhatsApp_Image_2025-06-25_at_16.07.15_fb3f8abe_xzxh6w.jpg" width="200" alt="Group Detail Screen"/>
  <img src="https://res.cloudinary.com/dr8g09icb/image/upload/v1750848126/WhatsApp_Image_2025-06-25_at_16.07.16_d261e8da_lghjic.jpg" width="200" alt="Users Screen"/>
  <img src="https://res.cloudinary.com/dr8g09icb/image/upload/v1750848293/Screenshot_2025-06-25_151155_e6k64r.png" width="200" alt="Profile Screen"/>
  <img src="https://res.cloudinary.com/dr8g09icb/image/upload/v1750848293/Screenshot_2025-06-25_151146_rti1zy.png" width="200" alt="Vibe Screen"/>
  <img src="https://res.cloudinary.com/dr8g09icb/image/upload/v1750848292/Screenshot_2025-06-25_151204_gtyeef.png" width="200" alt="Notification Screen"/>
</div>

---

## 🛠️ Tech Stack & Architecture

This project leverages a modern and scalable stack, built entirely on Flutter and Firebase.

-   **Frontend:** [Flutter](https://flutter.dev/) - For building a high-performance, cross-platform mobile application from a single codebase.
-   **Backend:** [Firebase](https://firebase.google.com/) - A comprehensive suite of tools for the backend.
    -   **Authentication:** Firebase Auth for secure Google sign-in.
    -   **Database:** Cloud Firestore, a NoSQL database for real-time data synchronization.
-   **Image Hosting:** [Cloudinary](https://cloudinary.com/) - For robust image hosting, optimization, and delivery.
-   **State Management:** [Provider](https://pub.dev/packages/provider) - For simple, efficient, and scalable state management.
-   **Architecture:** The app is structured using a clean, service-oriented architecture.
    -   **Models:** Define the data structures (User, Post, Group, etc.).
    -   **Services:** Handle all business logic and communication with Firebase (AuthService, PostService, GroupService).
    -   **Providers:** Manage and provide app-wide state (e.g., the current user's data).
    -   **Screens:** The UI layer, which consumes data from services and providers.
    -   **Widgets:** Reusable UI components (PostCard, GroupCard, etc.).

---

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

-   [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.x.x or higher)
-   An IDE like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)
-   An active [Firebase](https://firebase.google.com/) account
-   A [Cloudinary](https://cloudinary.com/) account (for image uploads)

### Installation & Setup

1.  **Clone the Repository**
    ```sh
    git clone https://github.com/your-username/vibe-together-app.git
    cd vibe-together-app
    ```

2.  **Set up Firebase**
    -   Create a new project in the [Firebase Console](https://console.firebase.google.com/).
    -   Enable **Authentication** (Google & Email/Password) and **Cloud Firestore**.
    -   Install the Firebase CLI and FlutterFire CLI, then configure the project:
        ```sh
        flutterfire configure
        ```
    -   Download the generated `google-services.json` file and place it in `android/app/`.

3.  **Configure Android**
    -   To enable Google Sign-In, you need to add your machine's SHA-1 fingerprint to your Firebase project settings. Run the following command in the `android` directory:
        ```sh
        ./gradlew signingReport
        ```
    -   Copy the `SHA1` key from the `debug` variant and add it to your Firebase project settings under **Project settings > Your apps > Android**.

4.  **Configure Cloudinary**
    -   Create an **unsigned upload preset** in your Cloudinary settings.
    -   Open `lib/services/image_upload_service.dart` and replace the placeholder values with your **Cloud Name** and **Upload Preset Name**.
      ```dart
      static const String _cloudName = "YOUR_CLOUD_NAME_HERE";
      static const String _uploadPreset = "YOUR_UPLOAD_PRESET_NAME_HERE";
      ```

5.  **Install Dependencies & Run**
    -   Get all the required Flutter packages:
        ```sh
        flutter pub get
        ```
    -   Run the app on your emulator or physical device:
        ```sh
        flutter run
        ```

---

## 🌟 Future Work

This project has a solid foundation, but there's always room to grow! Here are some potential features for the future:

-   [ ] **Video Uploads:** Allow users to upload short videos to posts and groups.
-   [ ] **Real-time Location:** Implement features like "Nearby Vibes" using user location data.
-   [ ] **Push Notifications:** Re-integrate Firebase Cloud Messaging for instant notifications about new matches, messages, and group activity.
-   [ ] **Advanced Search & Filtering:** Add powerful filters to the search screen (e.g., filter posts by vibe, filter events by date).
-   [ ] **Monetization:** Explore options like "Featured Vibe" promotions or premium group features.

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<div align="center">
  Made with ❤️ and Flutter
</div>
