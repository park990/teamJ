# TeamJ 🎉

> 모임과 랜덤 채팅을 위한 소셜 네트워킹 애플리케이션

---

## 📖 프로젝트 개요

**봄밍**는 **Spring Boot**와 **Flutter**로 구축된 종합 모임 관리 및 실시간 채팅 애플리케이션입니다.
사용자 간 소셜 인터랙션과 실시간 기능에 중점을 두고 있습니다.

### ✨ 주요 기능

-  **소셜 모임**: 모임 생성, 참가, 관리 기능
-  **랜덤 1:1 채팅**: WebSocket & Redis 기반 실시간 매칭 시스템
-  **커뮤니티**: 게시판 및 댓글 기능
-  **인증**: OAuth (카카오) & 커스텀 JWT (이중 토큰 시스템)

---

## 📂 레포지토리 구조

| 디렉토리 | 설명 | 상태 |
|:---------|:-----|:-----|
| `/backend` | Spring Boot REST API & WebSocket 서버 | ✅ **활성** |
| `/front` | Flutter 모바일 애플리케이션 (Riverpod 2.x) | ✅ **활성** |
| `/redis` | Redis 설정 파일 | ⚙️ Config |
| `/flutter_front` | 이전 Flutter 구현 | ⚠️ **사용 금지** (Deprecated) |

---

## 🛠️ 사전 요구사항

다음 도구들이 설치되어 있어야 합니다:

-  **Java 21** (JDK 21)
-  **Flutter 3.10+**
-  **MySQL** Database
-  **Redis** Server

---

## 🚀 시작하기

### 1️⃣ 백엔드 설정 (Spring Boot)

```bash
# 백엔드 디렉토리로 이동
cd backend

# 프로젝트 빌드
./gradlew build

# 애플리케이션 실행
./gradlew bootRun

# 테스트 실행
./gradlew test
```

#### ⚙️ 환경 설정 (`application.properties`)

`src/main/resources/application.properties` 파일에 다음 환경 변수를 설정하세요:

-  Database credentials (MySQL)
-  Redis Host/Port
-  JWT Secret Key
-  AWS S3 Credentials

---

### 2️⃣ 프론트엔드 설정 (Flutter)

> ⚠️ **중요**: `/front` 디렉토리를 사용하세요. `/flutter_front`는 무시하세요.

```bash
# 프론트엔드 디렉토리로 이동
cd front

# 의존성 설치
flutter pub get

# 에뮬레이터/디바이스에서 실행
flutter run
```

#### 🔧 환경 변수 설정 (`.env`)

`front/` 디렉토리에 `.env` 파일을 생성하세요:

```env
# Android 에뮬레이터: 10.0.2.2, iOS: localhost
BASE_URL=10.0.2.2:8080
WS_URL=10.0.2.2:8080
```

---

## 🏗️ 아키텍처 하이라이트

### 🖥️ 백엔드 (Spring Boot 3.5+)

#### 🔌 WebSocket 인증
- ⚠️ `@MessageMapping`에서 `SecurityContextHolder`는 동작하지 않음 (ThreadLocal 이슈)
- ✅ `JwtChannelInterceptor`를 사용하여 `SimpSessionAttributes`에 사용자 정보 주입

#### 🎯 매칭 시스템
- Redis 기반 매칭 큐 관리 (`MatchQueueManager`)
- **흐름**: User Enter → Redis Queue → Match Found → Notify Users

#### 💾 캐싱
- Redis를 사용하여 인기 모임 리스트 및 참가자 수 캐싱 (TTL: 1-10분)

---

### 📱 프론트엔드 (Flutter)

#### 🔄 상태 관리
**Riverpod 2.x** 엄격히 사용:

- `Provider`: Repository 및 Service 용도
- `AsyncNotifier`: 비동기 데이터 스트림 용도
- `ChangeNotifier`: UI Controller 용도

#### 🏛️ 아키텍처 패턴
**MVVM 패턴**: `Screen ↔ Controller ↔ Repository ↔ Data Source`

---

## 📝 개발 가이드라인

### 1️⃣ 프론트엔드 표준 (Flutter)

#### ✅ 상태 관리
- **필수**: Riverpod 2.x 사용
- ❌ **금지**: GetX 또는 레거시 Provider 사용 금지
- ❌ **지양**: 복잡한 비즈니스 로직에서 `setState` 사용 지양

#### 📁 디렉토리
- ✅ 항상 `/front`에서 작업
- ❌ `/flutter_front` 수정 금지

---

### 2️⃣ 백엔드 표준 (Java)

#### ☕ Java 21 기능
다음 모던 기능을 적극 활용하세요:
- Records
- Switch Expressions
- Pattern Matching

#### 🏛️ Clean Architecture
엄격한 계층 분리 유지:

```
Controller (Request/Response)
    ↓
Service (Business Logic & Transactions)
    ↓
Repository (Data Access)
```

---

### 3️⃣ 보안 모범 사례

#### 🔒 시크릿 관리
- ❌ API 키, 비밀번호, JWT 시크릿을 버전 관리에 커밋하지 마세요
- ✅ 항상 환경 변수 또는 `.env` 파일 사용

---

## 📚 추가 문서

더 자세한 내용은 다음 문서를 참조하세요:

- 📄 [CLAUDE.md](CLAUDE.md) - AI 개발 지원 가이드
- 🔗 Backend API 문서
- 📱 Flutter 컴포넌트 가이드

---

## 👥 기여하기

프로젝트에 기여하고 싶으시다면:
1. Fork this repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 라이선스

이 프로젝트는 [MIT 라이선스](LICENSE) 하에 배포됩니다.

자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

---

<div align="center">

**Made with ❤️ by TeamJ**

</div>
