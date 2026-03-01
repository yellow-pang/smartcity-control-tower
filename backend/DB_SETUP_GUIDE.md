# 📚 DB 실행 환경 설정 가이드

## 0. 개요

스마트시티 운영 관제 컨트롤타워의 MariaDB 환경을 로컬에서 실행하고 초기화하는 방법입니다.

---

## 1. 사전 요구사항

- Docker & Docker Compose 설치
- 포트 가용성 확인
  - `3306` (MariaDB)
  - `8180` (Adminer UI)

---

## 2. Docker Compose로 DB 실행

### 2.1 컨테이너 시작

```bash
cd backend/

# 컨테이너 시작 (백그라운드)
docker-compose up -d

# 상태 확인
docker-compose ps
```

**출력 예시:**

```
NAME                    STATUS
smartcity-mariadb       Up 10 seconds (healthy)
smartcity-adminer       Up 5 seconds
```

### 2.2 접속 확인

#### MariaDB 직접 접속 (CLI)

```bash
docker-compose exec mariadb mariadb -u smartcity_user -p smartcity

# 프롬프트에서 비밀번호 입력: smartcity_password_123
```

#### Adminer UI 접속 (GUI)

```
http://localhost:8180
```

**접속 정보:**

- 시스템: MariaDB
- 서버: mariadb
- 사용자명: smartcity_user
- 비밀번호: smartcity_password_123
- 데이터베이스: smartcity

---

## 3. Flyway 마이그레이션 자동 실행

Spring Boot 애플리케이션 실행 시 **Flyway가 자동으로 마이그레이션을 수행**합니다.

### 3.1 마이그레이션 파일 구조

```
backend/src/main/resources/db/migration/
├── V1__initial_schema.sql      # 전체 테이블 생성
├── V2__seed_codes.sql           # 코드 데이터 삽입
├── V3__seed_rbac.sql            # 역할/권한 삽입
├── V4__seed_admin_user.sql      # 관리자 계정 생성
└── V5__seed_test_users.sql      # 테스트 계정 생성
```

### 3.2 실행 순서

Flyway는 **버전 번호 순서대로 자동 실행**합니다:

1. `V1`: 모든 테이블 생성 (DDL)
2. `V2`: code_group, code_item 데이터 삽입
3. `V3`: role, permission, role_permission 설정
4. `V4`: admin 계정 생성
5. `V5`: operator, auditor 계정 생성

### 3.3 Spring Boot 실행 및 마이그레이션 확인

```bash
cd backend/

# Gradle로 빌드 및 실행
./gradlew bootRun

# 또는 JAR 파일로 실행
./gradlew build
java -jar build/libs/backend-0.0.1-SNAPSHOT.jar
```

**마이그레이션 로그 확인:**

실행 로그에서 다음과 같이 표시됩니다:

```
INFO  org.flywaydb.core.internal.command.DbMigrate - Migrating schema `smartcity` to version 1 - initial_schema
INFO  org.flywaydb.core.internal.command.DbMigrate - Migrating schema `smartcity` to version 2 - seed_codes
INFO  org.flywaydb.core.internal.command.DbMigrate - Migrating schema `smartcity` to version 3 - seed_rbac
INFO  org.flywaydb.core.internal.command.DbMigrate - Migrating schema `smartcity` to version 4 - seed_admin_user
INFO  org.flywaydb.core.internal.command.DbMigrate - Migrating schema `smartcity` to version 5 - seed_test_users
```

---

## 4. 수동 마이그레이션 (선택)

Flyway를 거치지 않고 **DBeaver**에서 직접 실행하려면:

### 4.1 순서대로 SQL 실행

DBeaver 또는 다른 클라이언트에서:

```sql
-- 1. V1__initial_schema.sql 실행
-- 2. V2__seed_codes.sql 실행
-- 3. V3__seed_rbac.sql 실행
-- 4. V4__seed_admin_user.sql 실행
-- 5. V5__seed_test_users.sql 실행
```

---

## 5. 데이터 검증 쿼리

마이그레이션 후 데이터 검증:

### 5.1 테이블 존재 확인

```sql
-- 모든 테이블 조회
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'smartcity'
ORDER BY TABLE_NAME;
```

**예상 테이블 수: 22개**

### 5.2 코드 데이터 확인

```sql
-- 코드 그룹 조회
SELECT * FROM code_group;
-- 예상: 9개 그룹 (TARGET_STATUS, TARGET_TYPE, EVENT_TYPE 등)

-- 샘플 코드 아이템
SELECT g.group_key, i.item_key, i.name
FROM code_group g
JOIN code_item i ON g.code_group_id = i.code_group_id
WHERE g.group_key = 'CASE_STATUS'
ORDER BY i.sort_order;
-- 예상: NEW, IN_PROGRESS, ON_HOLD, RESOLVED
```

### 5.3 사용자 및 권한 확인

