# 🔐 환경별 설정 가이드

## 0. 개요

Spring Boot 프로필을 이용한 환경별 설정 분리로 민감 정보(DB 비밀번호 등)가 커밋되지 않도록 관리합니다.

---

## 1. 파일 구조

```
backend/src/main/resources/
├── application.yaml              # ✅ 커밋 (기본값, 환경변수 플레이스홀더)
├── application-dev.yaml          # ❌ 커밋X (개발용 - 실제 비밀번호)
├── application-prod.yaml         # ✅ 커밋 (운영용 - 환경변수 사용)
└── application-local.yaml        # ❌ 커밋X (로컬 오버라이드 - 선택)
```

---

## 2. 각 파일 역할

### 2.1 application.yaml (공유 가능)

- **용도**: 기본 설정 + 환경변수 플레이스홀더
- **커밋**: ✅ YES (민감정보 없음)
- **내용**:
  ```yaml
  spring:
    datasource:
      url: jdbc:mariadb://${DB_HOST:localhost}:${DB_PORT:3306}/${DB_NAME}...
      username: ${DB_USERNAME}
      password: ${DB_PASSWORD}
  ```
- **특징**: 모든 민감 정보는 `${}` 문법으로 환경변수 참조

### 2.2 application-dev.yaml (개발용)

- **용도**: 로컬 개발 환경 설정
- **커밋**: ❌ NO (실제 비밀번호 포함)
- **내용**:
  ```yaml
  spring:
    datasource:
      username: smartops_user
      password: ChangeMe!1234 # 실제 비밀번호
  ```
- **활성화**: `SPRING_PROFILE_ACTIVE=dev` 또는 기본값
- **유지**: 로컬에만 유지, 버전 관리 제외

### 2.3 application-prod.yaml (운영용)

- **용도**: 운영 환경 설정
- **커밋**: ✅ YES (민감정보 없음, 환경변수 사용)
- **내용**:
  ```yaml
  logging:
    level:
      root: WARN
  ```
- **활성화**: `SPRING_PROFILE_ACTIVE=prod`
- **특징**: 모든 민감정보는 런타임 환경변수로 주입

### 2.4 application-local.yaml (선택 - 개인용)

- **용도**: 개인 로컬 오버라이드
- **커밋**: ❌ NO (.gitignore 등록)
- **언제 필요**: IDE 특정 설정 필요시

---

## 3. 개발 환경 설정 (로컬)

### 3.1 기본 설정 (Spring Boot 기본값)

```bash
cd backend/

# 방법 1: 기본값 사용 (dev 프로필이 기본)
./gradlew bootRun

# 방법 2: 명시적으로 dev 프로필 활성화
./gradlew bootRun --args='--spring.profiles.active=dev'
```

**동작 원리:**

1. `application.yaml` 로드 (기본값)
2. `application-dev.yaml` 로드 (현재 프로필)
3. `application-dev.yaml` 설정이 기본값을 오버라이드

### 3.2 환경변수 오버라이드 (선택)

원하는 경우 선택적으로 환경변수 설정:

```bash
# Linux / macOS
export DB_HOST=192.168.1.100
export DB_USERNAME=custom_user
export DB_PASSWORD=custom_pass

./gradlew bootRun

# Windows PowerShell
$env:DB_HOST="192.168.1.100"
$env:DB_USERNAME="custom_user"
$env:DB_PASSWORD="custom_pass"

./gradlew bootRun
```

### 3.3 IDE 설정 (IntelliJ IDEA / VS Code)

#### IntelliJ IDEA

**Run Configuration 설정:**

1. `Run` → `Edit Configurations`
2. `Application` 선택
3. `VM options` 추가:
   ```
   -Dspring.profiles.active=dev
   ```
4. `Environment variables` 추가 (선택):
   ```
   DB_HOST=localhost;DB_PORT=3306;DB_NAME=smartops
   ```

#### VS Code

`.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "java",
      "name": "Spring Boot App (Dev)",
      "request": "launch",
      "mainClass": "com.yellowpang.backend.BackendApplication",
      "args": "--spring.profiles.active=dev",
      "cwd": "${workspaceFolder}/backend"
    }
  ]
}
```

---

## 4. 운영 환경 설정 (프로덕션)

### 4.1 Docker 배포

```dockerfile
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app
COPY backend/build/libs/backend-*.jar app.jar

# 환경변수 설정 (예시)
ENV SPRING_PROFILE_ACTIVE=prod
ENV DB_HOST=mariadb.prod.example.com
ENV DB_PORT=3306
ENV DB_NAME=smartops_prod
ENV DB_USERNAME=prod_user
ENV DB_PASSWORD=${DB_PASSWORD_SECRET}

ENTRYPOINT ["java", "-jar", "app.jar"]
```

**실행:**

```bash
docker run -e DB_PASSWORD=secret123 smartcity-backend:latest
```

### 4.2 Kubernetes 배포

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
data:
  SPRING_PROFILE_ACTIVE: prod
  DB_HOST: smartops-db
  DB_PORT: "3306"
  DB_NAME: smartops_prod

---
apiVersion: v1
kind: Secret
metadata:
  name: backend-secrets
