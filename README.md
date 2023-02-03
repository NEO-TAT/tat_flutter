<h6 align="center">
<a href="https://apps.apple.com/tw/app/tat-%E5%8C%97%E7%A7%91%E7%94%9F%E6%B4%BB/id1513875597?itscg=30200&amp;itsct=apps_box_appicon" style="width: 170px; height: 170px; border-radius: 22%; overflow: hidden; display: inline-block; vertical-align: middle;"><img src="https://is3-ssl.mzstatic.com/image/thumb/Purple112/v4/20/2b/3b/202b3b1c-c977-5445-365d-52593ed795f3/AppIcon-0-1x_U007emarketing-0-7-0-85-220.png/540x540bb.jpg" alt="TAT - 北科生活" style="width: 170px; height: 170px; border-radius: 22%; overflow: hidden; display: inline-block; vertical-align: middle;"></a>
</h6>

<h1 align="center">
<b>TAT</b>
<i><p><small>the Best NTUT Campus life assistant</small></p></i>
</h1>

<h6 align="center">

[![CI](https://github.com/NEO-TAT/tat_flutter/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/NEO-TAT/tat_flutter/actions/workflows/build.yml)

<a href='https://play.google.com/store/apps/details?id=club.ntut.npc.tat'>
<img height="50px" alt='Get it on Google Play' src='https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg'/>
</a>

<a href="https://apple.co/3Rmojax">
<img height="50px" alt='Get it on AppStore' src='https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg'>
</a>

</h6>

## Introduction
TAT is a solution that simplifies campus life. 

With this app, you can quickly view the course tables, classroom, grades, and calendar for each semester, as well as quickly log in to the i-plus website without entering your account information. 

Additionally, we offer common functions of i-Plus, such as downloading course files and viewing notifications. 

Furthermore, you can view your friends' course tables and see what courses they have chosen.

If you would like to learn more about the features, why not download and try it for yourself? We support both Android and iOS/iPadOS platforms, making it the most widely used assistant app at National Taipei University of Technology (NTUT).

## Our story
Not long after the establishment of the **NTUT Programming Club (N.P.C.)**, the founding president created a campus life app called TTS (with features similar to TAT), which was launched on the Google Play Store (due to its development in Android native, there was no iOS version available).

Approximately 2 to 3 years after TTS was in use, a member of NPC had new ideas. He hoped to achieve the goal of a dual-platform launch through the newly-released cross-platform open-source development framework (Flutter) by Google at that time. As a result, the founding president of NPC worked with him to complete the initial version of TAT and released it on both platforms.

Now, TAT has become a necessary tool for Northeastern students. In fact, this is due to the efforts of the student union at that time.

However, what many people do not know is that TAT is a project fully developed by NPC and does not rely on any assistance from the school or student union. Therefore, it does not have any obligations to the school or student union. This makes every time the backend of the school has changes, all TAT users will immediately be at risk of encountering unexpected errors.

## Get started
<a href="https://flutter.dev/">
<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="get started with flutter">
</a>

Due to the strong drive of ![Flutter](https://flutter.dev/), the development of TAT is accomplished with half the effort.

- First, it is recommended that you install Flutter in your development environment. If you are not yet familiar with Flutter, you may refer to its official website for tutorials.

- Next, you are required to install ![Android Studio](https://developer.android.com/studio) or ![VSCode](https://code.visualstudio.com/) in your development environment, as Flutter and Dart officially recommend the use of these two solutions for development. However, if you believe that other editors/IDEs are a better choice for you, you may try installing them as well.

- Once your editor/IDE is set up, it is advisable to run Flutter Doctor to check for any missing steps.
  ```bash
  # Make sure you are using the latest Stable version of Flutter and Dart.
  flutter doctor -v
  ```

- Now, you may clone the code of TAT to your environment through ![Git](https://git-scm.com/).
  ```bash
  git clone --recurse-submodules git@github.com:NEO-TAT/tat_flutter.git
  ```

- Then, start installing the dependencies in the TAT project.
  ```bash
  flutter pub get --exclude=tat_core
  ```

Once all dependencies are successfully installed (excluding `tat_core`), you can start doing whatever you want!

> **Note**
> If you need to debug the TAT app in your environment, you must first become a member of the **NTUT Programming Club (N.P.C.)**, as this will enable your Android Studio to access TAT's core business logic code. Otherwise, you will not be able to build successfully. For information on how to join the **NPC**, please refer to the Contact Us section below.

If you got any questions during the above steps, please feel free to contact us (NPC) anytime.

## Discussion
The TAT team always holds a positive attitude and strives to provide the best product to all users. We are always willing to listen to any valuable feedback from our users.

Therefore, if you have any suggestions or advice regarding this app, we sincerely hope that you can go to the "Feedback" section under the "Others" tab in the app and fill out the feedback form.

If you would like to participate directly in our development discussions, you are welcome to join our ![Discord server](https://discord.gg/FvRwmSCKWY) or post your ideas in the ![GitHub Discussion](https://github.com/orgs/NEO-TAT/discussions).

## Become contributor
<img src="https://i.imgur.com/7yYwMr1.webp" height="200">

If you are inclined to contribute to the improvement of this app, we welcome your participation at all times, regardless of the form it may take.

While we certainly welcome more capable developers, contributing to this app does not necessarily require writing code. If your expertise lies in areas such as UI design, animation design, project management, DevOps, planning, quality management, automation, security, server-side, front-end web development, CI/CD, AI, ML, networking, IoT, multilingual translation, accounting and finance, advertising, marketing, and promotion, among others, we also highly value your involvement.

Furthermore, we have compiled detailed development materials into our ![wiki](https://github.com/NEO-TAT/tat_flutter/wiki) and invite you to peruse it at your convenience.

## Contact us
<a href="https://discord.gg/FvRwmSCKWY"><img src="https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Discord server"></a>
<a href="https://www.facebook.com/NPC.OwO"><img src="https://img.shields.io/badge/Facebook-1877F2?style=for-the-badge&logo=facebook&logoColor=white" alt="Facebook"></a>

<img width="100px" alt="NPC Special Logo SEO" src="https://user-images.githubusercontent.com/47718989/216663916-a7f568e0-8cdd-4cda-8d2d-2c8f72ac08bc.png">

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

_Copyright © 2023 All rights reserved and owned by [**N.P.C. 北科程式設計研究社**](https://ntut.club)._