```sql
-- 사용자 스캔
SELECT u.email, u.name, u.status, r.role_key
FROM app_user u
JOIN user_role ur ON u.user_id = ur.user_id
JOIN role r ON ur.role_id = r.role_id
ORDER BY u.email;
```

**예상 결과:**

| email                   | name       | status | role_key |
| ----------------------- | ---------- | ------ | -------- |
| admin@smartops.local    | 초기관리자 | ACTIVE | ADMIN    |
| operator@smartops.local | 운영자     | ACTIVE | OPERATOR |
| auditor@smartops.local  | 감사자     | ACTIVE | AUDITOR  |

### 5.4 권한 매핑 확인

```sql
-- OPERATOR 역할의 권한 조회
SELECT r.role_key, p.perm_key, p.name
FROM role r
JOIN role_permission rp ON r.role_id = rp.role_id
JOIN permission p ON rp.permission_id = p.permission_id
WHERE r.role_key = 'OPERATOR'
ORDER BY p.perm_key;
```

---

## 6. 테스트 계정 정보

| 역할     | 이메일                  | 비밀번호\*   | 권한      |
| -------- | ----------------------- | ------------ | --------- |
| Admin    | admin@smartops.local    | `$2a$10$...` | 전체 권한 |
| Operator | operator@smartops.local | `$2a$10$...` | 관제/운영 |
| Auditor  | auditor@smartops.local  | `$2a$10$...` | 읽기 전용 |

**\* 주의:** 비밀번호는 `$2a$10$REPLACE_WITH_BCRYPT_HASH_VALUE` 플레이스홀더입니다.
로그인 시 실제 BCrypt 해시 값으로 교체해야 합니다. (1단계에서 구현 예정)

### 임시 테스트용 비밀번호 설정 (선택)

개발 편의상 테스트 비밀번호를 설정하려면:

```sql
-- 모든 테스트 계정의 비밀번호를 동일하게 설정 (예: "password123")
-- BCrypt 해시 (bcrypt hash for "password123"):
-- $2a$10$slYQmyNdGzin7olVN3p5aO3BHK/R/qb39L5DMpWy2Qfasl.uEhVjK

UPDATE app_user
SET password_hash = '$2a$10$slYQmyNdGzin7olVN3p5aO3BHK/R/qb39L5DMpWy2Qfasl.uEhVjK'
WHERE email IN (
  'admin@smartops.local',
  'operator@smartops.local',
  'auditor@smartops.local'
);
```

---

## 7. 컨테이너 정리

### 7.1 컨테이너 중지

```bash
docker-compose down
```

### 7.2 전체 리셋 (데이터 삭제)

```bash
docker-compose down -v  # -v 옵션으로 볼륨도 삭제
```

---

## 8. 트러블슈팅

### 8.1 포트 충돌

포트 3306 또는 8180이 이미 사용 중인 경우:

```yaml
# compose.yaml에서 포트 변경
ports:
  - "3307:3306" # 외부포트:컨테이너포트
```

### 8.2 Flyway 마이그레이션 실패

마이그레이션이 실패한 경우:

1. **DB 상태 확인:**

   ```sql
   SELECT * FROM flyway_schema_history;
   ```

2. **실패한 마이그레이션 복구:**
   ```bash
   docker-compose down -v  # 전체 삭제 후 재시작
   docker-compose up -d
   ```

### 8.3 접속 거부 오류

```
ERROR 2003 (HY000): Can't connect to MySQL server on 'localhost' (111)
```

**해결:**

```bash
# 컨테이너 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs mariadb
```

---

## 9. 성능 최적화 (선택)

### 9.1 인덱스 생성 확인

```sql
-- 주요 인덱스 확인
SELECT TABLE_NAME, INDEX_NAME
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'smartcity'
AND TABLE_NAME IN ('case_ticket', 'event_log', 'notification_send', 'audit_log')
ORDER BY TABLE_NAME, INDEX_NAME;
```

### 9.2 테이블 용량 확인

```sql
SELECT
  TABLE_NAME,
  ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), 2) AS 'Size (MB)'
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'smartcity'
ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC;
```

---

## 10. 다음 단계

- ✅ DB 환경 완료
- 🚀 **1단계**: Spring Security + JWT + 권한 시스템 구현
- 📱 **2단계**: REST API (조회) 구현
- 🎨 **3단계**: 프론트엔드 인증 & 라우팅
- ... (이후 단계 진행)

---

## 참고 문서

- [Flyway 공식 문서](https://flywaydb.org/documentation)
- [MariaDB 공식 문서](https://mariadb.com/docs/)
- [Docker Compose 참조](https://docs.docker.com/compose/compose-file/)

---

**최종 확인 체크리스트:**

- [ ] Docker 컨테이너 실행 확인 (`docker-compose ps`)
- [ ] Adminer UI 접속 가능 (http://localhost:8180)
- [ ] 22개 테이블 생성 확인
- [ ] 3개 테스트 계정 존재 확인
- [ ] RBAC 권한 매핑 확인
- [ ] 코드 데이터 (9개 그룹) 확인
