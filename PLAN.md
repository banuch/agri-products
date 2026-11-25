# Agriculture Society — Flutter App Plan (v1)

## Requirements (agreed)
| Area | Decision |
|---|---|
| Platforms | Android + iOS (Flutter 3.47) |
| Backend | Firebase: Auth (email/password), Cloud Firestore, Storage (product photos) |
| Roles | Buyer, Seller — chosen on the "Choose Seller/Buyer?" screen, stored on the user profile |
| Seller location | **Required** 6-digit pincode at registration, validated via India Post API (`api.postalpincode.in`) → auto-fills Post office/Village, District, State. Plus a free-text address. |
| Buyer location | Pincode optional; buyers filter product lists by **pincode** or **district** |
| Contact Owner | **Phone call** (opens dialer) + **In-app enquiry** (quantity + message, seller sees it in Enquiries) |
| Seller v1 features | Add / edit / delete products (≤3 photos), seller profile page (buyers see seller's other listings) |
| Languages | **Telugu (తెలుగు) + English**. Language chosen on the very first screen with big buttons; switchable anytime from Account. Crop names stored in both languages. |
| Easy UI (low-literacy sellers) | Big buttons with **icon/picture + short text**, large fonts, number keypads for numbers, **login with mobile number + 6-digit PIN** (no email typing), crops picked from **picture tiles** (typing only for "Other"), **step-by-step Add Product** (Category → Crop → Photo → Price & Quantity → Check & Save) with +/- buttons, simple Yes/No confirmations, plain-language errors |
| Out of scope v1 | WhatsApp, GPS/distance sort, admin approval, payments/cart, chat, push notifications |

## Screens
**Common:** Language (తెలుగు/English) → Welcome → Choose Seller/Buyer → Login (Forgot PIN → call helpline) / Create account
- Seller sign-up: Name, Mobile, 6-digit PIN ×2, **Pincode → Village/District/State**, Address (optional)
- Buyer sign-up: Name, Mobile, 6-digit PIN ×2, Pincode (optional), Address (optional)

**Buyer (bottom nav: Account · Category · Search)**
- All Categories grid (Vegetables, Fruits, Grains, Pulses, Spices, Dairy & Others)
- Category product list (image, name, Rs./Kg, location) with pincode/district filter
- Search (by product name, filterable by pincode/district)
- Product detail: photo carousel, available kg, description, price, seller + location, **Call** and **Send Enquiry**
- Seller profile (details + other listings)
- Account: profile, My enquiries, Logout

**Seller (bottom nav: My Products · Enquiries · Account)**
- My Products list → Add / Edit / Delete product
- Enquiries received (buyer name, qty, message, Call buyer, mark as responded)
- Account: profile (edit address/pincode), Logout

## Firestore data
- `users/{uid}`: role, name, phone, email, pincode, postOffice, district, state, address, createdAt
- `products/{id}`: sellerId, sellerName, sellerPhone, category, name, nameLower, pricePerKg, availableKg, description, imageUrls[], pincode, district, state, createdAt
- `enquiries/{id}`: productId, productName, sellerId, buyerId, buyerName, buyerPhone, quantityKg, message, status (new/responded), createdAt
- Security rules: users edit only their own profile; only sellers create products and only the owner edits/deletes; enquiries readable by their buyer and seller only.

## Tech
`provider` (state), `firebase_*`, `image_picker`, `url_launcher`, `http`, `cached_network_image`, `shared_preferences`, `flutter_localizations`. Role-based root gate instead of a router package. System font (has Telugu, works offline). Green `#0B7A20` + gold theme per mockups (typos from mockups fixed).

## Setup you'll do once
1. Create a Firebase project; enable Email/Password auth, Firestore, Storage.
2. `dart pub global activate flutterfire_cli` then `flutterfire configure` in the project (overwrites the placeholder `lib/firebase_options.dart`).
3. Deploy `firestore.rules`, `storage.rules`, `firestore.indexes.json`.
