<!-- markdownlint-disable no-inline-html first-line-heading -->

<img src="assets/images/tat-round.png" alt="App logo" align="right" style="width: 20%" />

# TAT

The swiss army knife for NTUT students.

[![All Contributors](https://img.shields.io/github/all-contributors/NEO-TAT/tat_flutter?color=ee8449&style=for-the-badge)](#contributors)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/NEO-TAT/tat_flutter/build.yml?logo=github&style=for-the-badge)

<a href="https://play.google.com/store/apps/details?id=club.ntut.npc.tat">
  <img
    src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg"
    alt="Get it on Google Play"
    style="height: 72px"
  />
</a>
<a href="https://apps.apple.com/tw/app/tat-北科生活">
  <img
    src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg"
    alt="Download on the App Store"
    style="height: 72px"
  />
</a>

## Introduction

TAT is an app designed to simplify your college life. It allows you to quickly access your course schedule, classroom locations, grades, and semester calendar. You can also easily log in to i-School Plus without entering your account information.

In addition, you can use TAT to download course materials and check for announcements, just like with i-School Plus. Furthermore, you can also view your friends' schedules and the courses they have chosen.

If you are interested in learning more about TAT, simply download it! It is available on both Android and iOS/iPadOS platforms and is widely used by students at National Taipei University of Technology (NTUT) to stay organized and manage their academic lives more effectively.

## Our story

The NTUT Programming Club (NPC) was founded, and its director created an app called TTS, similar to TAT, which was launched on the Google Play Store for Android. After 2-3 years, another club member proposed using the cross-platform open-source development framework Flutter to launch TAT on both Android and iOS platforms. With the founding director's help, they completed TAT's initial version, which has become a necessary tool for the university's students.

However, many are unaware that TAT is a project developed entirely by NPC, without any support from the school or student union. As a result, TAT is not obligated to the school or student union, and whenever the school's backend undergoes changes, TAT users may face unexpected errors.

## Getting started

To develop TAT with Flutter, follow these steps:

1. Install [Flutter][Flutter] in your development environment by referring to its official website for tutorials.

2. Install either [Android Studio][Android Studio] or [Visual Studio Code][Visual Studio Code], as they are officially recommended by Flutter and Dart for development. However, you can use other editors/IDEs if you prefer.

3. Run `flutter doctor` to check for any missing steps in your editor/IDE setup.

4. Clone this repository with the `--recurse-submodules` flag. For example: `git clone --recurse-submodules git@github.com:NEO-TAT/tat_flutter.git`.

5. Install the dependencies using the command `flutter pub get`.

6. Once all dependencies are successfully installed (excluding `tat_core`), you can start developing TAT.

Note that to debug the app locally, you must first join the [NTUT Programming Club GitHub organization][NPC GitHub] for the `tat_core` dependency. If you encounter any issues during the process, feel free to [Contact Us](#contact-us) for assistance.

## Discussion

The TAT team is always positive and aims to provide the best product for users. They are open to valuable feedback and suggestions from users.

If you have any suggestions or advice regarding the app, you can go to the "Feedback" section under the "Others" tab in the app and fill out the feedback form.

You can also participate in development discussions directly by joining the [TAT Discord server][Discord] or posting your ideas in the [TAT Flutter GitHub Discussions][Discussions].

## Becoming a contributor

<img
  src="https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Uncle_Sam_%28pointing_finger%29.png/178px-Uncle_Sam_%28pointing_finger%29.png"
  alt="Uncle Sam (pointing finger)"
  align="right"
/>

We welcome anyone who wants to contribute to the improvement of this app, regardless of their skills or expertise. While we appreciate skilled developers, you don't necessarily have to be one to contribute. You can help with UI design, animation design, project management, DevOps, planning, quality management, automation, security, server-side, front-end web development, CI/CD, AI, ML, networking, IoT, multilingual translation, accounting and finance, advertising, marketing, and promotion, among other things.

We've compiled detailed development materials in our [wiki][Wiki] and encourage you to check it out at your leisure.

## Contact us

[![Discord server](https://img.shields.io/discord/1068833951143178242?color=5865F2&label=Discord&logo=discord&style=for-the-badge)][Discord]

[![Facebook](https://img.shields.io/badge/Facebook-Follow-1877F2?style=for-the-badge&logo=facebook)][NPC Facebook]

[![Our website](https://img.shields.io/badge/Website-visit-black?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxZW0iIGhlaWdodD0iMWVtIiB2aWV3Qm94PSIwIDAgMjQgMjQiPjxwYXRoIGZpbGw9ImN1cnJlbnRDb2xvciIgZD0iTTE2LjM2IDE0Yy4wOC0uNjYuMTQtMS4zMi4xNC0yYzAtLjY4LS4wNi0xLjM0LS4xNC0yaDMuMzhjLjE2LjY0LjI2IDEuMzEuMjYgMnMtLjEgMS4zNi0uMjYgMm0tNS4xNSA1LjU2Yy42LTEuMTEgMS4wNi0yLjMxIDEuMzgtMy41NmgyLjk1YTguMDMgOC4wMyAwIDAgMS00LjMzIDMuNTZNMTQuMzQgMTRIOS42NmMtLjEtLjY2LS4xNi0xLjMyLS4xNi0yYzAtLjY4LjA2LTEuMzUuMTYtMmg0LjY4Yy4wOS42NS4xNiAxLjMyLjE2IDJjMCAuNjgtLjA3IDEuMzQtLjE2IDJNMTIgMTkuOTZjLS44My0xLjItMS41LTIuNTMtMS45MS0zLjk2aDMuODJjLS40MSAxLjQzLTEuMDggMi43Ni0xLjkxIDMuOTZNOCA4SDUuMDhBNy45MjMgNy45MjMgMCAwIDEgOS40IDQuNDRDOC44IDUuNTUgOC4zNSA2Ljc1IDggOG0tMi45MiA4SDhjLjM1IDEuMjUuOCAyLjQ1IDEuNCAzLjU2QTguMDA4IDguMDA4IDAgMCAxIDUuMDggMTZtLS44Mi0yQzQuMSAxMy4zNiA0IDEyLjY5IDQgMTJzLjEtMS4zNi4yNi0yaDMuMzhjLS4wOC42Ni0uMTQgMS4zMi0uMTQgMmMwIC42OC4wNiAxLjM0LjE0IDJNMTIgNC4wM2MuODMgMS4yIDEuNSAyLjU0IDEuOTEgMy45N2gtMy44MmMuNDEtMS40MyAxLjA4LTIuNzcgMS45MS0zLjk3TTE4LjkyIDhoLTIuOTVhMTUuNjUgMTUuNjUgMCAwIDAtMS4zOC0zLjU2YzEuODQuNjMgMy4zNyAxLjkgNC4zMyAzLjU2TTEyIDJDNi40NyAyIDIgNi41IDIgMTJhMTAgMTAgMCAwIDAgMTAgMTBhMTAgMTAgMCAwIDAgMTAtMTBBMTAgMTAgMCAwIDAgMTIgMloiLz48L3N2Zz4=)][NPC Website]

## Contributors

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

---
_© 2023 [**N.P.C. 北科程式設計研究社**][NPC Website]._

[Flutter]: https://flutter.dev
[Android Studio]: https://developer.android.com/studio
[Visual Studio Code]: https://code.visualstudio.com
[Discussions]: https://github.com/NEO-TAT/tat_flutter/discussions
[Wiki]: https://github.com/NEO-TAT/tat_flutter/wiki
[Discord]: https://ntut.club/jointat
[NPC Website]: https://ntut.club
[NPC GitHub]: https://github.com/NTUT-NPC
[NPC Facebook]: https://www.facebook.com/NPC.OwO
