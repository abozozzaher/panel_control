'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "6ad7fdf0d69a46918679f1dce5ca7813",
"version.json": "a4220e8df23381dc5bda98c5840d4c6a",
"index.html": "e2fd3207ac8d9e35276f643d8b1f1ddf",
"/": "e2fd3207ac8d9e35276f643d8b1f1ddf",
"main.dart.js": "109a15ae2606299d3c22787da229647b",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"favicon.png": "6e7b2d273d3c8407585fdd40823a07bc",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "3bae9d71127f98d09766051f117b6125",
"assets/AssetManifest.json": "b5a01f941aad4709378b8eff3f53475c",
"assets/NOTICES": "f3b3658da6505143bb2f794f83df2c11",
"assets/FontManifest.json": "bf6a238ad4b6c257eae135e683cfe672",
"assets/AssetManifest.bin.json": "a555b0ccda3e64a37ea030444c301bcb",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/flutter_image_compress_web/assets/pica.min.js": "6208ed6419908c4b04382adc8a3053a2",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/country_state_city_pro/assets/state.json": "e4745737737ccbda1213e0af9839925f",
"assets/packages/country_state_city_pro/assets/city.json": "3a7a4886baa0f1d4f3dc40a72dc35885",
"assets/packages/country_state_city_pro/assets/country.json": "de2a8a8da3cce0928ec6939e49dba675",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "19891b453e76c593731d53273055d1f9",
"assets/fonts/MaterialIcons-Regular.otf": "8e52989dd6905082bec0327a169f8be8",
"assets/assets/img/placeholder.gif": "e88f546886e7e989a3a05eb62f807b12",
"assets/assets/img/add.png": "4dfe3fbccaff7a108eb4ec959f6c363c",
"assets/assets/img/deliveryFast.json": "de776386e3a05a3eb7e0f8d3558f2805",
"assets/assets/img/china.png": "00d7b6d94371a8a31bcfa9f64fd2b8b1",
"assets/assets/img/brands.png": "d85019b02f84ae1577687fae4e1d843a",
"assets/assets/img/todays_deal.png": "c798d81c6d67529ee284b9331c6a85e2",
"assets/assets/img/empty.json": "6ae9e3420ef6a5a819844f2117a7dcdc",
"assets/assets/img/tr.png": "17b6d17a7bc1d95ab7089d2c0bfd2e60",
"assets/assets/img/cart.png": "1f5f9c6f38835b6c513a9794aff6b13e",
"assets/assets/img/razorpay.png": "95a422973abee92e56cf101550a7f0f9",
"assets/assets/img/pen.png": "ea0abb1d7362361b5ecf309156d2f5f0",
"assets/assets/img/no_order4.png": "d1f404359fe474e95b0d0b8068731bae",
"assets/assets/img/no-data.json": "5274c4848df82da025b6efda2ae8bf4a",
"assets/assets/img/hi.png": "cd05e8e8048c33b669bee61cc1eb8fc8",
"assets/assets/img/favourite.png": "6da65bc721c45bfbfbb93e090bb85d99",
"assets/assets/img/brazil.png": "3fc8860c56a93364c00c45ea5c18aa73",
"assets/assets/img/ru.png": "dfe6886357bdd2fc84d4d3ff236db134",
"assets/assets/img/no_order2.png": "cd91d2be5959dd19b31a5e0f937aabd5",
"assets/assets/img/user.png": "83fe01d524ce8a513d02b85ef11c72b6",
"assets/assets/img/no_order3.png": "bddfb0ad9e04b1cc034eaa7b9386afd1",
"assets/assets/img/loading.gif": "3f899a790ab677acd5762723b7743334",
"assets/assets/img/no_order1.png": "ddf9358dd220a257d6a33f39ac736f4c",
"assets/assets/img/friend.png": "ed204df17e600d1016672c0e81809bbd",
"assets/assets/img/sign-in.json": "65d0c3ae4c33652f2d2ef7bda1bfc6ad",
"assets/assets/img/canada.png": "a4122561940e7324ca621f6f9d75050a",
"assets/assets/img/dashboard.json": "dce295afe37f8aa3eabf317980d9659b",
"assets/assets/img/not-found.json": "a0744c711ebb5b1658b65635ca3cc014",
"assets/assets/img/logo.png": "1debf7da3a849d68fd3a77465cae1e91",
"assets/assets/img/no-internet.gif": "3aa87b48d1f0bc952a35381af8e2240f",
"assets/assets/img/pay_pickup.png": "83211f71556036ba32de5bbf983ce93e",
"assets/assets/img/top_categories.png": "f390e29b08742ec060e6e190ed200595",
"assets/assets/img/twitter.png": "0251d8ee95aa6d1f3400faa3b46b4bcf",
"assets/assets/img/linkedin.png": "fd0d5546fdbdc85c76c4372a0d51f1bc",
"assets/assets/img/google-plus.png": "1d8cc4a9c9019c751098a4bf99ebdccf",
"assets/assets/img/sy.png": "85e177b41a53e134ab7ebfcf7ed5dc5c",
"assets/assets/img/spain.png": "fed7d0ce876bc8161c3b8658475c425f",
"assets/assets/img/de.png": "cc23f204eaadf5d54d2e131228fec9c0",
"assets/assets/img/web.png": "3a704f723dd54d8fc95c7fa36df27995",
"assets/assets/img/Korean.png": "4ed07bb14f25b0914dcbf5ba01bb2ec2",
"assets/assets/img/france.png": "78e9f99bc3c993c9c83615d0f3d028c4",
"assets/assets/img/top_sellers.png": "d1ba492409bd709c2a7784360a5a10f5",
"assets/assets/img/visacard.png": "4383c95d3b7c43343b1a6a1cf8cd4b2b",
"assets/assets/img/CartEmpty.png": "144d02a9bb62d08c539ac21efb9985da",
"assets/assets/img/footer.svg": "ed6bd474d30a8d750aa924a78918b1ac",
"assets/assets/img/no_order.png": "97712304230c37d92d1909dc873292e4",
"assets/assets/img/mastercard.png": "fec056c30fa325712d541018e91b20e4",
"assets/assets/img/update.json": "677b62536ab561b58af277fbb909123b",
"assets/assets/img/logo.svg": "50ac89287e374ce31bacbc5baede9bb3",
"assets/assets/img/paypal.png": "dc57a6fb1bc9c03ea0125e1c12dead9a",
"assets/assets/img/no-deal.json": "4cd3dda4cca7958c2e083b321ff52208",
"assets/assets/img/united-states-of-america.png": "e499f1fbaeb06cf2b9f6ddfd4de672b5",
"assets/assets/img/marker.png": "e9bd7f334793426a58e5f7a2aef56858",
"assets/assets/img/flash_deal.png": "bc0457f5e61c228f4fc43ba5bd3e11e2",
"assets/assets/fonts/Beiruti.ttf": "74ffd0f113ab35f493a4c1bd8826e681",
"assets/assets/fonts/Tajawal/Tajawal-ExtraBold.ttf": "066a37467c3af47d359507f7c7976071",
"assets/assets/fonts/Tajawal/Tajawal-Light.ttf": "b6f8ed4fd29cc11d562ce730712aeaae",
"assets/assets/fonts/Tajawal/Tajawal-Bold.ttf": "76f83be859d749342ba420e1bb010d6a",
"assets/assets/fonts/Tajawal/Tajawal-ExtraLight.ttf": "cce1763b8395a41d57dfdf63a2e97e62",
"assets/assets/fonts/Tajawal/Tajawal-Regular.ttf": "e3fe295c55a0cb720f766bccc5eecf63",
"assets/assets/fonts/Tajawal/Tajawal-Medium.ttf": "3358032dd0994cf4a2116f0b16f80d70",
"assets/assets/fonts/Tajawal/Tajawal-Black.ttf": "bc674767a78d2808b19a818d9742a4af",
"assets/assets/sound/ripiito.mp3": "15d30c5496a0bf69171cd43d9c83245f",
"assets/assets/sound/error-404.mp3": "f3da16101876634bc5072dfbd338b463",
"assets/assets/sound/beep.mp3": "356a3be3958e44c87463660befa65a8a",
"assets/assets/sliders/slider1.png": "681ef46b8e9d40e43f4d526fdfb8d3d8",
"assets/assets/sliders/slider3.png": "e4f28a5089ee5f819453d199d6f40e4e",
"assets/assets/sliders/slider2.png": "7f2fdc62693deda1ec3e4068798cd672",
"assets/assets/sliders/slider5.png": "6a83325150299c0ea233563bdc401f47",
"assets/assets/sliders/slider4.png": "b7ab03e95e07dd5b42bb00b47b5cc8d3",
"assets/assets/store/front_store1.jpg": "d305d8261b437fba16fe58f3b8e0f638",
"assets/assets/store/front_store2.jpg": "b8795467e8657b215015bf7747ac0730",
"assets/assets/store/front_store3.jpg": "1e1c126ca271ea4ca00bc433ce8b28bf",
"assets/assets/store/front_store7.jpg": "161d77f0fe6991094c2113a9cd01b2d9",
"assets/assets/store/front_store6.jpg": "020e9fb873dad2ca94080d2ce335ce9c",
"assets/assets/store/front_store4.jpg": "f70d732c7b590795c34f74c7f5329fb7",
"assets/assets/store/front_store5.jpg": "0205d9154d183bde4126f787cb279a95",
"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
