/**
 * Connectify Firestore Database Seeder
 * 
 * Target project: connectify-4f06d
 * Collections populated:
 *   - users/{uid}
 *   - providers/{uid}
 *
 * Usage:
 *   node seed.js [options]
 *
 * Options:
 *   --key=<path>     Path to Firebase Service Account JSON key file
 *   --clean          Delete all existing dummy documents (isDummy: true) before seeding
 *   --clean-only     Only delete existing dummy documents without creating new ones
 */

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

// ---------------------------------------------------------------------------
// 1. Firebase Admin Initialization
// ---------------------------------------------------------------------------
const PROJECT_ID = 'connectify-4f06d';

function getServiceAccountKeyPath() {
  const argKey = process.argv.find(arg => arg.startsWith('--key='));
  if (argKey) {
    return path.resolve(argKey.split('=')[1]);
  }
  if (process.env.SERVICE_ACCOUNT_KEY) {
    return path.resolve(process.env.SERVICE_ACCOUNT_KEY);
  }
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    return path.resolve(process.env.GOOGLE_APPLICATION_CREDENTIALS);
  }

  // Common default locations
  const candidatePaths = [
    path.join(__dirname, 'serviceAccountKey.json'),
    path.join(__dirname, '..', 'serviceAccountKey.json'),
    path.join(__dirname, 'connectify-service-account.json'),
    path.join(__dirname, '..', 'connectify-service-account.json'),
  ];

  for (const p of candidatePaths) {
    if (fs.existsSync(p)) return p;
  }

  return null;
}

const keyPath = getServiceAccountKeyPath();

if (keyPath && fs.existsSync(keyPath)) {
  console.log(`[Connectify Seed] Using service account key from: ${keyPath}`);
  const serviceAccount = JSON.parse(fs.readFileSync(keyPath, 'utf8'));
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: serviceAccount.project_id || PROJECT_ID,
  });
} else {
  console.log('[Connectify Seed] No explicit service account file found. Attempting Application Default Credentials (ADC)...');
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: PROJECT_ID,
  });
}

const db = admin.firestore();

// ---------------------------------------------------------------------------
// 2. Dummy Data Definitions
// ---------------------------------------------------------------------------
const CATEGORY_DATA = {
  'Home Maintenance': {
    subServices: [
      'Electrician',
      'Carpenter',
      'Painting',
      'Plumber',
      'HVAC',
      'Pest Control',
      'Gardening',
    ],
    bios: [
      'Certified electrician and home handyman with extensive residential repair experience.',
      'Master carpenter & painter offering high-end finishing, custom furniture, and wall repairs.',
      'Plumbing and HVAC specialist dedicated to fast diagnostics and reliable long-term fixes.',
    ],
  },
  'Appliance Repair': {
    subServices: [
      'Refrigerator Repair',
      'Washing Machine',
      'Microwave & Oven Repair',
      'Dishwasher Repair',
      'AC Maintenance',
    ],
    bios: [
      'Specialist in all major kitchen appliances and cooling systems with genuine replacement parts.',
      'Quick response appliance technician with 7+ years fixing washers, dryers, and ovens.',
      'Expert diagnosis and same-day repairs for domestic refrigerators and smart appliances.',
    ],
  },
  'Technology & IT': {
    subServices: [
      'Network Setup',
      'Smart Home Installation',
      'Computer Repairs',
      'Wi-Fi Optimization',
      'Data Recovery',
    ],
    bios: [
      'Network engineer & IoT installer helping homes and small offices stay fast and secure.',
      'Hardware technician specializing in PC/Mac repairs, OS setup, and high-speed mesh networks.',
      'Smart home automation and audio-video integration expert ready to upgrade your living space.',
    ],
  },
  'Personal & Lifestyle': {
    subServices: [
      'Massage at Home',
      'Pet Care',
      'Tailoring & Alterations',
      'Personal Fitness Trainer',
      'House Sitting',
    ],
    bios: [
      'Licensed wellness therapist providing relaxing at-home therapeutic and deep tissue sessions.',
      'Passionate animal lover and pet care professional offering sitting, grooming, and walking.',
      'Custom tailor and seamstress with meticulous attention to fittings, hems, and alterations.',
    ],
  },
  'Educational & Tutoring': {
    subServices: [
      'Mathematics',
      'Physics',
      'Chemistry',
      'Biology',
      'Languages',
      'History',
      'Computer Science',
      'Drawing & Sketching',
      'Music & Performance',
    ],
    bios: [
      'Passionate STEM tutor with a background in engineering, making math and physics simple.',
      'Trilingual educator teaching English, French, and conversational skills to all age groups.',
      'Software developer & CS instructor tutoring Python, Web Development, and algorithm basics.',
    ],
  },
  'Event Support': {
    subServices: [
      'Photography & Videography',
      'Catering Services',
      'Decoration Services',
      'Sound & DJ Services',
      'Event Planning',
    ],
    bios: [
      'Professional photographer & videographer capturing memorable moments and celebrations.',
      'Experienced culinary artist providing customized catering and buffet spreads for all occasions.',
      'Event decorator and sound technician bringing themes and lighting to life seamlessly.',
    ],
  },
  'Cleaning': {
    subServices: [
      'General Cleaning',
      'Deep Cleaning',
      'Carpet & Upholstery Cleaning',
      'Window Cleaning',
      'Move-in / Move-out Cleaning',
    ],
    bios: [
      'Detail-oriented cleaning specialist offering eco-friendly deep cleaning for homes and offices.',
      'Professional move-in/out and post-renovation cleaning crew leader ensuring spotless spaces.',
      'Expert in carpet shampooing, upholstery steam cleaning, and sanitized kitchen refreshes.',
    ],
  },
};

