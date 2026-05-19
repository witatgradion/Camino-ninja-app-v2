# Localization Audit Report

**Date:** 2026-04-09 (original audit) · 2026-04-23 (post-implementation update)
**Branch:** `chore/localization-clean-up` (from `release/2.2.390`)
**File:** `lib/l10n/arb/app_en.arb`

---

## Post-Implementation Status

What actually shipped on this branch:

- **Priority 1 — executed.** 240 unused keys removed in `f0681c35`; 2 additional unused keys (`distanceKm`, `ninja`) removed in `008f4166`. Net **242 keys removed**.
- **Priority 2 — deferred.** Consolidation was investigated but not performed. When comparing the 13 candidate pairs across all locales, every pair had divergent translations in at least one locale (e.g., `closed_536` contains the year "2021" in every locale, `april1ToOct30_556` has a completely different date range in Hungarian). Consolidating blindly would change user-visible strings. Proper consolidation requires per-pair translator review and is out of scope for this cleanup PR.
- **Croatian (hr) locale added** in `0944bfa3`. Now 19 locales.
- **`markAllAsRead` key added** by the mark-all-as-read feature merged into this branch (PR #368).

Final English key count: **834** (from 1,075 → −242 removed + 1 added).

---

## Executive Summary (original audit)

| Metric | Count |
|--------|-------|
| Total localization keys | 1,075 |
| Keys in active use | ~839 |
| **Unused keys** | **~236** |
| Keys with `_NNN` database ID suffix | 143 |
| Supported locales | 18 |

The codebase has accumulated significant localization debt. Roughly **22% of keys are unused**, and 143 keys carry database ID suffixes (`_NNN`) that create maintenance confusion. There are also numerous naming inconsistencies, duplicate-value keys, and content strings that don't belong in the localization file.

---

## Part 1: Unused Localization Keys (236)

These keys exist in `app_en.arb` (and all 18 locale files) but are **never accessed** via `AppLocalizations.of(context).keyName` or `l10n.keyName` anywhere in the Dart source. Verified against all files in `lib/`, `packages/`, and `test/`, including indirect usage through `OpenSeasonKeyMapper`, `ReservationKeyMapper`, and service extensions.

### 1.1 Accommodation-Specific Content (14 keys)

These are narrative descriptions of individual accommodations. They are **content, not UI strings**, and should live in a CMS or database, not the localization file.

| Key | Value (English) |
|-----|----------------|
| `afterCorcubion` | On the camino 1 km after Corcubion |
| `animalsRefugio` | The refugio has sheep, chickens, geese, ducks and cats... |
| `busConnections` | Bus connections to Cee, Muxia, and Santiago de Compostela. |
| `cafeInfoLunchDinner` | Information and keys to the albergue is in Cafe Cruceiro... |
| `closedAbandoned` | 500 before the village. Looked closed and abandoned... |
| `franciscanTour` | Franciscan Capuchins Brothers offer you a visit... |
| `galicianPearl` | This is a true Galician pearl... |
| `grimaldo` | Grimaldo is 650 meters out of the path... |
| `leonTapas` | Leon is famous for having free tapas... |
| `offPathLasVegas` | The hostel (and the town) are half a kilometer out of the way... |
| `offPathPlazaMayor` | 1,3 km from the path and 2,1 km from Plaza Mayor. |
| `offPathTownHall` | 1.8 km off the path and town... |
| `portoTax` | Accommodations in Porto are required to tax you a 2 EUR... |
| `swampTagus` | It is located at the foot of the swamp 600 meters off the road... |

### 1.2 Accommodation Detail Notes (39 keys)

Specific operational notes for individual accommodations — also content, not UI.

| Key | Value |
|-----|-------|
| `albergueFullReservation` | The albergue is full every day except winter... |
| `book2Weeks` | Book at least 2 weeks in advance |
| `breakfastAvailable` | Breakfast Available |
| `breakfastIncluded247` | Breakfast is included. Open 24 hours. |
| `breakfastIncluded_260` | Breakfast is included. |
| `breakfastIncluded_285` | Breakfast included |
| `breakfastIncluded_443` | Breakfast Included |
| `campingPossible` | Possibility of camping |
| `camping_281` | Camping |
| `campsite` | Campsite |
| `checkInOutSept16ToEaster` | From September 16th to Easter check-in is from 14:00... |
| `closedForSeason` | Closed for the season |
| `closedMondays_283` | Closed on Mondays |
| `closedRenovation` | Currently closed for renovation. |
| `closedTemporarily` | Closed Temporarily |
| `closedUntil2021` | Closed until 2021 |
| `closes2300LowSeason` | Closes at 23:00 in low season |
| `closes2300Summer_299` | Closes at 23:00 in summer |
| `closes2330Summer` | Closes 23:30 in summer |
| `coffee` | Coffee |
| `communityDinnerBreakfast` | Community Dinner and Breakfast is included |
| `covid19Reservation` | COVID-19: It is recommended to make reservations... |
| `dinnerRecommendation` | Dinner has my recommendation. |
| `donation` | Donation |
| `fastInternet` | Super fast optic fiber internet connection. |
| `freeBreakfastPriorStay` | Their famous breakfast is free if you stayed before. |
| `highSeasonWeekendsReservation` | In high season and weekends it is recommended to book. |
| `jesusMeditation2030` | Jesus meditation at 20:30 |
| `julyAugCheckInClose` | July and August: Check-In from 11:00, closes at 22:00 |
| `kitchenLoungeClose2000` | Kitchen and lounge closes at 20:00 |
| `lights630LaundryFree` | Lights are on at 6:30. Laundry is free. |
| `mayCloseWithoutWarning` | It can be closed without warning. |
| `musiciansWelcome` | Musicians welcome. Music & Sharing (poetry). |
| `noAmenities` | No running water, shower, electricity and wi-fi... |
| `noFoodNoKitchen` | There is no food options in the village... |
| `opens1400Winter` | Opens 14:00 in winter |
| `opens1600LowSeason` | Opens at 16:00 in low season |
| `openWeekdaysAugustDaily` | Open Monday to Friday; in August every day |
| `palletTents` | Camping with tents installed on wooden pallets... |

### 1.3 Key Collection Instructions (7 keys)

| Key | Value |
|-----|-------|
| `keysAcvmLibrary` | To check in and get keys: Monday to Friday... |
| `keysBarManga` | You can pick up the keys at the La Manga bar... |
| `keysHostelTouristOffice` | Collect the keys: In the Pilgrim's Hostel... |
| `keysPosada` | The key must be collected at C. La Cruz, 2... |
| `keysStampsTouristOffice` | Keys and stamps can be obtained at the Tourist Office... |
| `keysTownhall` | The keys are obtained at Junta da Freguesia... |
| `keysTownhallPensionista` | Keys at the Town Hall (in the morning)... |

### 1.4 Season/Status Labels (18 keys)

| Key | Value |
|-----|-------|
| `allowsReservation` | Allows reservation |
| `included` | Included |
| `july1ToSeptember24` | July 1 to September 24 |
| `opensOnDate` | Opens {opensDate} |
| `registrationHostelDinner` | Registration is at the hostel behind the albergue... |
| `rejected` | Rejected |
| `religiousCongregation` | It is not an albergue, but a hospitable reception... |
| `reservationRequired` | Reservation is required |
| `room8To10` | Room for 8-10 people |
| `salvadoranaCertificate` | In this hostel, and also in the Cathedral... |
| `saunaHammam` | They have a sauna and a hammam. |
| `specialPricesPilgrims` | Special prices for pilgrims... |
| `specialPricesShared_305` | Special prices for pilgrims in shared accommodation. |
| `specialPricesShared_306` | Special prices for pilgrims in shared accommodations. |
| `suspended` | This hostel has been suspended... |
| `tentsInGarden` | They have tents in the garden. It's 10 euros per person. |
| `verifiedOpen` | Verified Open |
| `winterCheckIn` | Check-In in winter: 11:00-13:30 and 15:00-18:00 |

### 1.5 Onboarding / Marketing Copy (19 keys)

| Key | Value |
|-----|-------|
| `anonymous` | 100% anonymous. |
| `appInfoOffline` | All the information about accommodation, routes... |
| `buenCamino` | Buen Camino! |
| `dataStorage` | All the information about accommodation, routes... |
| `easyBooking` | You can book accommodations easily through the app... |
| `easyIntuitiveApp` | The bliss of having an easy and intuitive App... |
| `freeToUse` | 100% free to use. |
| `howToNinja` | How to Ninja |
| `intro` | Intro |
| `noAds` | 100% free of ads. |
| `offlineAccomRouteInfo` | Offline information about accommodation and routes... |
| `offlineInfo` | Offline information about accommodation... |
| `outro` | Outro |
| `packListEtc` | Pack List, Send Luggage etc. |
| `ultralightInspiration` | Ultralight Pack List Inspiration |
| `usefulLinks` | Useful Links |
| `virginMonserratPrayer` | Every evening, at 6:00 p.m., pilgrims are invited... |
| `walkEatSleepRepeat` | Walk / Eat / Sleep / Repeat |
| `wifiSpanishSim` | There is WiFi, but it most likely only works... |

### 1.6 Settings / Data Descriptions (30 keys)

| Key | Value |
|-----|-------|
| `askUpdateCellular` | Ask before updating on cellular data |
| `checkForUpdates` | Check for updates |
| `checkingForUpdates` | checking for updates |
| `downloadInstallNow` | Do you want to download and install now? |
| `downloadingUpdates` | downloading updates |
| `hideMapsCellular` | Hide Maps on cellular data for cities and accommodation |
| `locateOfflineMap` | Locate on offline map |
| `lowResPhotosCellular` | If you have limited bandwidth you can choose... |
| `mapElevationPhotos` | Map, Elevation & Photos |
| `maps` | Maps |
| `mapsData` | Viewing maps does not take a lot of data... |
| `mapsMeLink` | If you use MAPS.ME for offline navigation... |
| `offlineDataSettings` | Offline & Data-Saving Settings |
| `otaExplanation` | Minor updates to accommodations, routes... |
| `otaUpdates` | Over The Air (OTA) Updates |
| `otaUpdates_473` | Minor updates to accommodations, routes... |
| `photos` | Photos |
| `photosOnlyWifi` | You can completely turn off the use of photos... |
| `photosUploaded` | Photos Uploaded |
| `shareApp` | Tell your friends about this App |
| `showAccommodation` | Show accommodation |
| `showLowResPhotos` | Only show low resolution photos on cellular data |
| `showMapsMeLink` | Show accommodation link to MAPS.ME |
| `showPhotosOnlyWifi` | Only show photos when on Wi-Fi |
| `themeLightDark` | Theme (light/dark) |
| `updates` | Updates |
| `updatesAvailable` | Updates are available. |
| `uploadInstructions` | You can upload your own pictures... |
| `uploadPhotoRequiredLoginDescription` | Please register before uploading... |
| `webSocialEmailQr` | Web, Social, Email, QR |

### 1.7 Location / Distance Labels (31 keys)

| Key | Value |
|-----|-------|
| `distDestinationCity` | Dist. destination city |
| `distanceElevation` | Distance & Elevation |
| `distanceElevationOffline` | The Distance and Elevation features works offline... |
| `distanceFromCityCenter` | I am {distance} meters from the center of {cityName}. |
| `distanceFromCity_403` | I am {distance} km from {cityName}... |
| `distanceFromRouteMeters` | {distanceMeters} m from nearest GPS point on route |
| `distanceFromRoute_391` | distance from route |
| `distanceFromRoute_474` | {distanceMeters} m from route |
| `distanceNextCity` | Dist. next city |
| `distanceOfflineAirplane` | The Distance feature works offline... |
| `distance_377` | Distance |
| `elevationGainLoss` | elevation gain/loss |
| `elevationGainLoss_436` | elev. gain/loss: {elevationGain} m/-{elevationLoss} m |
| `elevationOnline` | The Elevation feature only works online... |
| `elevation_379` | Elevation |
| `elevation_390` | elevation |
| `errorGettingCurrentLocation` | Error getting current location |
| `locationRequiredDialogMessage` | Location services are required to track... |
| `meters` | m |
| `minMaxElev` | min/max elev.: {elevationMin} m/{elevationMax} m |
| `minMaxElevation` | min/max elevation |
| `mostChosenFromStart` | Most chosen from your start |
| `myLocation` | My location |
| `notOnRouteName_404` | My Ninja App do not believe I am on {routeName}. |
| `offPath_315` | It is 2,6 km off the path |
| `offPath_329` | 0,6 km off the path |
| `offPath_330` | 2,6 km off the path |
| `offPath_331` | 0,3 km off the path |
| `searchingSatellite` | searching for satellite ... |
| `searchingSatellites` | searching for satellites |
| `searchingSatellites_383` | searching for satellites |

### 1.8 UI Labels / Actions (50 keys)

| Key | Value |
|-----|-------|
| `accommodationNameHelperMessage` | Add your email (just in case) to help us... |
| `addPhotoButton` | Add a photo |
| `allUpdated` | you are all updated |
| `back` | Back |
| `bed_plural` | beds |
| `bed_singular` | bed |
| `calculating` | calculating stuff |
| `commentErrorMessage` | Please write a comment |
| `confirmDeletePlan` | Are you sure you want to delete this plan? |
| `contactUsEmail` | Contact Us (Email) |
| `contributePhotos` | Contribute with your own photos |
| `dateFetched` | DATE FETCHED |
| `dateOfStage` | Date of stage |
| `didYouEncounterAnyIssues` | Did you encounter any issues? |
| `dormitory_plural` | dormitories |
| `dormitory_singular` | dormitory |
| `eat` | Eat |
| `exit` | Exit |
| `exiting` | Exiting |
| `facebook` | Facebook |
| `feedback` | Feedback |
| `feedbackHint` | Write your feedback here |
| `feedbackLoadingMessage` | Submitting your feedback... |
| `feedbackSuccessMessage` | Your feedback has been submitted |
| `feedbackTitle` | Feedback |
| `getDirections` | Get directions |
| `googleMaps` | Google Maps |
| `happy` | Happy |
| `incorrectInfo` | Incorrect information? |
| `informationAboutThisMissingAccommodation` | Information about this missing accommodation |
| `newAnnouncement` | New Announcement |
| `ninjaAppSays` | My Ninja App says |
| `notFoundError` | Could not find what you were looking for... |
| `notes` | Notes |
| `orUploadQr` | Or upload QR code |
| `pilgrimsChoseCity` | {count} pilgrims chose this city |
| `pricesClosingHours` | The prices and closing hours is what we... |
| `rateAlbergueLabel` | Rate this albergue |
| `ratingErrorMessage` | Please rate the albergue |
| `reloading` | reloading |
| `remainingCountMore` | And {remainingCount} more inside |
| `routeStartAndDestination` | Route, start and destination |
| `scanWithApp` | Scan this with the Camino Ninja app |
| `scanWithVersion` | Scan with Camino Ninja {version} or newer. |
| `scoreFromTravelSites` | Score from travel sites |
| `selectAll` | Select all |
| `sleep` | Sleep |
| `stageMap` | Stage Map |
| `submitButton` | Submit |
| `walk` | Walk |

### 1.9 Other Unused Keys (28 keys)

| Key | Value |
|-----|-------|
| `selectDestinationCityFirst` | Please select the city you want to go to first |
| `selectDestinationForElevation` | You have to select a destination to be able to view... |
| `selectRouteFirst` | Please select a route first |
| `selectRouteForElevation` | You have to select a route to be able to view... |
| `selectStartCityFirst` | Please select the city you will start in first |
| `selectStartConfirmation` | Should I select {cityName} as my start location? |
| `selectStartForElevation` | You have to select a start location to be able to view... |
| `shareAll` | Share all |
| `sharePhotosWithTheCommunity` | Share photos with the community |
| `sharing` | Sharing |
| `signIn` | Sign in |
| `signInDescription1` | You can still use Camino Ninja without an account... |
| `signInDescription2` | If you continue as a guest, you can't post... |
| `signInToContinue` | Please sign in again to continue. |
| `signUp` | Sign up |
| `tellFriends` | Tell your friends about this place |
| `thankYouContribution` | Thank you for your contribution!... |
| `thereIsNoAccommodationInThisCity` | There is no accommodation in this city. |
| `totalUphill` | Total uphill |
| `turnOnLocation` | You need to turn on Location to use this feature. |
| `uploadingWait` | Uploading ...please wait ... |
| `vendingMachine` | Vending Machine |
| `view` | View |
| `winterCheckRecommendation` | In winter it is recommended to check... |
| `winterHoursDisposable` | In winter they open at 14:00 and closes at 21:30. |
| `yourClosestLocation` | Your closest location |
| `yourLocation` | Your location |
| `yourSavedStaysAreHere` | Your saved stays are here |

---

## Part 2: Naming Inconsistencies

### 2.1 Database ID Suffixes (`_NNN`) — 143 keys

These keys have a numeric suffix that appears to be a backend database ID. This creates confusion, makes the key names meaningless, and results in duplicate values when the same text is needed for different database records.

**Pattern:** `{descriptiveName}_{databaseId}` (e.g., `breakfastIncluded_260`)

#### Groups with identical values (should be consolidated)

> **Note (2026-04-23):** The "Values Identical?" column below was based on comparing English values only. Cross-locale verification during implementation found that every listed pair diverges in at least one non-English locale. Consolidation has been **deferred** pending translator review — do not act on this table without that review.


| Base Key | Suffixed Duplicates | Values Identical? |
|----------|-------------------|------------------|
| `allYearClosedTuesdays` | `_544`, `_589` | Yes (both "closed on Tuesdays") |
| `allYearExceptDec24And25` | `_490`, `_653` | Yes |
| `allYearExceptNov1To7` | `_584`, `_625` | Yes |
| `breakfastIncluded` | `_260`, `_285`, `_443` | Near-identical (casing differs) |
| `distance` | `_344`, `_377` | Yes (both "Distance") |
| `elevation` | `_342` (used), `_379`, `_390` | Near-identical (casing differs) |
| `feb1ToDec19` | `_618`, `_624` | Yes |
| `february1ToNovember30` | `_141`, `_171` | Yes |
| `jan11ToDec19` | `_499`, `_572` | Yes |
| `jan21ToDec19` | `_636`, `_671` | Yes |
| `jan8ToDec21` | `_601`, `_669` | Yes |
| `march1ToDec10` | `_528`, `_672`, `_695` | Yes |
| `march1ToDec14` | `_606`, `_663` | Yes |
| `march1ToDec15` | `_649`, `_702` | Yes |
| `march15ToOctober15` | `_130`, `_208`, `_227` | Yes |
| `march15ToOctober31` | `_119`, `_180` | Yes |
| `march15ToSept30` | `_558`, `_563`, `_686` | Yes |
| `searchingSatellites` | `_383` | Yes (exact duplicate) |
| `specialPricesShared` | `_305`, `_306` | Near-identical ("accommodation" vs "accommodations") |
| `yesRecommended` | `_246`, `_249` | Yes |

**Full list of all 143 suffixed keys:** See the `OpenSeasonKeyMapper` and `ReservationKeyMapper` switch statements which map backend IDs to these keys. The suffix number matches the switch case value.

**Recommendation:** Consolidate identical-value suffixed keys into a single key. The mapper can map multiple backend IDs to the same l10n key:
```dart
// Before: 3 keys with identical value
544 => AppLocalizations.of(context).allYearClosedTuesdays_544,
589 => AppLocalizations.of(context).allYearClosedTuesdays_589,
134 => AppLocalizations.of(context).allYearClosedTuesdays,

// After: 1 key
134 || 544 || 589 => AppLocalizations.of(context).allYearClosedTuesdays,
```

### 2.2 Duplicate/Near-Duplicate Keys (Non-Suffixed)

| Keys | Values | Issue |
|------|--------|-------|
| `bed`, `beds`, `bed_singular`, `bed_plural` | "1 bed", "{n} beds", "bed", "beds" | 4 keys for singular/plural bed. Should use ICU plural syntax |
| `dormitory_singular`, `dormitory_plural` | "dormitory", "dormitories" | Same — should use ICU plural |
| `feedback`, `feedbackTitle` | "Feedback", "Feedback" | Identical values |
| `appInfoOffline`, `dataStorage` | Nearly identical long descriptions | Content overlap |
| `otaUpdates`, `otaUpdates_473`, `otaExplanation` | All describe OTA updates | Redundant |
| `distanceFromRoute`, `distanceFromRoute_391`, `distanceFromRoute_474`, `distanceFromRouteMeters` | Various "distance from route" formats | Should consolidate |
| `signIn`, `signInSignUp` | "Sign in" vs "Sign in / Sign up" | May want both, but `signIn` is unused |
| `submit`, `submitButton` | "Submit" | Duplicate intent |

### 2.3 Inconsistent Abbreviations

| Pattern | Examples | Issue |
|---------|----------|-------|
| `dist` vs `distance` | `distDestinationCity` vs `distanceFromCity` | Abbreviation inconsistency |
| `elev` vs `elevation` | `minMaxElev` vs `minMaxElevation`, `elevationGainLossRouteScreen` vs `elevationGainLoss` | Mixed |
| `Accom` vs `Accommodation` | `offlineAccomRouteInfo` vs `showAccommodation` | Mixed |

### 2.4 Inconsistent Casing in Values

| Key | Value | Issue |
|-----|-------|-------|
| `breakfastIncluded` | "Breakfast is included" | Sentence case |
| `breakfastIncluded_285` | "Breakfast included" | Title case, no verb |
| `breakfastIncluded_443` | "Breakfast Included" | Title Case |
| `elevation_342` | "Elevation" | Capitalized |
| `elevation_390` | "elevation" | Lowercase |
| `distanceFromRoute` | "Distance from route (included)" | Sentence case |
| `distanceFromRoute_391` | "distance from route" | Lowercase |
| `calculating` | "calculating stuff" | Lowercase, informal |
| `checkingForUpdates` | "checking for updates" | Lowercase |
| `allUpdated` | "you are all updated" | Lowercase |
| `dateFetched` | "DATE FETCHED" | ALL CAPS |

### 2.5 Content Strings in Localization File

**16+ keys** contain accommodation-specific narrative content (see Section 1.1). These are effectively CMS content stored as localization keys. They reference specific locations, people, phone numbers, and local details.

**Examples:**
- `grimaldo`: References "Grimaldo bar" and specific directions
- `keysPosada`: References "Maria Eugenia" and phone number "620 235 322"
- `leonTapas`: References "Barrio Humedo" and specific times
- `portoTax`: References specific tax amount "2 EUR"

**Recommendation:** These should be returned by the API as accommodation metadata, not stored as l10n keys across 18 locale files.

### 2.6 Generic/Ambiguous Key Names

Single-word keys that could conflict with Dart identifiers or are unclear in context:

| Key | Used? | Issue |
|-----|-------|-------|
| `back` | No | Too generic |
| `eat` | No | Too generic |
| `exit` | No | Too generic |
| `happy` | No | Too generic |
| `sleep` | No | Too generic |
| `walk` | No | Too generic |
| `view` | No | Conflicts with `View` widget |
| `notes` | No | Conflicts with common property names |
| `feedback` | No | Conflicts with common property names |
| `map` | Yes | Conflicts with `Map` class |
| `more` | Yes | Too generic |
| `open` | Yes | Conflicts with common method names |
| `plan` | Yes | Could be ambiguous |
| `route` | Yes | Could be ambiguous |
| `name` | Yes | Could be ambiguous |

**Recommendation for used generic keys:** No rename needed (they work), but document that these are l10n keys to avoid confusion.

### 2.7 Inconsistent Verb Forms

| Pattern | Examples |
|---------|----------|
| Imperative | `addPhoto`, `addStage`, `checkForUpdates`, `getDirections` |
| Gerund | `calculating`, `checkingForUpdates`, `downloadingUpdates`, `reloading`, `exiting` |
| Noun | `photos`, `distance`, `elevation`, `feedback` |

The mix is acceptable when gerunds are used for loading states and imperatives for button labels, but some are inconsistent:
- `checkForUpdates` (imperative) vs `checkingForUpdates` (gerund) — both appear to be the same feature
- `submit` vs `submitButton` — redundant naming

---

## Part 3: Recommendations

### Priority 1: Remove Unused Keys — **DONE** (242 keys)
Removed 240 unused keys in `f0681c35` and 2 more (`distanceKm`, `ninja`) in `008f4166`. Translation burden reduced by ~22%.

### Priority 2: Consolidate Suffixed Duplicates — **DEFERRED**
Cross-locale verification found that all 13 candidate pairs with matching base keys diverge in at least one non-English locale. Safe consolidation requires per-pair translator review. Tracked as a follow-up.

### Priority 3: Adopt ICU Plural Syntax
Replace `bed_singular`/`bed_plural` and `dormitory_singular`/`dormitory_plural` with proper ICU message syntax (already used for `nightsAtStop`):
```json
"beds": "{count, plural, =1{bed} other{beds}}"
```

### Priority 4: Standardize Naming Conventions
- Remove `_NNN` suffixes where values differ — rename to descriptive names
- Consistent abbreviations: pick `dist`/`distance` and stick to one
- Consistent casing in values: establish "Sentence case" as the standard

### Priority 5: Move Content to API
The 14+ accommodation-specific narrative strings should be served by the backend API as part of accommodation data, not hardcoded in the localization files.

---

## Appendix: Locale Files

All changes to `app_en.arb` must be mirrored across all 19 locale files (Croatian added on this branch):

| Code | Language |
|------|----------|
| `cs` | Czech |
| `da` | Danish |
| `de` | German |
| `en` | English |
| `es` | Spanish |
| `fr` | French |
| `hr` | Croatian |
| `hu` | Hungarian |
| `id` | Indonesian |
| `it` | Italian |
| `ja` | Japanese |
| `ko` | Korean |
| `nl` | Dutch |
| `pl` | Polish |
| `pt` | Portuguese |
| `ro` | Romanian |
| `ru` | Russian |
| `uk` | Ukrainian |
| `zh` | Chinese |
