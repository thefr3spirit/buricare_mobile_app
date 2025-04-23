<a id="readme-top"></a>

[![Contributors][contributors-shield]][contributors-url]  
[![Forks][forks-shield]][forks-url]  
[![Stargazers][stars-shield]][stars-url]  
[![Issues][issues-shield]][issues-url]  
[![License][license-shield]][license-url]  
[![LinkedIn][linkedin-shield]][linkedin-url]  

<br />

<div align="center">
  <a href="https://github.com/thefr3spirit/buricare_mobile_app">
    <img src="assets/buricare_logo.png" alt="BuriCare Logo" width="80" height="80">
  </a>

  <h3 align="center">BuriCare Mobile App</h3>

  <p align="center">
    A Flutter-based application for real-time monitoring, local caching, 
    and cloud synchronization of premature babies’ vital signs.
    <br />
    <a href="https://github.com/thefr3spirit/buricare_mobile_app"><strong>Explore the Code »</strong></a>
    <br /><br />
    <a href="https://github.com/thefr3spirit/buricare_mobile_app">View Demo</a>
    &middot;
    <a href="https://github.com/thefr3spirit/buricare_mobile_app/issues/new?labels=bug">Report Bug</a>
    &middot;
    <a href="https://github.com/thefr3spirit/buricare_mobile_app/issues/new?labels=enhancement">Request Feature</a>
  </p>
</div>

---

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#built-with">Built With</a></li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul><li><a href="#prerequisites">Prerequisites</a></li>
          <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

---

## About The Project

BuriCare is a cross-platform Flutter app designed to work with a Bluetooth-connected pouch device that provides an optimal environment for premature babies. Equipped with sensors for heart rate, temperature, and SpO₂, the device streams data to the mobile app, allowing both medical professionals and parents to:

- **View real-time vitals** on dedicated dashboard tiles.  
- **Store data locally** using Hive for offline reliability.  
- **Aggregate readings** into minute, hourly, and daily averages.  
- **Sync** with Firebase Firestore under `/users/{uid}/…` collections.  
- **Receive alerts** when vitals deviate from safe ranges.  
- **Run in the background**, ensuring continuous monitoring even when the UI is closed.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Built With

- [![Flutter][Flutter-shield]][Flutter-url]  
- [![Dart][Dart-shield]][Dart-url]  
- [![Firebase][Firebase-shield]][Firebase-url]  
- [![Hive][Hive-shield]][Hive-url]  
- [![Riverpod][Riverpod-shield]][Riverpod-url]  
- [![Connectivity Plus][Connectivity-shield]][Connectivity-url]  
- [![Flutter Local Notifications][Notifications-shield]][Notifications-url]  

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.19)  
- Dart SDK (>= 3.3)  
- Android Studio / Xcode  
- Firebase project with Android/iOS apps configured  

### Installation

1. **Clone the repo**  
   ```sh
   git clone https://github.com/thefr3spirit/buricare_mobile_app.git
   cd buricare_mobile_app
   ```

2. **Install packages**  
   ```sh
   flutter pub get
   ```

3. **Configure Firebase**  
   - Place `google-services.json` in `android/app/`  
   - Place `GoogleService-Info.plist` in `ios/Runner/`  
   - (Re)generate `lib/firebase_options.dart` with FlutterFire CLI:
     ```sh
     flutterfire configure
     ```

4. **Generate Hive adapters**  
   ```sh
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**  
   ```sh
   flutter run
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Usage

- **Sign In:** Email/password or Google.  
- **AuthGate** directs users to sign-in, email-verification, or home screens.  
- **Home Dashboard:**  
  - Real-time tiles for each vital.  
  - Button to view graphs (last minute, hour, day, month).  
- **Background Operation:**  
  - On Android, a foreground service keeps the app alive.  
  - On iOS, background fetch syncs cached data periodically.  

_For more details, see the in-code comments under `lib/services/` and `lib/repositories/`._

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Roadmap

- [ ] Add daily average graph  
- [ ] Implement push notifications for alerts  
- [ ] Enhance background reliability on iOS  
- [ ] Add unit & integration tests  
- [ ] CI/CD pipeline for automated builds  

See [open issues](https://github.com/thefr3spirit/buricare_mobile_app/issues) for more.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Contributing

Contributions are welcome! Please:

1. Fork the repo  
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)  
3. Commit your changes (`git commit -m 'Add feature'`)  
4. Push to the branch (`git push origin feature/AmazingFeature`)  
5. Open a Pull Request  

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## License

Distributed under the MIT License. See [`LICENSE`](LICENSE) for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Contact

Beofr3Spirit – [@thefr3spirit](https://github.com/thefr3spirit) – beofr3spirit@gmail.com

Project Link: [https://github.com/thefr3spirit/buricare_mobile_app](https://github.com/thefr3spirit/buricare_mobile_app)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

<!-- Shields & Links -->
[contributors-shield]: https://img.shields.io/github/contributors/thefr3spirit/buricare_mobile_app.svg?style=for-the-badge  
[contributors-url]: https://github.com/thefr3spirit/buricare_mobile_app/graphs/contributors  
[forks-shield]: https://img.shields.io/github/forks/thefr3spirit/buricare_mobile_app.svg?style=for-the-badge  
[forks-url]: https://github.com/thefr3spirit/buricare_mobile_app/network/members  
[stars-shield]: https://img.shields.io/github/stars/thefr3spirit/buricare_mobile_app.svg?style=for-the-badge  
[stars-url]: https://github.com/thefr3spirit/buricare_mobile_app/stargazers  
[issues-shield]: https://img.shields.io/github/issues/thefr3spirit/buricare_mobile_app.svg?style=for-the-badge  
[issues-url]: https://github.com/thefr3spirit/buricare_mobile_app/issues  
[license-shield]: https://img.shields.io/github/license/thefr3spirit/buricare_mobile_app.svg?style=for-the-badge  
[license-url]: https://github.com/thefr3spirit/buricare_mobile_app/blob/main/LICENSE  
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-blue?style=for-the-badge&logo=linkedin  
[linkedin-url]: https://linkedin.com/in/thefr3spirit  

[Flutter-shield]: https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white  
[Flutter-url]: https://flutter.dev/  
[Dart-shield]: https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white  
[Dart-url]: https://dart.dev/  
[Firebase-shield]: https://img.shields.io/badge/Firebase-FFA611?style=for-the-badge&logo=firebase&logoColor=white  
[Firebase-url]: https://firebase.google.com/  
[Hive-shield]: https://img.shields.io/badge/Hive-5C18A9?style=for-the-badge&logo=hive&logoColor=white  
[Hive-url]: https://pub.dev/packages/hive_flutter  
[Riverpod-shield]: https://img.shields.io/badge/Riverpod-6F2DBD?style=for-the-badge&logo=reactivex&logoColor=white  
[Riverpod-url]: https://pub.dev/packages/flutter_riverpod  
[Connectivity-shield]: https://img.shields.io/badge/ConnectivityPlus-4285F4?style=for-the-badge&logo=googlechrome&logoColor=white  
[Connectivity-url]: https://pub.dev/packages/connectivity_plus  
[Notifications-shield]: https://img.shields.io/badge/LocalNotifications-FF6F00?style=for-the-badge&logo=google&logoColor=white  
[Notifications-url]: https://pub.dev/packages/flutter_local_notifications  

[product-screenshot]: images/screenshot.png  

