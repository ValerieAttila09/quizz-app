# Quiz App Backend Server

Backend API server untuk Quiz App menggunakan Dart Shelf, MongoDB Atlas, dan JWT Authentication.

## Setup MongoDB Atlas

1. Buat akun di [MongoDB Atlas](https://www.mongodb.com/cloud/atlas/register)
2. Buat cluster baru (pilih Free Tier M0)
3. Buat database user:
   - Username: `quizapp`
   - Password: (buat password yang kuat)
4. Whitelist IP address:
   - Klik "Network Access"
   - Klik "Add IP Address"
   - Pilih "Allow Access from Anywhere" (0.0.0.0/0) untuk development
5. Dapatkan connection string:
   - Klik "Connect" pada cluster
   - Pilih "Connect your application"
   - Copy connection string
   - Format: `mongodb+srv://<username>:<password>@cluster.mongodb.net/<dbname>?retryWrites=true&w=majority`

## Konfigurasi Environment

1. Copy file `.env.example` menjadi `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit file `.env` dan update dengan MongoDB connection string Anda:
   ```
   MONGODB_URI=mongodb+srv://quizapp:YOUR_PASSWORD@cluster.mongodb.net/quiz_app?retryWrites=true&w=majority
   JWT_SECRET=ganti-dengan-secret-key-yang-aman
   JWT_EXPIRY_HOURS=24
   PORT=8080
   ```

## Menjalankan Server

1. Install dependencies:
   ```bash
   dart pub get
   ```

2. Jalankan server:
   ```bash
   dart run bin/server.dart
   ```

Server akan berjalan di `http://localhost:8080`

## API Endpoints

### Public Endpoints (No Authentication Required)

#### Register User
```
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "username": "username",
  "password": "password123",
  "fullName": "Full Name"
}
```

#### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

#### Verify Token
```
GET /api/auth/verify
Authorization: Bearer <token>
```

### Protected Endpoints (Authentication Required)

Semua endpoint di bawah memerlukan header:
```
Authorization: Bearer <your-jwt-token>
```

#### Get User Profile
```
GET /api/user/profile
```

#### Update User Profile
```
PUT /api/user/profile
Content-Type: application/json

{
  "fullName": "New Name",
  "username": "newusername"
}
```

#### Submit Quiz Result
```
POST /api/quiz/submit
Content-Type: application/json

{
  "difficulty": "Easy",
  "score": 15,
  "totalQuestions": 15,
  "timeTaken": 120
}
```

#### Get Quiz History
```
GET /api/quiz/history?limit=10
```

#### Get User Stats
```
GET /api/quiz/stats
```

## Testing dengan cURL

### Register
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"testuser","password":"test123","fullName":"Test User"}'
```

### Login
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

### Get Profile (ganti TOKEN dengan token dari login)
```bash
curl http://localhost:8080/api/user/profile \
  -H "Authorization: Bearer TOKEN"
```

## Database Collections

### users
- `_id`: ObjectId
- `email`: String (unique)
- `username`: String (unique)
- `password`: String (hashed)
- `fullName`: String
- `createdAt`: DateTime
- `updatedAt`: DateTime

### quiz_history
- `_id`: ObjectId
- `userId`: ObjectId (reference to users)
- `difficulty`: String (Easy/Medium/Hard)
- `score`: int
- `totalQuestions`: int
- `timeTaken`: int (seconds)
- `completedAt`: DateTime

### high_scores
- `_id`: ObjectId
- `userId`: ObjectId (reference to users)
- `difficulty`: String (Easy/Medium/Hard)
- `highestScore`: int
- `totalQuizzes`: int
- `averageScore`: double
- `lastUpdated`: DateTime

## Security Features

- ✅ Password hashing dengan bcrypt
- ✅ JWT authentication dengan expiry
- ✅ CORS enabled untuk Flutter app
- ✅ Input validation
- ✅ Unique constraints pada email dan username
- ✅ Protected routes dengan middleware

## Troubleshooting

### Error: "Database not connected"
- Pastikan MongoDB connection string di `.env` sudah benar
- Pastikan IP address sudah di-whitelist di MongoDB Atlas

### Error: "Invalid or expired token"
- Token JWT sudah expired (default 24 jam)
- Login ulang untuk mendapatkan token baru

### Error: "Email or username already exists"
- Email atau username sudah terdaftar
- Gunakan email/username yang berbeda