type: Opaque
stringData:
  DB_USERNAME: prod_user
  DB_PASSWORD: <encrypted_password>

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  template:
    spec:
      containers:
        - name: backend
          image: smartcity-backend:1.0.0
          envFrom:
            - configMapRef:
                name: backend-config
            - secretRef:
                name: backend-secrets
```

### 4.3 Linux 서비스

```bash
# /etc/systemd/system/smartcity-backend.service

[Unit]
Description=SmartCity Backend Service
After=network.target

[Service]
Type=simple
User=smartcity
WorkingDirectory=/opt/smartcity-backend

# 환경변수 파일 로드
EnvironmentFile=/etc/smartcity-backend/prod.env

ExecStart=/usr/bin/java -jar /opt/smartcity-backend/backend-1.0.jar

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**환경변수 파일 (`/etc/smartcity-backend/prod.env`):**

```bash
SPRING_PROFILE_ACTIVE=prod
DB_HOST=localhost
DB_PORT=3306
DB_NAME=smartops_prod
DB_USERNAME=prod_user
DB_PASSWORD=SecurePassword!2024
```

---

## 5. 환경변수 참조 목록

### 5.1 필수 환경변수

| 변수명                  | 설명        | 기본값    | 예시                |
| ----------------------- | ----------- | --------- | ------------------- |
| `SPRING_PROFILE_ACTIVE` | 활성 프로필 | dev       | prod, dev, local    |
| `DB_HOST`               | DB 호스트   | localhost | mariadb.example.com |
| `DB_PORT`               | DB 포트     | 3306      | 3306                |
| `DB_NAME`               | DB 이름     | smartops  | smartops_prod       |
| `DB_USERNAME`           | DB 사용자   | (없음)    | prod_user           |
| `DB_PASSWORD`           | DB 비밀번호 | (없음)    | SecurePass!1234     |

### 5.2 선택 환경변수

```bash
# 로깅
LOG_LEVEL=INFO
LOG_FILE=/var/log/smartcity/app.log

# JWT (1단계에서 추가)
JWT_SECRET_KEY=your-secret-key-here
JWT_EXPIRATION_MS=86400000
```

---

## 6. 주의사항 및 보안

### 6.1 ⚠️ 절대 하지 말 것

```bash
❌ git add application-dev.yaml
❌ git add .env
❌ 비밀번호를 소스 코드에 하드코딩
❌ 프로덕션 비밀번호를 공유 저장소에 저장
```

### 6.2 ✅ 권장 사항

```bash
✅ .gitignore에 dev 프로필 등록
✅ 운영 환경변수는 시크릿 관리 도구 사용 (Vault, K8s Secrets, AWS Secrets Manager)
✅ 개발/운영 환경 완전 분리
✅ 정기적으로 비밀번호 로테이션
```

### 6.3 실수 방지

만약 실수로 비밀번호가 커밋된 경우:

```bash
# Git 히스토리에서 제거
git rm --cached backend/src/main/resources/application-dev.yaml
echo "application-dev.yaml" >> .gitignore
git add .gitignore
git commit -m "Remove sensitive config from history"

# 강제 푸시 (주의: 협업 시 영향)
git push -f
```

---

## 7. 로컬 application-dev.yaml 생성 (첫 실행 시)

처음 프로젝트를 받은 개발자는:

```bash
cd backend/src/main/resources/

# application-dev.yaml 생성
cat > application-dev.yaml << 'EOF'
spring:
  datasource:
    url: jdbc:mariadb://localhost:3306/smartops?characterEncoding=UTF-8&serverTimezone=Asia/Seoul
    username: smartops_user
    password: ChangeMe!1234
  jpa:
    database-platform: org.hibernate.dialect.MariaDBDialect
    hibernate:
      ddl-auto: validate
    show-sql: false
  devtools:
    restart:
      enabled: true

logging:
  level:
    root: INFO
    com.yellowpang.backend: DEBUG
    org.springframework.security: DEBUG
    org.mybatis: DEBUG
EOF

# 또는 부팀 리더에게 application-dev.yaml 파일 요청
```

---

## 8. 검증 및 테스트

### 8.1 활성 프로필 확인

```bash
curl http://localhost:8080/actuator/env | grep spring.profiles

# 또는 로그에서 확인
# "The following profiles are active: dev"
```

### 8.2 데이터소스 확인

```sql
-- DB가 올바르게 연결되었는지 확인
SELECT 'Connection OK' AS status;
```

### 8.3 프로필별 로깅 레벨 검증

- **dev**: `DEBUG` 레벨 로그 출력
- **prod**: `WARN` 레벨 로그만 출력

---

## 9. 요약

| 시나리오        | 파일                     | 액션                           |
| --------------- | ------------------------ | ------------------------------ |
| 로컬 개발       | `application-dev.yaml`   | 실제 비밀번호 포함, .gitignore |
| 팀 공유         | `application.yaml`       | 환경변수만, 커밋 ✅            |
| 운영 배포       | `application-prod.yaml`  | 환경변수 참조, 커밋 ✅         |
| 개인 오버라이드 | `application-local.yaml` | 선택, .gitignore               |

---

## 10. 참고 자료

- [Spring Boot Profile](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.profiles)
- [12-Factor App - Config](https://12factor.net/config)
- [OWASP - Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
