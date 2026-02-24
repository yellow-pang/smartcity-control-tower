-- seed_test_users.sql (MariaDB)
-- 테스트용 계정 2명 생성 + OPERATOR / AUDITOR 역할 부여
-- 실행 순서: schema.sql -> seed_rbac.sql -> seed_admin_user.sql -> seed_test_users.sql
--
-- 중요:
-- 1) password_hash는 샘플 placeholder 입니다. 실제 BCrypt 해시로 교체하세요.
-- 2) email UNIQUE 제약이 있으니 이미 존재하면 실패합니다.

START TRANSACTION;

-- =========================
-- 1) 역할 ID 조회
-- =========================
SELECT role_id INTO @R_OPERATOR FROM role WHERE role_key = 'OPERATOR';
SELECT role_id INTO @R_AUDITOR  FROM role WHERE role_key = 'AUDITOR';

-- =========================
-- 2) OPERATOR 사용자 생성 + 역할 부여
-- =========================
INSERT INTO app_user (
  email, password_hash, name, status, last_login_at,
  created_at, updated_at
) VALUES (
  'operator@smartops.local',
  '$2a$10$REPLACE_WITH_BCRYPT_HASH_VALUE', -- TODO: 실제 BCrypt 해시로 교체
  '운영자',
  'ACTIVE',
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
);

SELECT user_id INTO @U_OPERATOR
FROM app_user
WHERE email = 'operator@smartops.local';

INSERT INTO user_role (user_id, role_id, created_at, updated_at)
VALUES (@U_OPERATOR, @R_OPERATOR, CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3));

-- =========================
-- 3) AUDITOR 사용자 생성 + 역할 부여
-- =========================
INSERT INTO app_user (
  email, password_hash, name, status, last_login_at,
  created_at, updated_at
) VALUES (
  'auditor@smartops.local',
  '$2a$10$REPLACE_WITH_BCRYPT_HASH_VALUE', -- TODO: 실제 BCrypt 해시로 교체
  '감사자',
  'ACTIVE',
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
);

SELECT user_id INTO @U_AUDITOR
FROM app_user
WHERE email = 'auditor@smartops.local';

INSERT INTO user_role (user_id, role_id, created_at, updated_at)
VALUES (@U_AUDITOR, @R_AUDITOR, CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3));

COMMIT;

-- (선택) 확인
-- SELECT u.email, r.role_key
-- FROM app_user u
-- JOIN user_role ur ON ur.user_id = u.user_id
-- JOIN role r ON r.role_id = ur.role_id
-- WHERE u.email IN ('operator@smartops.local', 'auditor@smartops.local');