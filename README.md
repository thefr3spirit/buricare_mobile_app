#BuriCare
An end-to-end Flutter application for monitoring and storing premature babies’ vital signs in real time, with background operation, local caching, and Firebase synchronization.

#Description
BuriCare connects via Bluetooth to a pouch device that maintains an optimal incubator-like environment. The attached sensor measures heart rate, internal body temperature, and SpO₂, streaming data to the app. There are two user roles: medical personnel and parents—both can view real-time vitals, historical trends, and receive alerts if any value drifts outside safe ranges.

Key Features
Real-time Monitoring
Displays raw sensor readings every second in four dedicated tiles.

Historical Analytics
• Last Minute: Graph updates every second using in-memory data
• Last Hour: Plots minute-averaged data
• Last Day: Plots hourly-averaged data
• Last Month: Plots daily-averaged data

Automated Alerts
Notifies the user if heart rate, temperature, or SpO₂ leaves configurable bounds.

Data Persistence & Sync
• Raw readings (1 Hz) → /users/{uid}/rawReadings
• Minute averages → /users/{uid}/minuteAverages
• Hourly averages → /users/{uid}/hourlyAverages
• Daily averages → /users/{uid}/dailyAverages

Offline-First
Uses Hive for local caching when offline; SyncService flushes unsent data when connectivity returns.

Background Operation
On Android: Foreground service keeps the pipeline alive even when the UI is closed.
On iOS: Background fetch periodically wakes the app to record or sync data.

Architecture & Approach
1. Data Pipeline (VitalsPipeline)
Subscribes to VitalsGenerator.stream (simulated or real BLE).

Buffers per second into a 60-item list → computes minute average → writes to Firestore & feeds hourly buffer.

Buffers per minute into a 60-item list → computes hourly average → writes to Firestore & feeds daily buffer.

Buffers per hour into a 24-item list → computes daily average → writes to Firestore.

2. Repository Layer (VitalsRepository)
Centralizes Firestore writes under /users/{uid}/…, using .add() for raw and .set(docId) for aggregates keyed by timestamp.

3. Local Cache (VitalsHive & LocalCache)
VitalsHive: Hive model annotated with @HiveType/@HiveField for binary storage.

LocalCache: Static wrapper for adding, retrieving, and deleting cached readings in the cached_readings box.

4. Sync Service (SyncService)
Listens for ConnectivityResult changes via connectivity_plus. On reconnect, iterates through LocalCache.getAll(), re-writes each reading via VitalsRepository, and deletes successful entries.

5. State Management
Uses Riverpod with ProviderScope and ConsumerWidget (e.g. AuthGate) to rebuild UI based on auth state and data streams.
