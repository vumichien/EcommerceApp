const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Initialize Firebase Admin SDK
// You need to add your Firebase service account key here
const serviceAccount = require('./firebase-service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Sample products data (matching your Flutter app)
const sampleProducts = [
  { id: 1, title: "NMN 10000mg Ultra", price: "¥8,800", category: "Anti-Aging" },
  { id: 2, title: "Arginine & Citrulline", price: "¥5,200", category: "Sports Nutrition" },
  { id: 3, title: "Broccoli Sprout Extract", price: "¥3,600", category: "Detox & Cleanse" },
  { id: 4, title: "Sun Protection Plus", price: "¥4,200", category: "Skin Health" },
  { id: 5, title: "Alpha-GPC Cognitive", price: "¥6,500", category: "Brain Health" },
  { id: 6, title: "Multivitamin Complete", price: "¥2,800", category: "General Health" },
];

// Routes

// Health check
app.get('/', (req, res) => {
  res.json({
    message: 'Houzou Medical Notification Server',
    status: 'running',
    timestamp: new Date().toISOString()
  });
});

// Send notification to navigate to Home
app.post('/send-home-notification', async (req, res) => {
  try {
    const { token, title, body } = req.body;

    if (!token) {
      return res.status(400).json({ error: 'FCM token is required' });
    }

    const message = {
      notification: {
        title: title || 'Welcome Back!',
        body: body || 'Check out our latest health supplements',
      },
      data: {
        type: 'home',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      token: token,
    };

    const response = await admin.messaging().send(message);
    
    res.json({
      success: true,
      messageId: response,
      message: 'Home notification sent successfully'
    });

  } catch (error) {
    console.error('Error sending home notification:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Send notification to navigate to Product Detail
app.post('/send-product-notification', async (req, res) => {
  try {
    const { token, productId, title, body } = req.body;

    if (!token) {
      return res.status(400).json({ error: 'FCM token is required' });
    }

    if (!productId) {
      return res.status(400).json({ error: 'Product ID is required' });
    }

    // Find product by ID
    const product = sampleProducts.find(p => p.id.toString() === productId.toString());
    
    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }

    const message = {
      notification: {
        title: title || `New Deal: ${product.title}`,
        body: body || `Special offer on ${product.title} - ${product.price}. Tap to view details!`,
      },
      data: {
        type: 'product_detail',
        product_id: productId.toString(),
        product_title: product.title,
        product_price: product.price,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      token: token,
    };

    const response = await admin.messaging().send(message);
    
    res.json({
      success: true,
      messageId: response,
      message: 'Product notification sent successfully',
      product: product
    });

  } catch (error) {
    console.error('Error sending product notification:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Send notification to multiple devices (topic)
app.post('/send-topic-notification', async (req, res) => {
  try {
    const { topic, title, body, type, productId } = req.body;

    if (!topic) {
      return res.status(400).json({ error: 'Topic is required' });
    }

    let data = {
      type: type || 'home',
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    };

    // Add product data if it's a product notification
    if (type === 'product_detail' && productId) {
      const product = sampleProducts.find(p => p.id.toString() === productId.toString());
      if (product) {
        data.product_id = productId.toString();
        data.product_title = product.title;
        data.product_price = product.price;
      }
    }

    const message = {
      notification: {
        title: title || 'Houzou Medical',
        body: body || 'New update available!',
      },
      data: data,
      topic: topic,
    };

    const response = await admin.messaging().send(message);
    
    res.json({
      success: true,
      messageId: response,
      message: `Topic notification sent successfully to ${topic}`
    });

  } catch (error) {
    console.error('Error sending topic notification:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Get sample products
app.get('/products', (req, res) => {
  res.json({
    success: true,
    products: sampleProducts
  });
});

// Test notification endpoint
app.post('/test-notification', async (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({ error: 'FCM token is required for testing' });
    }

    // Send a test notification to home
    const homeMessage = {
      notification: {
        title: '🏠 Test Home Notification',
        body: 'This will take you to the home screen!',
      },
      data: {
        type: 'home',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      token: token,
    };

    const homeResponse = await admin.messaging().send(homeMessage);

    // Send a test notification for product detail (random product)
    const randomProduct = sampleProducts[Math.floor(Math.random() * sampleProducts.length)];
    
    const productMessage = {
      notification: {
        title: '🛍️ Test Product Notification',
        body: `Check out ${randomProduct.title} - ${randomProduct.price}`,
      },
      data: {
        type: 'product_detail',
        product_id: randomProduct.id.toString(),
        product_title: randomProduct.title,
        product_price: randomProduct.price,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      token: token,
    };

    const productResponse = await admin.messaging().send(productMessage);

    res.json({
      success: true,
      message: 'Test notifications sent successfully',
      results: {
        home: homeResponse,
        product: productResponse,
        testedProduct: randomProduct
      }
    });

  } catch (error) {
    console.error('Error sending test notifications:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error('Server error:', error);
  res.status(500).json({
    success: false,
    error: 'Internal server error'
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Houzou Medical Notification Server running on port ${PORT}`);
  console.log(`📱 Ready to send notifications to your Flutter app!`);
  console.log(`🌐 Access at: http://localhost:${PORT}`);
});

module.exports = app; 