const EXPERIENCE_LEVELS = [
  'less than 1 Year',
  '1 Year',
  '2 Year',
  '3 Year',
  '4 Year',
  '5 to 10 Year',
  '+10 Year',
];

const PROVIDER_NAMES = [
  'Ahmad Al-Mansoor',
  'Fatima Zahra',
  'Tariq Mahmoud',
  'Yousef Haddad',
  'Lina Kassem',
  'Zaid Al-Najjar',
  'Omar Suleiman',
  'Maya Darwish',
  'Hassan Qasim',
  'Noor Al-Husseini',
  'Khaled Barakat',
  'Rania Abbasi',
  'Fadi Shammas',
  'Dina Al-Halabi',
  'Rami Bitar',
  'Sami Obeidat',
  'Hiba Kanaan',
  'Murad Sweidan',
  'Salma Ghazal',
  'Kareem Nabulsi',
  'Leila Tazi',
];

const SEEKER_NAMES = [
  'Zaid Al-Amiri',
  'Mona Al-Khatib',
  'Bashar Al-Masri',
  'Dalia Jabari',
  'Hamza Al-Shami',
  'Reem Kaddoura',
  'Mustafa Al-Kilani',
  'Farah Abu-Ghazaleh',
  'Ibrahim Jaradat',
  'Yasmin Al-Bakri',
];

