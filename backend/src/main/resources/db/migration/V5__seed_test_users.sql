-- V5__seed_test_users.sql (MariaDB)
-- 테스트용 계정 2명 생성

START TRANSACTION;

-- 역할 ID 조회
SELECT role_id INTO @R_OPERATOR FROM role WHERE role_key = 'OPERATOR';
SELECT role_id INTO @R_AUDITOR  FROM role WHERE role_key = 'AUDITOR';

-- OPERATOR 사용자 생성
INSERT INTO app_user (
  email, password_hash, name, status, last_login_at,
  created_at, updated_at
) VALUES (
  'operator@smartops.local',
  '$2a$10$REPLACE_WITH_BCRYPT_HASH_VALUE',
  '운영자',
  'ACTIVE',
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
);

SELECT user_id INTO @U_OPERATOR FROM app_user WHERE email = 'operator@smartops.local';

INSERT INTO user_role (user_id, role_id, created_at, updated_at)
VALUES (@U_OPERATOR, @R_OPERATOR, CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3));

-- AUDITOR 사용자 생성
INSERT INTO app_user (
  email, password_hash, name, status, last_login_at,
  created_at, updated_at
) VALUES (
  'auditor@smartops.local',
  '$2a$10$REPLACE_WITH_BCRYPT_HASH_VALUE',
  '감사자',
  'ACTIVE',
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
);

SELECT user_id INTO @U_AUDITOR FROM app_user WHERE email = 'auditor@smartops.local';

INSERT INTO user_role (user_id, role_id, created_at, updated_at)
VALUES (@U_AUDITOR, @R_AUDITOR, CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3));

COMMIT;
