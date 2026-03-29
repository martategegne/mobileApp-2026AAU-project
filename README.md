# mobileApp-2026AAU-project
# Smart Study Resource Sharing Platform

## Description
A mobile application that enables students to share, access, and manage academic resources such as lecture notes, past exams, and study materials.

The system promotes collaboration, accessibility, and efficient learning within a university environment.

## Features
- Authentication (Signup/Login)
  .User Signup
  .User Login / Logout
  .Delete Account
- Authorization (Student/Admin roles)
  Role-based access:
  .Student
  .Admin
  Permissions:
    . Students: upload, request, view resources
    . Admin: manage users, delete inappropriate content
-Resource Management (CRUD)
  .Upload study materials (PDF, Image, Document)
  .View all resources
  .Update resource details
  .Delete resources
  .Search resources by:
    .Course Code
    .Keywords
- Resource Requests (CRUD)
  .Create request
  .View all requests
  .Update request
  .Delete request
  .Mark request as fulfilled
- Offline support
  .Access cached resources without internet
  .Sync data automatically when connection is restored
  
  ## Advanced Features
Resource rating system
Most downloaded materials
Course-based filtering
Bookmark resources
  

## Architecture
This project follows Domain Driven Design (DDD):
** Layers**
  .Presentation Layer
    .Flutter UI
    .Screens & Widgets
  .Application Layer
    .Use cases (business logic execution)
  .Domain Layer
      Entities:
        User
        Resource
        Request
  .Infrastructure Layer
    .REST API services
    .Local database (offline caching)
    ** system Architecture **
    Flutter Mobile App
       ↓
  REST API Backend
       ↓
PostgreSQL Database

  ## API end points
- ** Authentication**
    .POST /auth/signup
    .POST /auth/login
    .DELETE /auth/delete
- ** Resources**
    .GET /resources
    .POST /resources
    .PUT /resources/{id}
    .DELETE /resources/{id}
- ** Requests**
    .GET /requests
    .POST /requests
    .PUT /requests/{id}
    .DELETE /requests/{id}
## Domain Model
**User**
  .id
  .name
  .email
  .role
**Resource**
  .id
  .title
  .courseCode
  .description
  .fileUrl
  .uploadedBy
  .uploadDate
**Request**
  .id
  .courseCode
  .description
  .requestedBy
  .status
## Technology Stack
- Frontend
  .Flutter
  .Dart
- Backend
  .Node.js (REST API)
- Database
  .PostgreSQL (Main database)
  .SQLite (Offline storage)
-Authentication
  .JWT (JSON Web Tokens)
## Requirements
- Functional Requirements
  .Authentication & Authorization
  .Two business features with CRUD
  .REST API backend
  .Offline capability
-Non-Functional Requirements
  .High performance (fast search & loading)
  .Secure authentication (hashed passwords, JWT)
  .Scalable architecture (DDD)
  .Reliable data synchronization
  .User-friendly UI
-this of our project design is ........
  .No e-commerce features
  .No chat system
  .No social media features
  .No Firebase / Firestore
  .No cloud hosting (runs locally)
  .No payment integration

## Team Members

| No. | Name | Student ID | Role |
| :--- | :--- | :--- | :--- |
| 1 | Marta Tegegne | UGR/4457/16 | Project Developer |
| 2 | Ebise Tekle | UGR/9482/16 | Project Developer |
| 3 | Mufarihat Tadesse | UGR/9735/16 | Project Developer |
| 4 | [Name Here] | [ID Here] | Project Developer |
| 5 | [Name Here] | [ID Here] | Project Developer |