// ---------------------------------------------------------------------------
// 3. Helper Utilities
// ---------------------------------------------------------------------------
function randomChoice(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

function randomSubset(arr, minCount = 2, maxCount = 4) {
  const shuffled = [...arr].sort(() => 0.5 - Math.random());
  const count = Math.min(arr.length, Math.max(minCount, Math.floor(Math.random() * (maxCount - minCount + 1)) + minCount));
  return shuffled.slice(0, count);
}

function randomRating(min = 3.5, max = 5.0) {
  const val = Math.random() * (max - min) + min;
  return Math.round(val * 10) / 10;
}

function randomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function generatePhone(index) {
  const prefix = '+962 7 9';
  const suffix = (1000000 + index * 41235) % 9000000 + 1000000;
  return `${prefix}${suffix.toString().slice(0, 3)} ${suffix.toString().slice(3)}`;
}

function sanitizeEmail(name) {
  return name.toLowerCase().replace(/[^a-z0-9]/g, '.') + '@example.com';
}

function randomPastDateIso(daysAgoMax = 180) {
  const date = new Date(Date.now() - Math.floor(Math.random() * daysAgoMax * 86400000));
  return date.toISOString();
}

// ---------------------------------------------------------------------------
// 4. Idempotency Cleanup Helper
// ---------------------------------------------------------------------------
async function cleanDummyDocs() {
  console.log('[Connectify Seed] Cleaning existing dummy documents (isDummy == true)...');

  let deletedUsers = 0;
  let deletedProviders = 0;

  // Clean dummy users
  const dummyUsers = await db.collection('users').where('isDummy', '==', true).get();
  if (!dummyUsers.empty) {
    const userBatch = db.batch();
    dummyUsers.forEach(doc => userBatch.delete(doc.ref));
    await userBatch.commit();
    deletedUsers = dummyUsers.size;
  }

  // Clean dummy providers
  const dummyProviders = await db.collection('providers').where('isDummy', '==', true).get();
  if (!dummyProviders.empty) {
    const providerBatch = db.batch();
    dummyProviders.forEach(doc => providerBatch.delete(doc.ref));
    await providerBatch.commit();
    deletedProviders = dummyProviders.size;
  }

  console.log(`[Connectify Seed] Deleted ${deletedUsers} dummy users and ${deletedProviders} dummy providers.`);
}

// ---------------------------------------------------------------------------
// 5. Main Seeder Routine
// ---------------------------------------------------------------------------
async function seedDatabase() {
  const shouldClean = process.argv.includes('--clean') || process.argv.includes('--clean-only');
  const cleanOnly = process.argv.includes('--clean-only');

  if (shouldClean) {
    await cleanDummyDocs();
    if (cleanOnly) {
      console.log('[Connectify Seed] Cleanup complete. Exiting.');
      return;
    }
  }

  console.log('[Connectify Seed] Starting database seeding...');

  const batch = db.batch();
  const mainCategories = Object.keys(CATEGORY_DATA);
  let avatarCounter = 1;

  let providerCount = 0;
  let seekerCount = 0;
  const categoryStats = {};
  mainCategories.forEach(cat => (categoryStats[cat] = 0));

  // --- 5.1 Create 21 Providers (3 per category) ---
  for (let i = 0; i < PROVIDER_NAMES.length; i++) {
    const name = PROVIDER_NAMES[i];
    const categoryName = mainCategories[i % mainCategories.length];
    const categoryInfo = CATEGORY_DATA[categoryName];

    const uid = db.collection('users').doc().id;
    const userDocRef = db.collection('users').doc(uid);
    const providerDocRef = db.collection('providers').doc(uid);

    const subServices = randomSubset(categoryInfo.subServices, 2, 4);
    const experienceLevel = randomChoice(EXPERIENCE_LEVELS);
    const aboutMe = categoryInfo.bios[i % categoryInfo.bios.length];
    const rating = randomRating(3.8, 5.0);
    const ratingCount = randomInt(6, 95);
    const isAvailable = Math.random() > 0.15; // 85% available
    const imageUrl = `https://i.pravatar.cc/300?img=${avatarCounter++}`;
    const email = sanitizeEmail(name);
    const phone = generatePhone(i + 1);
    const memberSince = randomPastDateIso(200);

    // users/{uid} for provider
    batch.set(userDocRef, {
      role: 'provider',
      name: name,
      email: email,
      phone: phone,
      imageUrl: imageUrl,
      memberSince: memberSince,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isDummy: true,
    });

    // providers/{uid}
    batch.set(providerDocRef, {
      uid: uid,
      mainService: categoryName,
      subServices: subServices,
      experienceLevel: experienceLevel,
      aboutMe: aboutMe,
      rating: rating,
      ratingCount: ratingCount,
      isAvailable: isAvailable,
      isDummy: true,
    });

    providerCount++;
    categoryStats[categoryName]++;
  }

  // --- 5.2 Create 10 Seekers ---
  for (let j = 0; j < SEEKER_NAMES.length; j++) {
    const name = SEEKER_NAMES[j];
    const uid = db.collection('users').doc().id;
    const userDocRef = db.collection('users').doc(uid);

    const imageUrl = `https://i.pravatar.cc/300?img=${avatarCounter++}`;
    const email = sanitizeEmail(name);
    const phone = generatePhone(PROVIDER_NAMES.length + j + 1);
    const memberSince = randomPastDateIso(120);

    // users/{uid} for seeker (no provider doc)
    batch.set(userDocRef, {
      role: 'seeker',
      name: name,
      email: email,
      phone: phone,
      imageUrl: imageUrl,
      memberSince: memberSince,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isDummy: true,
    });

    seekerCount++;
  }

  // Commit batch
  console.log('[Connectify Seed] Committing batch write to Firestore...');
  await batch.commit();

  // --- 5.3 Print Summary ---
  console.log('\n========================================');
  console.log('       CONNECTIFY SEED SUMMARY          ');
  console.log('========================================');
  console.log(`✅ Project ID:               ${PROJECT_ID}`);
  console.log(`✅ Providers Created:        ${providerCount}`);
  console.log(`✅ Seekers Created:          ${seekerCount}`);
  console.log(`✅ Total User Documents:     ${providerCount + seekerCount}`);
  console.log(`✅ Total Provider Documents: ${providerCount}`);
  console.log(`✅ Total Documents Written:  ${(providerCount * 2) + seekerCount}`);
  console.log('\n📊 Providers per Category:');
  for (const [cat, count] of Object.entries(categoryStats)) {
    console.log(`   - ${cat.padEnd(25)}: ${count}`);
  }
  console.log('========================================');
  console.log('Seed completed successfully! 🚀\n');
}

// ---------------------------------------------------------------------------
// Run
// ---------------------------------------------------------------------------
seedDatabase().catch(err => {
  console.error('\n❌ [Connectify Seed] Error during seeding:', err);
  process.exit(1);
});
