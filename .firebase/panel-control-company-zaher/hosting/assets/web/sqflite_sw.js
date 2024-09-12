// sqflite_sw.js

// قم بتحميل ملف Service Worker لمكتبة sqflite_web
importScripts('https://cdn.jsdelivr.net/npm/sqflite_web@latest/dist/sqflite_web_service_worker.js');

// تشغيل التعليمات الخاصة بـ Service Worker
self.addEventListener('install', (event) => {
  console.log('[Service Worker] Installing Service Worker...');
  event.waitUntil(self.skipWaiting()); // يقفز إلى مرحلة التنشيط بدون انتظار
});

self.addEventListener('activate', (event) => {
  console.log('[Service Worker] Activating Service Worker...');
  event.waitUntil(self.clients.claim()); // يتحكم بالصفحات المفتوحة بدون انتظار
});

self.addEventListener('fetch', (event) => {
  // التعامل مع طلبات HTTP وتحديد إذا كانت تخدم من ذاكرة التخزين المؤقت أو من الشبكة
  console.log('[Service Worker] Fetching:', event.request.url);
});
