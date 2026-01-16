# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TeamJ is a gathering/meeting application with a Spring Boot backend and Flutter frontend. The app supports:
- Social gatherings with join/leave functionality
- Random 1:1 chat matching via WebSocket
- Bulletin board with posts and comments
- OAuth social login (Kakao)

**Repository Structure:**
- `/backend` - Spring Boot 3.5.7 (Java 21) REST API + WebSocket server
- `/front` - Flutter 3.10+ mobile application (primary frontend)
- `/flutter_front` - Legacy/alternative Flutter implementation (deprecated)
- `/redis` - Redis configuration for caching and sessions

## Backend Commands

### Build and Run
```bash
cd backend
./gradlew build                    # Build the project
./gradlew bootRun                  # Run Spring Boot application
./gradlew test                     # Run tests (minimal coverage currently)
./gradlew clean build              # Clean and rebuild
```

### Run Specific Tests
```bash
./gradlew test --tests BackendApplicationTests
./gradlew test --tests *ServiceTest     # When service tests exist
```

### Configuration
- Application properties: `backend/src/main/resources/application.properties`
- Requires MySQL database and Redis server
- JWT secret key must be configured as environment variable or in application.properties

## Frontend Commands

### Build and Run
```bash
cd front
flutter pub get                    # Install dependencies
flutter run                        # Run on connected device/emulator
flutter run -d chrome              # Run in Chrome for web testing
flutter build apk                  # Build Android APK
flutter build ios                  # Build iOS (requires macOS)
```

### Development
```bash
flutter analyze                    # Run static analysis
flutter clean                      # Clean build artifacts
flutter pub upgrade                # Upgrade dependencies
```

### Environment Setup
- Copy `.env` file to `front/` directory with required variables:
  - `BASE_URL` - Backend API base URL (e.g., "10.0.2.2:8080" for Android emulator)
  - `WS_URL` - WebSocket base URL (e.g., "10.0.2.2:8080")

## Architecture Overview

### Backend Architecture (Spring Boot)

**Package Structure:**
```
com.teamj/
├── controller/     # REST endpoints & WebSocket @MessageMapping
├── service/        # Business logic, transactions, caching
├── repository/     # JPA data access
├── entity/         # JPA domain models
├── dto/            # Data transfer objects
├── jwt/            # JWT authentication (HTTP + WebSocket)
├── config/         # Spring configuration (Security, WebSocket, Cache)
├── exception/      # Custom exceptions
└── util/           # Utilities (S3Uploader)
```

**Key Components:**

1. **JWT Authentication (Dual Mode):**
   - `JwtTokenProvider` - Token generation/validation (1h access, 7d refresh)
   - `JwtAuthenticationFilter` - HTTP request authentication (sets SecurityContext)
   - `JwtChannelInterceptor` - WebSocket STOMP authentication (saves to session attributes)
   - **Critical:** WebSocket uses session attributes due to ThreadLocal limitations across threads
   - Controllers extract user via `@Header("simpSessionAttributes")` for WebSocket

2. **Security Configuration:**
   - Stateless sessions (no server-side session storage)
   - Public endpoints: `/api/auth/**`, `/api/signUp/**`, `/api/gathering/newList`, `/api/gathering/hotList`, `/ws/**`
   - Protected endpoints require valid JWT in `Authorization: Bearer <token>` header

3. **Caching Strategy (Redis):**
   - Hot gatherings list: 10-minute TTL
   - Participant counts: 1-minute TTL
   - Cache invalidation on join/leave via `@CacheEvict`
   - Configuration: `CacheConfig.java`

4. **WebSocket/STOMP:**
   - Endpoint: `/ws` (with SockJS fallback)
   - Simple broker: `/topic` (broadcast), `/queue` (personal)
   - Application prefix: `/app`
   - **Random chat matching:**
     - Client: SEND to `/app/match/enter` with `genderOption`
     - Server: Uses `MatchQueueManager` (Redis-backed queue)
     - Response: `/queue/match/{userIdx}` with match result

5. **Entity Relationships:**
   - `Users` ↔ `Participant` ↔ `MeetRoom` (many-to-many via composite key)
   - `Participant.id` = composite PK of `(roomIdx, usersIdx)`
   - `usersRole`: "HOST" or "GUEST"

### Frontend Architecture (Flutter)

**Directory Structure:**
```
lib/
├── main.dart                    # Entry point with ProviderScope
├── screen/                      # UI screens (feature-based)
│   ├── myPage_screen/          # Auth, profile
│   ├── gathering_screen/       # Gathering list & details
│   ├── random_chat_screen/     # Random matching
│   ├── bom_screen/             # Bulletin board
│   └── nav_bar_screen/         # Bottom navigation
├── data/
│   ├── data_source/
│   │   ├── remote/             # ApiClient, WebSocketClient
│   │   └── local/              # WazzupTokenStorage (secure storage)
│   └── repository/             # Repository pattern (API abstraction)
├── provider/                    # Riverpod state providers
├── dto/                        # Data models matching backend DTOs
├── config/                     # App configuration
├── const/                      # Constants (colors, text styles)
├── alert/                      # Dialog & toast helpers
└── theme/                      # UI theming
```

