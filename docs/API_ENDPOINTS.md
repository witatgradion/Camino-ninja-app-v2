# Camino Ninja Flutter - Network API Endpoints

> All backend API calls used by the app, including REST (JSON) and Protocol Buffer variants.

---

## Table of Contents

- [Overview](#overview)
- [Authentication](#authentication)
- [Data Sync](#data-sync)
- [Routes](#routes)
- [Route Points](#route-points)
- [Alternative Route Points](#alternative-route-points)
- [Cities](#cities)
- [Albergues (Accommodations)](#albergues-accommodations)
- [Albergue User Images](#albergue-user-images)
- [Albergue Reviews & Ratings](#albergue-reviews--ratings)
- [Albergue Feedback](#albergue-feedback)
- [Missing Albergue Reports](#missing-albergue-reports)
- [Bug Reports](#bug-reports)
- [Endpoint Summary](#endpoint-summary)

---

## Overview

### Base URLs

| Flavor | Base URL |
|--------|----------|
| Development | `http://ec2-3-67-133-98.eu-central-1.compute.amazonaws.com:8080` |
| Staging | `http://ec2-3-67-133-98.eu-central-1.compute.amazonaws.com:8080` |
| Production | `https://prod.caminoninja.com` |

### API Versions

- **v1** (`/api/v1/...`) — JSON request/response
- **v2** (`/api/v2/...`) — Protocol Buffers (binary). Requests include `Accept: application/x-protobuf` header and expect `ResponseType: bytes`.

The app defaults to **v2 (Protobuf)** for all data-fetching endpoints to reduce bandwidth. Write operations (uploads, submissions) use **v1 (JSON)** with `multipart/form-data`.

### Common Headers

| Header | Value | Notes |
|--------|-------|-------|
| `x-firebase-appcheck` | Firebase App Check token | Included on all requests |
| `Authorization` | `Bearer {accessToken}` | Included on authenticated requests |
| `Accept` | `application/x-protobuf` | v2 endpoints only |

### Error Handling

All `NetworkService` methods return `ApiResult<T>`:
- `ApiSuccess<T>` — successful response with typed data
- `ApiFailure<Exception>` — failed response with error details

---

## Authentication

### POST `/api/v1/mobile_login`

Login with an OAuth provider token.

| Field | Details |
|-------|---------|
| **Version** | v1 only |
| **Content-Type** | `application/json` |
| **Used by** | `Repository.login()` |

**Request Body** (`LoginRequest`):

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `token` | String | No | OAuth token from provider |
| `login_type` | String | No | Provider type (e.g., `google`, `apple`) |
| `name` | String | No | User display name |

**Response** (`LoginResponse`):

| Field | Type | Description |
|-------|------|-------------|
| `access_token` | String | JWT access token |
| `refresh_token` | String | JWT refresh token |
| `access_token_expires_in` | int | Access token TTL (seconds) |
| `refresh_token_expires_in` | int | Refresh token TTL (seconds) |
| `user` | UserResponse | User profile object |

---

### POST `/api/v1/refresh`

Refresh an expired access token.

| Field | Details |
|-------|---------|
| **Version** | v1 only |
| **Auth Header** | `Authorization: Bearer {refreshToken}` |
| **Used by** | `Repository.refreshToken()`, `NetworkInterceptor` (automatic) |

**Response** (`LoginResponse`): Same as login response.

---

## Data Sync

### GET `/api/v1/latest_updated` | GET `/api/v2/latest_updated`

Check server-side timestamps to determine which local data needs refreshing.

| Field | Details |
|-------|---------|
| **Versions** | v1 (JSON), v2 (Protobuf) |
| **Used by** | `Repository.getLatestDataUpdate()` |

**Response** (`LatestDataUpdateResponse` / Protobuf `LatestUpdated`):

| Field | Type | Description |
|-------|------|-------------|
| `routes_updated_at` | DateTime | Last route data change |
| `route_points_updated_at` | DateTime | Last route points change |
| `alt_route_points_updated_at` | DateTime | Last alternative route points change |
| `albergues_updated_at` | DateTime | Last albergue data change |
| `cities_updated_at` | DateTime | Last city data change |
| `albergue_user_images_updated_at` | DateTime | Last user image change |
| `albergue_user_reviews_updated_at` | DateTime | Last user review change |

The app compares these timestamps against locally cached values and only re-downloads data types that have changed.

---

## Routes

### GET `/api/v1/routes` | GET `/api/v2/routes`

Fetch all available Camino pilgrimage routes.

| Field | Details |
|-------|---------|
| **Versions** | v1 (JSON), v2 (Protobuf) |
| **Used by** | `Repository.fetchAndSaveRoutes()` |

**Response** (`List<RouteResponse>` / Protobuf `RouteListResponse`):

| Field | Type | Description |
|-------|------|-------------|
| `id` | int | Route ID |
| `order_key` | int | Display order |
| `route_name` | String | Route name |
| `route_sub_name` | String | Route subtitle |
| `legend_color` | String | Hex color for map display |
| `status` | bool | Active status |
| `created_at` | String | Timestamp |
| `updated_at` | String | Timestamp |
| `deleted_at` | String | Soft delete timestamp |

---

## Route Points

### GET `/api/v1/route_points` | GET `/api/v2/route_points`

Fetch GPS waypoints that define route polylines on the map.

| Field | Details |
|-------|---------|
| **Versions** | v1 (JSON), v2 (Protobuf) |
| **Used by** | `Repository.fetchAndSaveRoutePoints()` |

**Response** (`List<RoutePointResponse>` / Protobuf `RoutePointsListResponse`):

| Field | Type | Description |
|-------|------|-------------|
| `id` | int | Point ID |
| `route_id` | int | Parent route |
| `order_key` | int | Sequence order |
| `elevation` | double | Elevation in meters |
| `geo_point` | GeoPoint | Latitude and longitude |

---

## Alternative Route Points

### GET `/api/v1/alt_route_points` | GET `/api/v2/alt_route_points`

Fetch alternative route variants (different paths on the same route).

| Field | Details |
|-------|---------|
| **Versions** | v1 (JSON), v2 (Protobuf) |
| **Used by** | `Repository.fetchAndSaveAltRoutePoints()` |

**Response** (`List<AltRoutePointResponse>` / Protobuf `AltRoutePointsListResponse`):

| Field | Type | Description |
|-------|------|-------------|
| `id` | int | Alt route ID |
| `order_key` | int | Display order |
| `route_id` | int | Parent route |
| `color` | String | Hex color for map line |
| `dotted` | bool | Dotted vs solid line style |
| `alt_route_points_values` | List | GPS points with `geo_point` and `order_key` |

---

## Cities

### GET `/api/v1/cities` | GET `/api/v2/cities`

Fetch all cities along Camino routes with amenity information.

| Field | Details |
|-------|---------|
| **Versions** | v1 (JSON), v2 (Protobuf) |
| **Used by** | `Repository.fetchAndSaveCities()` |

**Response** (`List<CityResponse>` / Protobuf `CityListResponse`):

| Field | Type | Description |
|-------|------|-------------|
| `id` | int | City ID |
| `name` | String | City name |
| `slug` | String | URL-safe identifier |
| `km` | int | Distance marker (km) |
| `geo_point` | GeoPoint | Latitude and longitude |
| `country` | String | Country name |
| `region` | String | Region name |
| `province` | String | Province name |
| `etape_city` | bool | Official rest stop |
| `share_url` | String | Shareable link |
| `routes` | List | Routes passing through this city |
| `route_points` | List | Route points within this city |

**City Service Flags** (all `bool`):

| Field | Description |
|-------|-------------|
| `has_atm` | ATM available |
| `has_bar_cafe` | Bar or cafe |
| `has_restaurant` | Restaurant |
| `has_shop` | Shop/store |
| `has_med_clinic` | Medical clinic |
| `has_pharmacy` | Pharmacy |
| `has_fountain` | Water fountain |
| `has_post_office` | Post office |
| `has_bus_station` | Bus station |
| `has_train_station` | Train station |
| `has_tobacco_store` | Tobacco store |
| `has_airport` | Airport |

---

## Albergues (Accommodations)

### GET `/api/v1/albergues` | GET `/api/v2/albergues`

Fetch all accommodations with full nested detail.

| Field | Details |
|-------|---------|
| **Versions** | v1 (JSON), v2 (Protobuf) |
| **Used by** | `Repository.fetchAndSaveAlbergues()` |

**Response** (`List<AlbergueResponse>` / Protobuf `AlbergueListResponse`):

**Basic Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | int | Albergue ID |
| `name` | String | Albergue name |
| `slug` | String | URL-safe identifier |
| `order_key` | int | Display order |
| `status` | int | Active status |
| `is_municipal` | bool | Municipal albergue |
| `is_albergue` | bool | Is an albergue (vs hotel, etc.) |
| `city_id` | int | Parent city |
| `city_name` | String | City name |
| `geo_point` | GeoPoint | Latitude and longitude |
| `address` | String | Street address |
| `postal_code` | String | Postal code |
| `province` | String | Province |
| `region` | String | Region |
| `country` | String | Country |
| `web` | String | Website URL |
| `share_url` | String | Shareable link |
| `places_in_dormitory` | int | Bed capacity |
| `number_of_dormitories` | int | Number of dorms |
| `dist_costa` | double | Distance from costa variant |
| `dist_litoral` | double | Distance from litoral variant |

**Booking Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `booking_com_url` | String | Booking.com listing URL |
| `reserver_url` | String | Direct reservation URL |
| `booking_price` | double | Price from Booking.com |
| `booking_price_updated_at` | String | When booking price was last fetched |

**Nested Objects:**

| Object | Type | Key Fields |
|--------|------|------------|
| `facilities` | AlbergueFacilities | 40+ boolean flags (kitchen, WiFi, meals, laundry, etc.) |
| `operating_hours` | AlbergueOperatingHours | Check-in/out times, open season, exclusion periods |
| `prices` | AlberguePrices | Price ranges for dormitory, single, double, triple, quad, shared, apartment |
| `reviews` | AlbergueReviews | Google rating (`g_rating`), Booking.com score (`b_review_score`) |
| `social_media` | AlbergueSocialMedia | Facebook URL/ID, Instagram handle, Messenger |
| `emails` | List\<AlbergueEmail\> | Email addresses |
| `phones` | List\<AlberguePhone\> | Phone numbers with `whatsapp`, `signal`, `private` flags |
| `images` | List\<AlbergueImage\> | File name, title, type, width, height |
| `wifis` | List\<AlbergueWifi\> | WiFi name and URL |

---

## Albergue User Images

### GET `/api/v1/albergues/user_images` | GET `/api/v2/albergues/user_images`

Fetch all user-uploaded photos across all albergues.

| Field | Details |
|-------|---------|
| **Versions** | v1 (JSON), v2 (Protobuf) |
| **Used by** | `Repository.fetchAndSaveAlbergueUserImages()` |

**Response** (`List<AlbergueImageResponse>` / Protobuf `AlbergueUserImagesListResponse`):

| Field | Type | Description |
|-------|------|-------------|
| `id` | int | Image ID |
| `albergue_id` | int | Parent albergue |
| `file_key` | String | Cloud storage key |
| `status` | bool | Approved status |
| `created_at` | String | Upload timestamp |
| `updated_at` | String | Timestamp |
| `deleted_at` | String | Soft delete timestamp |

---

### PUT `/api/v1/albergues/{id}/user_images`

Upload photos to a specific albergue.

| Field | Details |
|-------|---------|
| **Version** | v1 only |
| **Content-Type** | `multipart/form-data` |
| **Auth** | Required |
| **Used by** | `Repository.uploadAlbergueImage()` |

**Path Parameters:**

| Param | Type | Description |
|-------|------|-------------|
| `id` | int | Albergue ID |

**Form Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `images` | List\<File\> | Yes | JPEG image files |

---

## Albergue Reviews & Ratings

### GET `/api/v1/albergues/{id}/user_reviews` | GET `/api/v2/albergues/{id}/user_reviews`

Fetch paginated user reviews for a specific albergue.

| Field | Details |
|-------|---------|
| **Versions** | v1 (JSON), v2 (Protobuf) |
| **Used by** | `Repository.getAlbergueReviews()` |

**Path Parameters:**

| Param | Type | Description |
|-------|------|-------------|
| `id` | int | Albergue ID |

**Query Parameters:**

| Param | Type | Description |
|-------|------|-------------|
| `page` | int | Page number |
| `limit` | int | Items per page |

**Response** (`AlbergueReviewResponse` / Protobuf `AlbergueUserReviewsByAlbergueId`):

| Field | Type | Description |
|-------|------|-------------|
| `total` | int | Total review count |
| `albergue_user_reviews` | List | Review objects |

**Each review contains:**

| Field | Type | Description |
|-------|------|-------------|
| `albergue_id` | int | Parent albergue |
| `status` | bool | Approved status |
| `name` | String | Reviewer name |
| `email` | String | Reviewer email |
| `user_comment` | String | Review text |
| `user_rating` | double | Star rating |
| `images` | List | Attached image objects |
| `created_at` | String | Submission timestamp |
| `updated_at` | String | Timestamp |

---

### PUT `/api/v1/albergues/{id}/user_reviews`

Submit a review for a specific albergue.

| Field | Details |
|-------|---------|
| **Version** | v1 only |
| **Content-Type** | `multipart/form-data` |
| **Auth** | Required |
| **Used by** | `Repository.createAlbergueReview()` |

**Path Parameters:**

| Param | Type | Description |
|-------|------|-------------|
| `id` | int | Albergue ID |

**Form Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `user_rating` | int | Yes | Star rating (1-5) |
| `user_comment` | String | Yes | Review text |
| `images` | List\<File\> | No | JPEG photos |
| `email` | String | No | Reviewer email |
| `name` | String | No | Reviewer name |

---

### GET `/api/v1/albergues/user_ratings` | GET `/api/v2/albergues/user_ratings`

Fetch aggregated ratings for all albergues.

| Field | Details |
|-------|---------|
| **Versions** | v1 (JSON), v2 (Protobuf) |
| **Used by** | `Repository.fetchAndSaveAlberguesRating()` |

**Response** (`List<AlbergueRatingResponse>` / Protobuf `AlbergueUserRatingsListResponse`):

| Field | Type | Description |
|-------|------|-------------|
| `albergue_id` | int | Albergue ID |
| `rating` | float | Average rating |
| `total_approved_reviews` | int | Number of approved reviews |

---

### GET `/api/v2/albergues/{id}/user_ratings`

Fetch rating for a single albergue.

| Field | Details |
|-------|---------|
| **Version** | v2 (Protobuf) only |
| **Used by** | `Repository.fetchAndSaveAlbergueRating()` |

**Path Parameters:**

| Param | Type | Description |
|-------|------|-------------|
| `id` | int | Albergue ID |

**Response** (Protobuf `AlbergueUserRatings`):

| Field | Type | Description |
|-------|------|-------------|
| `albergue_id` | int | Albergue ID |
| `rating` | float | Average rating |
| `total_approved_reviews` | int | Number of approved reviews |

---

## Albergue Feedback

### PUT `/api/v1/albergues/{id}/user_feedbacks`

Submit general feedback about a specific albergue.

| Field | Details |
|-------|---------|
| **Version** | v1 only |
| **Content-Type** | `multipart/form-data` |
| **Auth** | Required |
| **Used by** | `Repository.createAlbergueFeedback()` |

**Path Parameters:**

| Param | Type | Description |
|-------|------|-------------|
| `id` | int | Albergue ID |

**Form Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `feedback` | String | Yes | Feedback text |
| `images` | List\<File\> | No | JPEG photos |
| `email` | String | No | Submitter email |
| `name` | String | No | Submitter name |

---

## Missing Albergue Reports

### POST `/api/v1/missing_albergues`

Report an accommodation that is not yet in the database.

| Field | Details |
|-------|---------|
| **Version** | v1 only |
| **Content-Type** | `multipart/form-data` |
| **Used by** | `Repository.reportMissingAlbergue()` |

**Form Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `city_id` | int | Yes | City where the albergue is located |
| `report_details` | String | Yes | Description of the missing albergue |
| `images` | List\<File\> | No | JPEG photos |
| `lon` | double | No | Longitude |
| `lat` | double | No | Latitude |
| `email` | String | No | Reporter email |
| `name` | String | No | Reporter name |
| `address` | String | No | Albergue address |

---

## Bug Reports

### POST `/api/v1/bug_reports`

Submit a bug report (triggered by shake-to-report or manually).

| Field | Details |
|-------|---------|
| **Version** | v1 only |
| **Content-Type** | `multipart/form-data` |
| **Used by** | `Repository.createBugReport()` |

**Form Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `text` | String | Yes | Bug description |
| `images` | List\<File\> | No | JPEG screenshots |
| `email` | String | No | Reporter email |

---

## Endpoint Summary

### By Category

| Category | Endpoints | Methods |
|----------|-----------|---------|
| Authentication | 2 | POST |
| Data Sync | 1 | GET |
| Routes | 1 | GET |
| Route Points | 1 | GET |
| Alt Route Points | 1 | GET |
| Cities | 1 | GET |
| Albergues | 1 | GET |
| Albergue User Images | 2 | GET, PUT |
| Albergue Reviews | 2 | GET, PUT |
| Albergue Ratings | 2 | GET |
| Albergue Feedback | 1 | PUT |
| Missing Albergue Reports | 1 | POST |
| Bug Reports | 1 | POST |
| **Total** | **17** | |

### By API Version

| Version | Count | Usage |
|---------|-------|-------|
| v1 only | 8 | Auth, uploads, submissions |
| v2 only | 1 | Single albergue rating |
| Both v1 and v2 | 8 | All data-fetching endpoints |

### By HTTP Method

| Method | Count | Usage |
|--------|-------|-------|
| GET | 11 | Data fetching |
| POST | 3 | Auth, bug reports, missing albergue reports |
| PUT | 3 | Image uploads, reviews, feedback |

### Protocol Buffer Definitions

Proto files are located at `packages/remote_data/proto/`:

| File | Messages |
|------|----------|
| `common.proto` | `GeoPoint` |
| `route.proto` | `Route`, `RouteListResponse` |
| `route_points.proto` | `RoutePoints`, `RoutePointsListResponse` |
| `alt_route_points.proto` | `AltRoutePoints`, `AltRoutePointsListResponse` |
| `city.proto` | `City`, `CityListResponse` |
| `albergue.proto` | `Albergue`, `AlbergueListResponse`, `AlbergueFacilities`, `AlbergueOperatingHours`, `AlberguePrices`, `AlbergueReviews`, `AlbergueSocialMedia`, `AlbergueEmail`, `AlberguePhone`, `AlbergueImage`, `AlbergueWifi` |
| `albergue_user_images.proto` | `AlbergueUserImages`, `AlbergueUserImagesListResponse` |
| `albergue_user_reviews.proto` | `AlbergueUserReviews`, `AlbergueUserReviewsByAlbergueId` |
| `albergue_user_ratings.proto` | `AlbergueUserRatings`, `AlbergueUserRatingsListResponse` |
| `latest_updated.proto` | `LatestUpdated` |

Generated Dart files are at `packages/remote_data/lib/src/proto/*.pb.dart`. Proto-to-JSON conversion is handled by `ProtoConverter`.

---

*Generated on 2026-02-12 from codebase analysis.*
