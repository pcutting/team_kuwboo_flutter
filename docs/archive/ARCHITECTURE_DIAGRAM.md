> **DEPRECATED** — Superseded by client/MILESTONE_1_ARCHITECTURE.md. Retained for historical context.

# Kuwboo System Architecture

**Created:** January 27, 2026
**Last Updated:** January 27, 2026
**Version:** 1.0

---

## Executive Summary

Kuwboo is a multi-platform social/marketplace application with native iOS and Android mobile apps backed by AWS cloud infrastructure. The architecture follows a traditional three-tier pattern with mobile clients communicating via REST API and WebSocket connections to a Node.js backend, which interfaces with an Aurora MySQL database and various AWS services.

---

## High-Level Architecture

```mermaid
flowchart TB
    subgraph Clients ["Client Layer"]
        iOS["📱 iOS App<br/>(Swift/UIKit)"]
        Android["📱 Android App<br/>(Kotlin)"]
        Admin["🖥️ Admin Panel<br/>(React)"]
    end

    subgraph CDN ["CDN Layer (CloudFront)"]
        CF_Admin["CloudFront<br/>E1TD7B7X99R9G8<br/>Admin/Frontend"]
        CF_Media["CloudFront<br/>E3LHR54EJZW4VC<br/>Media CDN"]
    end

    subgraph API ["API Layer"]
        EC2["🖥️ EC2 t3.medium<br/>Kuwboo-api-staging<br/>35.177.230.139"]
        Socket["Socket.io<br/>Real-time Events"]
    end

    subgraph Storage ["Storage Layer (S3)"]
        S3_FE["📁 kuwboo-frontend-staging<br/>React Build"]
        S3_Media["📁 kuwboo-dev<br/>Media Files"]
        S3_Upload["📁 kuwboo-dev-new<br/>Video Uploads"]
    end

    subgraph Serverless ["Serverless Layer"]
        Lambda1["⚡ kuwboo-media-converter<br/>Triggers MediaConvert"]
        Lambda2["⚡ kuwboo-job-complete<br/>Updates DB"]
        SNS["📨 SNS Topic<br/>Job Notifications"]
    end

    subgraph Media ["Media Processing"]
        MC["🎬 AWS MediaConvert<br/>Video Transcoding"]
    end

    subgraph Database ["Database Layer"]
        Aurora[("💾 Aurora MySQL 8.0<br/>kuwboo-db-staging<br/>kuwboo_db_stag")]
    end

    subgraph External ["External Services"]
        Firebase["🔔 Firebase<br/>Push/Analytics/Crashlytics"]
        Twilio["📱 Twilio<br/>SMS/OTP"]
        SMTP["📧 SMTP<br/>Email"]
        Social["🔐 Social OAuth<br/>FB/Google/Instagram"]
    end

    iOS --> CF_Media
    Android --> CF_Media
    Admin --> CF_Admin

    iOS --> EC2
    Android --> EC2
    iOS --> Socket
    Android --> Socket

    CF_Admin --> S3_FE
    CF_Media --> S3_Media

    EC2 --> Aurora
    EC2 --> S3_Media
    EC2 --> S3_Upload
    EC2 --> Firebase
    EC2 --> Twilio
    EC2 --> SMTP
    EC2 --> Social

    Socket --> EC2

    S3_Upload -->|"S3 Event"| Lambda1
    Lambda1 --> MC
    MC -->|"Job Complete"| SNS
    SNS --> Lambda2
    Lambda2 --> Aurora
```

---

## Component Architecture

### Mobile Applications