**State Management (Riverpod):**

Provider hierarchy:
```dart
// Infrastructure (singleton services)
Provider<ApiClient>
Provider<WebSocketClient>

// Repositories (data access)
Provider<GatheringRepository>
Provider<RandomMatchRepository>

// Async state (auto-loading, error handling)
AsyncNotifierProvider<GatheringHotListNotifier, List<GatheringHotlistDto>>

// UI controllers (mutable state)
ChangeNotifierProvider<RandomChatController>
```

**Key Patterns:**

1. **API Integration (`ApiClient`):**
   - Automatic JWT token refresh on 401/403
   - Token expiry validation before requests (using `jwt_decoder`)
   - Multipart support for image uploads
   - Error handling: Retry after refresh, force logout if refresh fails

2. **WebSocket Integration (`WebSocketClient`):**
   - SockJS fallback enabled
   - JWT in STOMP CONNECT headers: `{'Authorization': 'Bearer $token'}`
   - Connection lifecycle: connect() → subscribe() → send() → disconnect()
   - Auto-refresh and reconnect on 401/403 STOMP errors
   - Uses `Completer` to ensure connection before operations

3. **Repository Pattern:**
   - Abstracts API details from UI
   - Handles ApiResponse<T> unwrapping
   - Example: `GatheringRepository.fetchHotGatherings()` → calls API → returns `List<GatheringHotlistDto>`

4. **Controller Pattern (`ChangeNotifier`):**
   - Manages WebSocket lifecycle and state
   - Example: `RandomChatController` handles matching flow
   - State exposed via `notifyListeners()`, consumed via `ref.watch()`

## Critical Implementation Details

### WebSocket Authentication Flow

**Backend Challenge:** WebSocket messages run on different threads than HTTP requests, so `SecurityContextHolder.getContext()` (ThreadLocal) doesn't work in `@MessageMapping` methods.

**Solution:**
1. `JwtChannelInterceptor` intercepts STOMP CONNECT
2. Validates JWT from Authorization header
3. Saves `CustomUserDetails` to WebSocket session attributes
4. Controllers retrieve via `@Header("simpSessionAttributes") Map<String, Object> sessionAttributes`
5. Extract user: `CustomUserDetails user = (CustomUserDetails) sessionAttributes.get("user")`

### Token Refresh Flow

**Frontend (automatic):**
1. Request fails with 401/403
2. `ApiClient._refreshAccessToken()` sends refresh token to `/api/auth/reissue`
3. Backend validates refresh token → returns new access + refresh tokens
4. Frontend saves tokens, retries original request
5. If refresh fails → logout user, navigate to login screen

**WebSocket variant:**
1. STOMP ERROR frame contains 401/403
2. `WebSocketClient` catches error in `onStompError`
3. Triggers token refresh via `ApiClient`
4. Reconnects WebSocket with new token

### Random Chat Matching Algorithm

