# Lost Item Tracker System - Product Requirements Document (PRD)

A Flutter-based mobile application to track lost and found items, with local data storage using `shared_preferences`.

---

## 🛠 Project Setup

### Flutter Project Initialization
- [✅] Set up folders for models, screens, and utilities
- [✅] Add `shared_preferences` package to `pubspec.yaml`

### Local Storage Configuration
- [✅] Use `shared_preferences` to persist lost/found item data as JSON strings
- [✅] Create helper functions to:
    - Load items from preferences
    - Save updated item list
    - Clear specific item entries if needed

---

## 📦 Core Features - Lost/Found Items

### Add New Item
- [✅] Build a form to enter item name, type, area, date, status (lost/found), description
- [✅] Store image path (optional) if selected using image picker
- [✅] Save item data into shared preferences list

### Edit Item
- [✅] Load item data from shared preferences
- [✅] Allow user to modify and re-save the item
- [✅] Overwrite the specific entry in the list in preferences

### Delete Item
- [✅] Implement delete functionality by index or unique ID
- [✅] Update the stored list in shared preferences
- [✅] Confirm deletion before proceeding

### Search Items
- [ ] Implement in-memory search and filtering by item name, type, or area
- [ ] Re-render list view with filtered results
- [ ] Avoid calling backend — use locally cached shared preferences data

---

## 🎨 User Interface & UX

### Item List View
- [✅] Show all items stored in shared preferences
- [✅] Display in a card or tile with icon, title, and type badge

### Item Details View
- [ ] On tap, show full information of the selected item
- [ ] Include image, status (lost/found), area, and description

### Add/Edit Screens
- [✅] Use `TextFormField`, `Dropdown`, `DatePicker`, and `ImagePicker` widgets
- [✅] Validate required fields before saving
- [✅] After saving, update local shared preferences list

---

## 🚀 Usability & Features

### Local-Only App
- [ ] App works entirely offline
- [ ] No API calls are made
- [ ] All data persists locally via `shared_preferences`

### Easy Item Tracking
- [ ] User can open app and quickly see their tracked items
- [ ] Clearly show date added and item status

### Responsive UI
- [ ] Layout adapts to various screen sizes
- [ ] Use consistent colors/icons to indicate "Lost" vs "Found" status

---

## 🎯 Enhanced Features

### Item Categorization & Tags
- [ ] Allow users to select or create custom categories (e.g., Electronics, Clothing, Documents)
- [ ] Let users add multiple tags to items (e.g., "urgent", "school", "blue bag")
- [ ] Enable filtering/searching by tag(s)

### Mark as Recovered / Status Tracking
- [ ] Provide a toggle or button to mark an item as recovered
- [ ] Visually distinguish found vs still-missing items
- [ ] Optionally archive or hide recovered items from main list

### Reminder & Follow-up
- [ ] Allow setting a reminder date (e.g., "Check lost item again in 3 days")
- [ ] Use `flutter_local_notifications` to send a local notification when the date arrives
- [ ] Store reminder date with the item in shared preferences

### History / Activity Log
- [ ] Track actions like added, edited, deleted, or marked as found
- [ ] Save logs in shared preferences and display a timeline or activity feed

### Local Image Management
- [ ] Use `image_picker` to let users take a photo or select from gallery
- [ ] Store image file path in shared preferences
- [ ] Display thumbnail in item cards and full-size image in detail view

### Export/Import Data
- [ ] Export all items as a JSON file and save locally or share
- [ ] Allow importing a saved JSON file to restore data (merge or overwrite)
- [ ] Use file picker or sharing intent for this feature

### App Lock & Privacy
- [ ] Allow setting a PIN code to access the app
- [ ] Store the PIN securely in shared preferences
- [ ] Prompt user for PIN on app open if enabled

### Sorting & Filtering Enhancements
- [ ] Filter by date range, category, area, and tags
- [ ] Sort by newest, oldest, alphabetical, or by category/type