```mermaid
flowchart LR
    subgraph iOS ["iOS App (Swift)"]
        direction TB
        iOS_UI["UIKit + Storyboards"]
        iOS_VM["ViewModels (RxSwift)"]
        iOS_Router["Router Pattern"]
        iOS_API["KuwbooAPI Client"]
        iOS_Socket["Socket.io Client"]

        iOS_UI --> iOS_VM
        iOS_VM --> iOS_Router
        iOS_VM --> iOS_API
        iOS_VM --> iOS_Socket
    end

    subgraph Android ["Android App (Kotlin)"]
        direction TB
        And_UI["Jetpack Compose / XML"]
        And_VM["ViewModels"]
        And_API["Retrofit Client"]
        And_Socket["Socket.io Client"]

        And_UI --> And_VM
        And_VM --> And_API
        And_VM --> And_Socket
    end

    iOS_API --> API
    iOS_Socket --> WS
    And_API --> API
    And_Socket --> WS

    API["REST API<br/>kuwboo-api.codiantdev.com"]
    WS["WebSocket<br/>Real-time Events"]
```

---

### Backend Architecture

```mermaid
flowchart TB
    subgraph Backend ["Node.js Backend (Express.js)"]
        direction TB

        subgraph Routes ["Route Layer"]
            R_Account["Account Routes"]
            R_Feed["Feed Routes"]
            R_Chat["Chat Routes"]
            R_Product["Product Routes"]
            R_Social["Social Routes"]
        end

        subgraph Controllers ["Controller Layer"]
            C_Account["Account Controller"]
            C_Feed["Feed Controller"]
            C_Chat["Chat Controller"]
            C_Product["Product Controller"]
            C_Social["Social Controller"]
        end

        subgraph Services ["Service Layer"]
            S_Email["Email Service"]
            S_SMS["SMS Service"]
            S_Push["Push Service"]
            S_Media["Media Service"]
        end

        subgraph Repos ["Repository Layer"]
            Repo_User["User Repository"]
            Repo_Feed["Feed Repository"]
            Repo_Chat["Chat Repository"]
            Repo_Product["Product Repository"]
        end

        subgraph Models ["Model Layer (Sequelize)"]
            M_User["User Model"]
            M_Feed["Feed Model"]
            M_Thread["Thread Model"]
            M_Product["Product Model"]
        end

        Routes --> Controllers
        Controllers --> Services
        Controllers --> Repos
        Repos --> Models
    end

    Models --> DB[("Aurora MySQL")]
    Services --> External["External APIs"]
```

---

### Data Flow Diagrams

#### User Authentication Flow

```mermaid
sequenceDiagram
    participant App as Mobile App
    participant API as Backend API
    participant Twilio as Twilio SMS
    participant DB as Aurora MySQL
    participant JWT as JWT Service

    App->>API: POST /account/send-otp {phone}
    API->>Twilio: Send OTP SMS
    Twilio-->>App: SMS with OTP
    API-->>App: 200 OK

    App->>API: POST /account/verify-otp {phone, otp}
    API->>DB: Verify OTP & Find/Create User
    DB-->>API: User Record
    API->>JWT: Generate Access + Refresh Tokens
    JWT-->>API: Tokens
    API-->>App: {accessToken, refreshToken, user}
```

---

#### Video Upload & Processing Flow

```mermaid
sequenceDiagram
    participant App as Mobile App
    participant API as Backend API
    participant S3 as S3 (kuwboo-dev-new)
    participant Lambda as Lambda (converter)
    participant MC as MediaConvert
    participant Lambda2 as Lambda (job-complete)
    participant DB as Aurora MySQL

    App->>API: POST /feed/create {metadata}
    API->>DB: Create Feed (status: pending)
    API-->>App: {feedId, uploadURL}

    App->>S3: PUT video file
    S3->>Lambda: S3 Event (ObjectCreated)
    Lambda->>MC: Create Job (mp4 transcode)
    MC-->>Lambda: Job ID

    Note over MC: Transcoding...

    MC->>Lambda2: SNS (JobComplete)
    Lambda2->>DB: UPDATE feeds SET status='active'
    Lambda2-->>MC: OK

    App->>API: GET /feed/{id}
    API->>DB: Get Feed
    API-->>App: {feed with video URL}
```

---

#### Real-time Chat Flow

