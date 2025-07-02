# 🔥 Firebase Notification System - Hướng dẫn Setup

Hệ thống notification hoàn chỉnh cho **Houzou Medical App** với khả năng deep linking đến Home screen hoặc Product Detail screen.

## 📊 Tổng quan Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Web Server    │    │    Firebase      │    │   Flutter App   │
│   (Node.js)     │───▶│      FCM         │───▶│  (Deep Linking) │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Luồng hoạt động:
1. **Web Server** gửi notification qua Firebase FCM
2. **Firebase FCM** delivery notification tới thiết bị
3. **Flutter App** nhận notification và thực hiện deep linking:
   - `type: "home"` → Điều hướng về Home screen
   - `type: "product_detail"` → Điều hướng về Product Detail với ID sản phẩm cụ thể

## 🚀 **BƯỚC 1: Setup Firebase Project**

### 1.1 Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Nhập tên project: `houzou-medical-app`
4. Disable Google Analytics (tùy chọn)
5. Click **"Create project"**

### 1.2 Add Android App

1. Click **"Add app"** > Android icon
2. Nhập package name: `com.example.shop_app` (từ `android/app/src/main/AndroidManifest.xml`)
3. Tải file `google-services.json`
4. Copy file vào: `android/app/google-services.json`

### 1.3 Add iOS App

1. Click **"Add app"** > iOS icon  
2. Nhập bundle ID từ: `ios/Runner/Info.plist`
3. Tải file `GoogleService-Info.plist`
4. Copy file vào: `ios/Runner/GoogleService-Info.plist`

### 1.4 Generate Service Account Key (cho Web Server)

1. Vào **Project Settings** > **Service Accounts** 
2. Click **"Generate new private key"**
3. Tải file JSON và đổi tên thành: `firebase-service-account.json`
4. Copy file vào thư mục: `notification-server/firebase-service-account.json`

⚠️ **Quan trọng**: Đừng commit file này vào git!

## 🚀 **BƯỚC 2: Setup Flutter App**

### 2.1 Cài đặt Dependencies

Đã được cập nhật trong `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
  flutter_local_notifications: ^18.0.1
  go_router: ^13.2.0
```

Chạy:
```bash
flutter pub get
```

### 2.2 Configure Android

Thêm vào `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.0.0'
}
```

Thêm vào `android/build.gradle`:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

### 2.3 Configure iOS  

Thêm vào `ios/Runner/Info.plist`:
```xml
<key>FirebaseMessagingAutoInitEnabled</key>
<true/>
```

### 2.4 Test Flutter App

```bash
# Chạy app và kiểm tra console logs để lấy FCM Token
flutter run

# Tìm log như này:
# I/flutter: FCM Token: dxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## 🚀 **BƯỚC 3: Setup Web Server**

### 3.1 Cài đặt Node.js Server

```bash
cd notification-server
npm install
```

### 3.2 Add Firebase Service Account

Copy file `firebase-service-account.json` (từ bước 1.4) vào thư mục `notification-server/`

### 3.3 Chạy Server

```bash
# Development mode
npm run dev

# Production mode  
npm start
```

Server chạy tại: `http://localhost:3000`

## 🧪 **BƯỚC 4: Test Hệ thống**

### 4.1 Lấy FCM Token

1. Chạy Flutter app: `flutter run`
2. Tìm FCM token trong console logs
3. Copy token để test

### 4.2 Test API với cURL

```bash
# Test Home Notification
curl -X POST http://localhost:3000/send-home-notification \
  -H "Content-Type: application/json" \
  -d '{
    "token": "YOUR_FCM_TOKEN_HERE",
    "title": "🏠 Test Home Navigation",
    "body": "Tap to go to Home screen!"
  }'

# Test Product Notification  
curl -X POST http://localhost:3000/send-product-notification \
  -H "Content-Type: application/json" \
  -d '{
    "token": "YOUR_FCM_TOKEN_HERE",
    "productId": "1",
    "title": "🛍️ Special Offer!",
    "body": "NMN 10000mg Ultra - Limited time discount!"
  }'

# Test cả 2 loại notifications
curl -X POST http://localhost:3000/test-notification \
  -H "Content-Type: application/json" \
  -d '{"token": "YOUR_FCM_TOKEN_HERE"}'
```

## 📱 **Test Scenarios**

### Scenario 1: Home Navigation
1. Gửi home notification từ server
2. Notification xuất hiện trên thiết bị  
3. Tap notification → App mở và điều hướng về Home tab

### Scenario 2: Product Detail Navigation
1. Gửi product notification với `productId: "1"`
2. Notification xuất hiện trên thiết bị
3. Tap notification → App mở và điều hướng về Product Detail của sản phẩm có ID = 1

### Scenario 3: App States
- **Foreground**: Hiện local notification, tap để navigate
- **Background**: Tap notification để mở app và navigate  
- **Closed**: Tap notification để mở app và navigate

---

🎉 **Chúc mừng!** Bạn đã setup thành công hệ thống notification với deep linking cho Houzou Medical App!