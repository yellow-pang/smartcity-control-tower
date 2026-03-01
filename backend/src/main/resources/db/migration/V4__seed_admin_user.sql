-- V4__seed_admin_user.sql (MariaDB)
-- 초기 관리자 계정 1명 생성

START TRANSACTION;

-- ADMIN role_id 조회
SELECT role_id INTO @R_ADMIN FROM role WHERE role_key = 'ADMIN';

-- 초기 관리자 사용자 생성
INSERT INTO app_user (
  email, password_hash, name, status, last_login_at,
  created_at, updated_at
) VALUES (
  'admin@smartops.local',
  '$2a$10$REPLACE_WITH_BCRYPT_HASH_VALUE',
  '초기관리자',
  'ACTIVE',
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
);

-- 생성된 user_id 가져오기
SELECT user_id INTO @U_ADMIN FROM app_user WHERE email = 'admin@smartops.local';

-- user_role로 ADMIN 역할 부여
INSERT INTO user_role (user_id, role_id, created_at, updated_at)
VALUES (@U_ADMIN, @R_ADMIN, CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3));

COMMIT;