```mermaid
sequenceDiagram
    participant AppA as User A App
    participant Socket as Socket.io Server
    participant API as Backend API
    participant DB as Aurora MySQL
    participant AppB as User B App

    AppA->>Socket: connect + join(userId)
    Socket-->>AppA: connected

    AppA->>Socket: chat_message {to, content, threadId}
    Socket->>API: Save Message
    API->>DB: INSERT INTO chats
    DB-->>API: OK
    Socket->>AppB: chat_message {from, content}
    Socket-->>AppA: message_sent

    AppB->>Socket: update_seen_status {messageId}
    Socket->>DB: UPDATE chat SET seen=true
    Socket->>AppA: message_seen
```

---

### Module Architecture

Kuwboo uses a **module key pattern** where shared infrastructure serves multiple feature domains.

```mermaid
flowchart TB
    subgraph Modules ["Feature Modules"]
        VM["🎬 Video Making<br/>(TikTok-like)"]
        BS["🛒 Buy & Sell<br/>(Marketplace)"]
        DT["💑 Dating<br/>(Matching)"]
        SS["👥 Social Stumble<br/>(Discovery)"]
    end

    subgraph Extended ["Extended Modules"]
        Blog["📝 Blog"]
        Notice["📋 Notice Board"]
        VIP["⭐ VIP Pages"]
        Discount["💰 Find Discount"]
        Lost["🔍 Lost & Found"]
        Missing["👤 Missing Person"]
    end

    subgraph Shared ["Shared Infrastructure"]
        Threads["💬 Threads/Chat<br/>(moduleKey filtered)"]
        Followers["👥 Followers<br/>(per-module)"]
        Notifications["🔔 Notifications"]
        Media["📸 Media Storage"]
    end

    VM --> Threads
    VM --> Followers
    VM --> Media

    BS --> Threads
    BS --> Followers
    BS --> Media

    DT --> Threads
    DT --> Followers

    SS --> Threads
    SS --> Followers
    SS --> Media

    Blog --> Threads
    Blog --> Media

    Notice --> Threads
    VIP --> Threads
    VIP --> Followers
```

---

### Database Schema Overview

```mermaid
erDiagram
    users ||--o{ feeds : creates
    users ||--o{ buy_sell_products : lists
    users ||--o{ threads : participates
    users ||--o{ user_followers : follows

    feeds ||--o{ feed_comments : has
    feeds ||--o{ feed_likes : has
    feeds ||--o{ feed_hashtags : tagged

    buy_sell_products ||--o{ bids : receives
    buy_sell_products ||--o{ product_images : has

    threads ||--o{ chats : contains
    threads }|--|| thread_participants : has

    users {
        int id PK
        string phone
        string email
        string name
        string profile_pic
        datetime created_at
    }

    feeds {
        int id PK
        int user_id FK
        string status
        string video_url
        string thumbnail_url
        enum module_key
        datetime created_at
    }

    buy_sell_products {
        int id PK
        int user_id FK
        string title
        decimal price
        enum sale_type
        datetime auction_end
    }

    threads {
        int id PK
        enum module_key
        datetime created_at
    }

    chats {
        int id PK
        int thread_id FK
        int sender_id FK
        text content
        boolean seen
        datetime created_at
    }
```

---

### AWS Infrastructure Map

