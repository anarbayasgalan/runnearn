# RunProject

This repository contains the source code for the RunProject application, consisting of a Spring Boot backend (`earn`) and an Angular frontend (`web`).

## Prerequisites

Ensure you have the following installed:

-   **Java Development Kit (JDK) 21**
-   **Node.js** (LTS version recommended) & **npm**
-   **Maven**
-   **PostgreSQL**
-   **Git**

## Getting Started

### 1. Pull the Repository

```bash
git clone <repository_url>
cd run
```

### 2. Database Setup

1.  Make sure your PostgreSQL service is running.
2.  Create a database (check `earn/src/main/resources/application.properties` for the configured name, likely `runner` or similar).
3.  (Optional) Initialize the database using `user_cred.sql` if required.

### 3. Backend Setup (earn)

Navigate to the backend directory and run the application:

```bash
cd earn
mvn clean install
mvn spring-boot:run
```

The backend server will start at `http://localhost:8080`.

### 4. Frontend Setup (web)

Navigate to the frontend directory, install dependencies, and start the development server:

```bash
cd web
npm install
npm start
```

The frontend application will be available at `http://localhost:4200`.

## Modules

-   **earn**: Spring Boot Backend
-   **web**: Angular Frontend
-   **flutter**: Mobile Application (if applicable)

## Common Issues

-   **Port Conflicts**: Ensure ports `8080` (Backend) and `4200` (Frontend) are free.
-   **Database Connection**: Verify your database credentials in `earn/src/main/resources/application.properties`.
