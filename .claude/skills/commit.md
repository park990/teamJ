# Git Commit Rules

## Conventional Commits Format

```
<type>: <subject>

[optional body]

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## 📌 커밋 타입 (Types)

| Type | 용도 | TeamJ 프로젝트 예시 |
|------|------|---------------------|
| `feat` | 새 기능 추가 | `feat: 게시글 삭제 API 연동`<br>`feat: 401/403 자동 재시도 로직 추가` |
| `fix` | 버그 수정 | `fix: 토큰 갱신 무한루프 해결`<br>`fix: 이미지 업로드 실패 오류 수정` |
| `chore` | 빌드/설정/패키지 변경<br>(코드/기능 영향 없음) | `chore: riverpod 2.3 → 2.4 업그레이드`<br>`chore: .gitignore에 .env 추가`<br>`chore: Flutter SDK 3.13 업데이트` |
| `docs` | 문서 전용<br>(README, 가이드, 주석) | `docs: API 에러 핸들링 가이드 추가`<br>`docs: PostRepository 주석 추가`<br>`docs: CLAUDE.md 업데이트` |
| `refactor` | 코드 리팩토링<br>(기능 변경 없음) | `refactor: PostRepository 로직 단순화`<br>`refactor: ApiClient 메서드 분리` |
| `test` | 테스트 추가/수정 | `test: ApiClient 토큰 갱신 테스트`<br>`test: 게시글 삭제 통합 테스트` |
| `style` | 포맷팅, 세미콜론 등<br>(로직 변경 없음) | `style: Dart format 적용`<br>`style: import 정리` |

---

## 🔍 chore 상세 가이드

**chore = 코드/기능 변경 없이 프로젝트 설정만 변경**

| 카테고리 | 설명 | 예시 |
|----------|------|------|
| **패키지 관리** | pubspec.yaml, build.gradle | `chore: http 패키지 1.1.0 추가`<br>`chore: JWT 라이브러리 0.9 → 0.12 업그레이드` |
| **빌드 설정** | SDK, Gradle, 컴파일 옵션 | `chore: Java 17 → 21 마이그레이션`<br>`chore: minSdkVersion 21 → 23 변경` |
| **설정 파일** | .gitignore, .env, IDE 설정 | `chore: .gitignore에 .env 추가`<br>`chore: .vscode 설정 추가` |
| **개발 도구** | Linter, Formatter, CI/CD | `chore: GitHub Actions 파이프라인 수정`<br>`chore: pre-commit hook 추가` |
| **프로젝트 정리** | 미사용 파일/의존성 제거 | `chore: flutter_front 폴더 삭제`<br>`chore: 미사용 패키지 제거` |

---

## ❌ 흔히 헷갈리는 케이스

| 잘못된 사용 | 올바른 타입 | 이유 |
|-------------|-------------|------|
| `chore: README 수정` | `docs: README 업데이트` | 문서 변경은 `docs` |
| `chore: 주석 추가` | `docs: PostRepository 주석 추가` | 주석도 문서 |
| `fix: 패키지 업그레이드` | `chore: riverpod 업그레이드` | 버그 수정 아님 |
| `feat: 코드 포맷팅` | `style: Dart format 적용` | 기능 추가 아님 |
| `refactor: 버그 수정` | `fix: 로직 오류 수정` | 버그는 `fix` |

---

## 📋 타입 판단 플로우

```
┌─────────────────────────┐
│ 코드/기능이 변경되었나? │
└───────┬─────────────────┘
        │
    YES │ NO
        │
  ┌─────┴──────┐
  │            │
기능/버그     설정만?
  │            │
  ├─ 새 기능: feat      ├─ 패키지/빌드: chore
  ├─ 버그: fix          ├─ 문서만: docs
  ├─ 개선: refactor     └─ 포맷팅: style
  └─ 테스트: test
```

---

## Subject Guidelines

- ✅ 50자 이내로 작성
- ✅ 명령형 사용 ("추가했음" ❌, "추가" ✅)
- ✅ 한글 또는 영어 일관성 유지
- ❌ 마침표 사용 금지

---

## 커밋 예시

### Good ✅
```
feat: 게시글 삭제 API 연동

- PostRepository.deletePost() 메서드 추가
- 삭제 성공/실패 시 토스트 메시지 표시
- GlobalExceptionHandler에서 예외 처리

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

### Bad ❌
```
updated some files.              # 너무 모호함
Fix bug                          # 어떤 버그인지 불명확
feat: 게시글 삭제 기능 추가했습니다.  # 명령형 아님
chore: README 수정               # docs 사용해야 함
```

---

## Multi-line Commits

긴 설명이 필요한 경우 HEREDOC 사용:

```bash
git commit -m "$(cat <<'EOF'
feat: GlobalExceptionHandler 추가

- BbsException 커스텀 예외 처리
- ApiResponse 표준 포맷 반환
- 로깅 추가

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

---

## Branch Naming

| Type | 형식 | 예시 |
|------|------|------|
| 새 기능 | `feat/기능명` | `feat/api-error-handling` |
| 버그 수정 | `fix/버그명` | `fix/token-refresh-loop` |
| 설정/빌드 | `chore/작업명` | `chore/update-dependencies` |
| 문서 | `docs/문서명` | `docs/api-guide` |

---

## 빠른 참조

```bash
# 단일 라인
git commit -m "feat: 게시글 삭제 기능 추가"

# 멀티 라인 (HEREDOC)
git commit -m "$(cat <<'EOF'
feat: 게시글 삭제 기능 추가

상세 설명...

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"

# 브랜치 생성
git checkout -b feat/post-delete

# 이전 커밋 메시지 확인
git log --oneline -10
```