```mermaid
flowchart TB
    subgraph VPC ["VPC: vpc-07cedb96f54260c43 (eu-west-2)"]
        subgraph PublicSubnet ["Public Subnet (eu-west-2a)"]
            EC2["🖥️ EC2<br/>i-00ba3186d66389f31<br/>t3.medium<br/>35.177.230.139"]
        end

        subgraph PrivateSubnet ["Private Subnet"]
            RDS["💾 Aurora MySQL<br/>db.t3.medium<br/>Port 3306"]
        end

        EC2 -->|3306| RDS
    end

    subgraph SecurityGroups ["Security Groups"]
        SG_App["kuwboo-app-sg<br/>22: SSH (restricted)<br/>80: HTTP<br/>443: HTTPS"]
        SG_DB["kuwboo-db-sg<br/>3306: MySQL (from app SG)"]
    end

    EC2 --- SG_App
    RDS --- SG_DB

    subgraph GlobalServices ["Global Services"]
        CF1["CloudFront (Frontend)"]
        CF2["CloudFront (Media)"]
        S3_1["S3: kuwboo-frontend-staging"]
        S3_2["S3: kuwboo-dev"]
        S3_3["S3: kuwboo-dev-new"]
    end

    subgraph RegionalServices ["Regional Services (eu-west-2)"]
        Lambda["Lambda Functions"]
        MC["MediaConvert"]
        SNS["SNS Topics"]
    end

    Internet["🌐 Internet"] --> CF1
    Internet --> CF2
    Internet --> EC2

    CF1 --> S3_1
    CF2 --> S3_2

    S3_3 --> Lambda
    Lambda --> MC
    MC --> SNS
    SNS --> Lambda
    Lambda --> RDS
```

---

## Technology Stack

### Backend

| Component | Technology | Version |
|-----------|------------|---------|
| Runtime | Node.js | ~14.x |
| Framework | Express.js | 4.17.1 |
| ORM | Sequelize | 5.22.0 |
| Database | MySQL | 8.0 (Aurora) |
| Real-time | Socket.io | 2.4.1 |
| Auth | Passport.js | 0.4.1 |
| Validation | Joi | 15.1.1 |
| Logging | Winston | 3.3.3 |

### iOS App

| Component | Technology | Version |
|-----------|------------|---------|
| Language | Swift | 5.0 |
| UI Framework | UIKit + Storyboards | - |
| Architecture | MVVM + Router | - |
| Reactive | RxSwift | 6.9.0 |
| Networking | URLSession | - |
| Image Loading | Kingfisher | 7.6.2 |
| Auth | GoogleSignIn | 5.0.2 |
| Push | Firebase Messaging | 11.15.0 |

### Android App

| Component | Technology | Version |
|-----------|------------|---------|
| Language | Kotlin | - |
| Networking | Retrofit | - |
| Auth | Firebase Auth | - |
| Push | FCM | - |

### AWS Services

| Service | Purpose | Configuration |
|---------|---------|---------------|
| EC2 | API Server | t3.medium |
| Aurora MySQL | Database | db.t3.medium |
| S3 | Media Storage | 3 buckets |
| CloudFront | CDN | 2 distributions |
| Lambda | Video Processing | 2 functions |
| MediaConvert | Video Transcoding | On-demand |
| SNS | Event Notifications | 1 topic |

---

## Network Architecture

### API Endpoints

| Endpoint | Domain | Purpose |
|----------|--------|---------|
| API | `kuwboo-api.codiantdev.com` | REST API |
| WebSocket | `kuwboo-api.codiantdev.com` | Real-time events |
| Admin | `kuwboo.codiantdev.com` | Admin panel |
| Media CDN | CloudFront | Media delivery |

### Ports & Protocols

| Service | Port | Protocol |
|---------|------|----------|
| API Server | 443 | HTTPS |
| API Server | 80 | HTTP (redirect) |
| WebSocket | 443 | WSS |
| MySQL | 3306 | TCP (internal only) |

---

## Security Architecture

```mermaid
flowchart TB
    subgraph Client ["Client Security"]
        App["Mobile App"]
        HTTPS["HTTPS Only"]
        JWT["JWT Tokens"]
    end

    subgraph Network ["Network Security"]
        SG["Security Groups"]
        VPC["VPC Isolation"]
        CF["CloudFront WAF"]
    end

    subgraph Application ["Application Security"]
        Auth["Passport Auth"]
        Valid["Input Validation"]
        Helmet["Helmet Headers"]
    end

    subgraph Data ["Data Security"]
        Encrypt["Encryption at Rest"]
        SSL["SSL in Transit"]
        Keychain["Keychain (iOS)"]
    end

    App --> HTTPS --> SG --> Auth --> Encrypt
    JWT --> Auth
    VPC --> SG
    CF --> SG
    Valid --> Encrypt
    Helmet --> Auth
    SSL --> Encrypt
```

