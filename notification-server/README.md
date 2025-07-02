# 🚀 Houzou Medical Notification Server

Node.js server để gửi Firebase Cloud Messaging (FCM) notifications tới Houzou Medical Flutter App.

## 📋 Tính năng

- ✅ Gửi notification điều hướng về Home screen
- ✅ Gửi notification điều hướng về Product Detail screen  
- ✅ Hỗ trợ gửi notification theo topic (nhiều thiết bị)
- ✅ Test API endpoints
- ✅ CORS enabled
- ✅ Error handling

## 🔧 Cài đặt

### 1. Clone và install dependencies

```bash
cd notification-server
npm install
```

### 2. Cấu hình Firebase

1. Tạo Firebase project tại [Firebase Console](https://console.firebase.google.com/)
2. Vào **Project Settings** > **Service Accounts**
3. Click **Generate new private key** và tải file JSON
4. Đặt tên file thành `firebase-service-account.json` trong thư mục này
5. Đảm bảo file này không được commit vào git

### 3. Chạy server

```bash
# Development mode
npm run dev

# Production mode  
npm start
```

Server sẽ chạy tại: `http://localhost:3000`

## 📡 API Endpoints

### 1. Health Check
```
GET /
```

### 2. Gửi Home Notification
```
POST /send-home-notification
Content-Type: application/json

{
  "token": "FCM_TOKEN_FROM_FLUTTER_APP",
  "title": "Welcome Back!",
  "body": "Check out our latest health supplements"
}
```

### 3. Gửi Product Detail Notification
```
POST /send-product-notification
Content-Type: application/json

{
  "token": "FCM_TOKEN_FROM_FLUTTER_APP",
  "productId": "1",
  "title": "Special Offer!",
  "body": "Limited time discount on NMN supplement"
}
```

### 4. Gửi Topic Notification
```
POST /send-topic-notification
Content-Type: application/json

{
  "topic": "all_users",
  "title": "New Products Available!",
  "body": "Check out our latest health supplements",
  "type": "home"
}
```

### 5. Test Notifications
```
POST /test-notification
Content-Type: application/json

{
  "token": "FCM_TOKEN_FROM_FLUTTER_APP"
}
```

### 6. Lấy danh sách sản phẩm
```
GET /products
```

## 🛠️ Cách sử dụng

### Lấy FCM Token từ Flutter App

1. Chạy Flutter app
2. Kiểm tra console logs để lấy FCM token
3. Copy token để sử dụng trong API calls

### Test với cURL

```bash
# Test Home notification
curl -X POST http://localhost:3000/send-home-notification \
  -H "Content-Type: application/json" \
  -d '{
    "token": "YOUR_FCM_TOKEN",
    "title": "Test Home",
    "body": "This will navigate to home screen"
  }'

# Test Product notification
curl -X POST http://localhost:3000/send-product-notification \
  -H "Content-Type: application/json" \
  -d '{
    "token": "YOUR_FCM_TOKEN",
    "productId": "1",
    "title": "Product Alert",
    "body": "Special offer on supplements!"
  }'
```

## 📱 Flutter App Integration

Flutter app sẽ tự động handle notifications và điều hướng:

- **type: "home"** → Điều hướng về Home screen
- **type: "product_detail"** → Điều hướng về Product Detail screen với product ID

## 🐛 Troubleshooting

### Firebase errors
- Đảm bảo `firebase-service-account.json` tồn tại và có quyền đúng
- Kiểm tra project ID trong Firebase console

### FCM Token invalid
- Token FCM thay đổi theo thời gian, cần lấy token mới từ app
- Đảm bảo app đã cấp quyền notification

### Network errors
- Kiểm tra CORS settings nếu gọi từ web
- Đảm bảo port 3000 không bị blocked

## 🔒 Security

⚠️ **Quan trọng**: 
- File `firebase-service-account.json` không được commit vào git
- Trong production, nên thêm authentication cho API endpoints
- Validate FCM tokens trước khi gửi notification

## 📂 Project Structure

```
notification-server/
├── server.js              # Main server file
├── package.json           # Dependencies
├── firebase-service-account.json  # Firebase credentials (not in git)
└── README.md              # This file
```

## 🚀 Deployment

### Heroku
```bash
heroku create your-app-name
heroku config:set NODE_ENV=production
git push heroku main
```

### Docker
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
``` 