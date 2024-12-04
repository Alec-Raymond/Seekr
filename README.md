# **Seekr App**

## **Table of Contents**
1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Architecture](#architecture)
5. [Permissions](#permissions)
6. [Contributions](#features-and-contributions)

---

## **1. Introduction**
- **What is Seekr?**
  - A mobile app designed to enhance exploration while walking or biking.
  - Features advanced map functionalities, notifications, and user-friendly navigation tools.
- **Purpose**
  - To provide users with seamless navigation and exploration experiences.

---

## **2. Installation**

### Dependencies

**Firebase and Google Services**
- Firebase (11.4.0)
- AppCheck (11.1.0)
- GoogleAppMeasurement (11.4.0)
- GoogleDataTransport (10.1.0)
- GoogleUtilities (8.0.2)
- InteropForGoogle (100.0.0)
- GTMSessionFetcher (3.5.0)

**Networking and Data**
- gRPC (1.65.1)
- SwiftProtobuf (1.28.2)
- Promises (2.4.0)
- abseil (1.2024011602.0)

 **Database and Storage**
- leveldb (1.22.5)
- nanopb (2.30910.0)

---

## **3. Usage**
### Where to find the app
- Find and Download on Apple Store.
### Ways to use the app
  - **Login/Registration**:
    - Create an account or log in to access app.
  - **Main Navigation**:
    - Access the interactive map to start your journey and explore.
  - **Add Pins**:
    - Add pins to remember fun places you have been to.
  - **Hard Mode**:
     - Are you an experienced traveler? Turn off the map and try to find your way to your destination without visual help.
  - **Friend Invite Link (Prototype)**:
      - Invite your friends to use the app together.
    
## **4. Architecture**
  - Firebase
  - Swift
  - XCode
  - MapKit
  - UIKit


## **5. Permissions**
  - The app requires Location and Notifications permissions in order to function properly
---

## **6. Contributions**
### Login and Registration

  - UI Design: Taya, Ryan
  - Firebase functions for creating and logging in users: Ryan, Taya

### Pin Functionality
  - Create, Destroy, Find Pins (UCSC locations, bathrooms, coffee shops): Taya, Aidan

### Landmarks
  - Find 10 hidden landmarks around the Santa Cruz Area by exploring the map: Zander

### Profile

  - Profile Page + UI: Aidan
  - Firebase routes to delete or sign out of profiles: Ryan

### Social Features

  - Invite Friends Link Prototype: Aidan

### Application Accesability

  - Home page overlay menu to access other pages (Invite friends, profile, etc...): Ryan

### Notifications

  - Notification Scheduling and Sending: Lisa
  - Notification Permission Handling: Lisa

### Navigation

  - Navigation Functionality: Alec
  - Path to Desination: Alec
  - Wrong Direction Detection: Lisa
  - Start and end route functionality: Zander
  - Visual Progress Bar: Zander
  - Compass: Alec

### Gameplay Enhancements

  - Hard Mode Toggle: Alec

### Map Features

  - Basic Map: Lisa and Alec
  - Camera: Alec
