# PhotoX - AI Photo Editing Mobile App

A cross-platform mobile application built with Flutter that provides AI-powered photo editing features including photo enhancement, restoration, face swap, aging effects, style transfers, and more.

## 🌟 Features

### Core AI Features
- **Improve Photo Quality** - AI-powered enhancement
- **Restore Old Photos** - Damage repair and colorization
- **Perfect Selfie Edits** - Beauty filters and skin smoothing
- **Face Swap** - Swap faces between photos
- **AI Aging Timelapse** - Age progression/regression
- **AI Baby Generator** - Predict baby appearance
- **Animate Photos** - Add motion to static images
- **HD Image Upscaling** - 4x resolution enhancement
- **Style Transfers** - Artistic transformations

### Trending Filters
- Instant Snap
- Figurine style
- Ghostface filter
- Seasonal filters (Christmas themes)

### User Features
- User authentication and profiles
- Photo gallery/library
- Before/After comparison slider
- Save and share edited photos
- Processing history

### Monetization
- Free tier with daily limits
- PRO subscription (monthly/yearly)
- Credit-based system

## 🛠 Tech Stack

### Frontend
- **Framework**: Flutter (latest stable)
- **State Management**: BLoC (flutter_bloc)
- **Key Packages**: 
  - dio (networking)
  - image_picker / image_cropper
  - cached_network_image
  - flutter_animate
  - google_fonts

### Backend
- **Runtime**: Node.js
- **Framework**: Express
- **Database**: MongoDB
- **AI**: Google Generative AI (Gemini)
- **Storage**: Firebase Storage

## 📁 Project Structure

### Flutter App
```
lib/
├── main.dart
├── app.dart
├── config/          # Routes, theme, constants
├── core/            # Error handling, network, widgets
├── data/            # Models, repositories, datasources
├── domain/          # Entities, repository interfaces, usecases
├── presentation/    # BLoC, screens, widgets
└── services/        # App services
```

### Backend
```
backend/
├── src/
│   ├── config/      # Database, Firebase config
│   ├── controllers/ # Route handlers
│   ├── middleware/  # Auth, error handling, upload
│   ├── models/      # MongoDB schemas
│   └── routes/      # API routes
├── package.json
└── server.js
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Node.js (18+)
- MongoDB
- Firebase project

### Flutter App Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Create asset directories:
```bash
mkdir -p assets/images assets/icons assets/animations assets/fonts
```

3. Run the app:
```bash
flutter run
```

### Backend Setup

1. Navigate to backend:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Create environment file:
```bash
cp .env.example .env
```

4. Configure environment variables:
```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/photox
JWT_SECRET=your-secret-key
GOOGLE_AI_API_KEY=your-google-ai-key
FIREBASE_PROJECT_ID=your-project-id
```

5. Create uploads directory:
```bash
mkdir uploads
```

6. Start the server:
```bash
npm run dev
```

## 📱 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh-token` - Refresh access token
- `GET /api/auth/profile` - Get user profile
- `PUT /api/auth/profile` - Update profile

### Photos
- `GET /api/photos` - Get user photos
- `POST /api/photos/upload` - Upload photo
- `GET /api/photos/:id` - Get photo details
- `DELETE /api/photos/:id` - Delete photo

### AI Processing
- `POST /api/ai/enhance` - Enhance photo quality
- `POST /api/ai/restore` - Restore old photo
- `POST /api/ai/face-swap` - Swap faces
- `POST /api/ai/aging` - Age progression
- `POST /api/ai/style-transfer` - Apply art style
- `POST /api/ai/apply-filter` - Apply filter
- `POST /api/ai/upscale` - HD upscale

### Subscription
- `GET /api/subscription/plans` - Get plans
- `GET /api/subscription/status` - Get status
- `POST /api/subscription/purchase` - Purchase
- `POST /api/subscription/cancel` - Cancel

## 🎨 Design System

### Colors
- Primary: Coral/Pink gradient (#FF6B6B → #FF8E53)
- Accent: Electric Cyan (#00F5D4)
- Secondary: Deep Purple (#7B2CBF)
- Pro Gold: (#FFD700)

### Typography
- Font Family: Space Grotesk

## 📄 License

This project is proprietary software.

## 👥 Contributors

- PhotoX Team