---

## Deployment Architecture

### Current State (Manual)

```mermaid
flowchart LR
    Dev["👨‍💻 Developer"] -->|"SSH"| EC2["EC2 Instance"]
    Dev -->|"Xcode Archive"| TestFlight["TestFlight"]
    Dev -->|"Android Studio"| PlayStore["Play Console"]
    Dev -->|"AWS Console"| Lambda["Lambda"]
    Dev -->|"S3 Upload"| S3["S3"]
```

### Target State (CI/CD)

```mermaid
flowchart TB
    subgraph Source ["Source Control"]
        GH["GitHub Repos"]
    end

    subgraph CI ["CI/CD Pipeline"]
        GHA["GitHub Actions"]
        FL["Fastlane"]
    end

    subgraph Deploy ["Deployment Targets"]
        EC2["EC2 (Backend)"]
        TF["TestFlight"]
        GP["Google Play"]
        Lambda["Lambda"]
    end

    GH -->|"Push"| GHA
    GHA -->|"Backend"| EC2
    GHA -->|"iOS"| FL --> TF
    GHA -->|"Android"| GP
    GHA -->|"Lambda"| Lambda
```

---

## Scalability Considerations

### Current Bottlenecks

| Component | Limitation | Solution |
|-----------|------------|----------|
| EC2 | Single instance | Auto Scaling Group |
| Socket.io | In-memory sessions | Redis adapter |
| Aurora | Single-AZ | Multi-AZ deployment |
| Database | No read replicas | Add read replicas |

### Future Architecture

```mermaid
flowchart TB
    subgraph LoadBalanced ["Load Balanced"]
        ALB["Application Load Balancer"]
        EC2_1["EC2 Instance 1"]
        EC2_2["EC2 Instance 2"]
        EC2_N["EC2 Instance N"]
    end

    subgraph StateManagement ["State Management"]
        Redis["ElastiCache Redis<br/>Session Store<br/>Socket.io Adapter"]
    end

    subgraph Database ["Database (Multi-AZ)"]
        Aurora_W["Aurora Writer"]
        Aurora_R1["Aurora Reader 1"]
        Aurora_R2["Aurora Reader 2"]
    end

    Internet --> ALB
    ALB --> EC2_1
    ALB --> EC2_2
    ALB --> EC2_N

    EC2_1 --> Redis
    EC2_2 --> Redis
    EC2_N --> Redis

    EC2_1 --> Aurora_W
    EC2_1 --> Aurora_R1
    EC2_2 --> Aurora_W
    EC2_2 --> Aurora_R2
```

---

## Appendix: Resource Identifiers

### AWS Resource IDs

| Resource | ID |
|----------|-----|
| EC2 Instance | i-00ba3186d66389f31 |
| VPC | vpc-07cedb96f54260c43 |
| Aurora Cluster | kuwboo-db-staging |
| Security Group (App) | sg-0e1f7f0cbec7bb4e2 |
| Security Group (DB) | sg-00e79494db950f4d8 |
| CloudFront (Frontend) | E1TD7B7X99R9G8 |
| CloudFront (Media) | E3LHR54EJZW4VC |
| Lambda (Converter) | kuwboo-media-converter-dev |
| Lambda (Complete) | kuwboo-media-convert-on-job-complete-dev |
| SNS Topic | kuwboo-on-media-convert-job-complete |

### Domains & URLs

| Purpose | URL |
|---------|-----|
| API (Live) | https://kuwboo-api.codiantdev.com |
| Admin Panel | https://kuwboo.codiantdev.com |
| Media CDN | CloudFront distribution URL |

---

**Document Version:** 1.0
**Next Review:** March 31, 2026