**High-level flow:**
1. User sends `/app/match/enter` with `genderOption` (e.g., "female")
2. `MatchWebSocketController` → `MatchService.enterQueue(user, genderOption)`
3. `MatchQueueManager` (Redis-backed):
   - Creates `WaitingUser` with gender preference
   - Checks queue for compatible match (opposite gender seeking user's gender)
   - If match found: Creates `MeetRoom` + `Participant` records, returns `MatchPair`
   - If no match: Adds to queue, returns waiting status
4. Server sends response to `/queue/match/{userIdx}` for both users
5. Frontend receives via subscription, updates UI

**Cancellation:**
- User sends `/app/match/cancel`
- Removes from queue, notifies cancelled status

### Caching Pattern

**Backend (Redis):**
```java
@Cacheable(value = "participantCount", key = "#roomIdxList.toString()")
public Map<Long, Integer> getParticipantCounts(List<Long> roomIdxList)

@CacheEvict(value = "participantCount", allEntries = true)
public void joinGathering(Long roomIdx, Long userIdx)
```

**Why cache participant counts?**
- Hot gatherings list needs counts for all rooms
- Querying DB for each room is expensive
- Counts change frequently (1-minute TTL balances freshness vs. load)

### Image Upload Pattern

**Backend:** `S3Uploader` utility uploads to AWS S3, returns public URL

**Frontend:**
1. `image_picker` selects image
2. `ApiClient.postMultipart()` sends multipart/form-data
3. Backend saves to S3, stores URL in entity (e.g., `roomImg`, `usersImg`)
4. Frontend displays via `cached_network_image` for performance

## Common Development Patterns

### Adding a New API Endpoint

**Backend:**
1. Create DTO in `/dto` (request + response)
2. Add method to repository interface in `/repository`
3. Implement business logic in service (`/service`) with `@Transactional`
4. Create controller endpoint in `/controller` with `@GetMapping`/`@PostMapping`
5. Return `ApiResponse<YourDto>` for consistent error handling

**Frontend:**
1. Create DTO in `lib/dto` matching backend response
2. Add method to repository (e.g., `GatheringRepository`)
3. Create/update Riverpod provider for state management
4. Call from UI via `ref.read(yourRepositoryProvider).yourMethod()`

### Adding a New Screen

1. Create directory in `lib/screen/{feature}_screen/`
2. Add controller if stateful (extends `ChangeNotifier`)
3. Create provider in `lib/provider/`
4. Build UI with `ConsumerWidget` or `ConsumerStatefulWidget`
5. Access state via `ref.watch(yourProvider)`
6. Trigger actions via `ref.read(yourProvider.notifier).yourAction()`

### Handling Transactions

Always use `@Transactional` for multi-step database operations:
```java
@Transactional
public void joinGathering(Long roomIdx, Long userIdx) {
    // Validate
    validateJoinRequest(roomIdx, userIdx);

    // Create participant
    Participant participant = createParticipant(roomIdx, userIdx);

    // Update room state if needed
    updateRoomState(roomIdx);

    // If any step fails, entire transaction rolls back
}
```

## Environment Configuration

### Backend (.env or application.properties)
- `spring.datasource.url` - MySQL connection string
- `spring.datasource.username/password` - DB credentials
- `jwt.secret` - Base64-encoded secret key for JWT signing
- `spring.redis.host/port` - Redis connection
- `cloud.aws.credentials.access-key/secret-key` - AWS S3 credentials
- `cloud.aws.s3.bucket` - S3 bucket name

### Frontend (.env)
```
BASE_URL=10.0.2.2:8080          # Android emulator localhost
WS_URL=10.0.2.2:8080            # WebSocket URL
```

**Note:** Use `localhost:8080` for iOS simulator, `10.0.2.2:8080` for Android emulator

## Testing Gaps

**Current state:** Minimal test coverage

**Backend:**
- No unit tests for services (matching algorithm, caching logic)
- No integration tests for controllers
- No WebSocket tests

**Frontend:**
- No widget tests
- No unit tests for providers/repositories
- No integration tests

**To add tests:**
- Backend: Use `@SpringBootTest` for integration tests, mock repositories for unit tests
- Frontend: Create `{file}_test.dart` in `test/` directory, use `flutter test`

## Known Architectural Notes

- **Dual Flutter directories:** `/front` is active, `/flutter_front` appears deprecated
- **Session management:** Backend is stateless (JWT-only), no session cookies
- **CORS:** Currently allows all origins (development mode) - should restrict in production
- **Error handling:** Standardized via `ApiResponse<T>` wrapper with `result`, `message`, `data` fields
- **Gender enum:** Backend uses `MALE`/`FEMALE`, frontend sends lowercase strings
- **WebSocket transport:** SockJS enabled for browser compatibility (HTTP upgrade fallback)

## User Preferences & Code Style

### User Context
- **Role:** Junior Backend/Full-stack Developer (1 year exp).
- **Communication Style:**
  - Explain complex architecture decisions simply.
  - When suggesting code, always provide the full context or file path.
  - Prefer explanations in **Korean**.

### Code Conventions
- **Comments:** Write detailed comments in Korean for complex logic (especially in WebSocket/Matching services).
- **Backend:**
  - Use Lombok (`@RequiredArgsConstructor`) for dependency injection.
  - Strict separation of concern: Controller (Req/Res) -> Service (Logic) -> Repository (DB).
- **Frontend:**
  - Follow MVVM pattern strictly.
  - Use `ref.read` for actions and `ref.watch` for UI states.

## Code Style & Conventions (User Defined)

### 1. Frontend Standards (Flutter)
- **State Management:** STRICTLY use **Riverpod 2.x** (Do NOT use GetX or old Provider).
- **Architecture:** Separate business logic into **Controllers** (ChangeNotifier/StateNotifier).
- **Legacy Ban:** Do NOT reference, read, or modify code in the `flutter_front/` directory unless explicitly instructed.

### 2. Backend Standards (Java 21 & Spring Boot 3.x)
- **Modern Syntax:** Actively utilize Java 21 features (Records, Switch Expressions, Pattern Matching, etc.).
- **Libraries:** Ensure dependencies are compatible with Spring Boot 3.x (use `jakarta.*` packages instead of `javax.*`).

### 3. Security Best Practices
- **No Hardcoding:** Never hardcode passwords, API keys, or secrets in the source code.
- **Environment Variables:** Always suggest using `${VAR}` or `.env` file loading for sensitive data.
