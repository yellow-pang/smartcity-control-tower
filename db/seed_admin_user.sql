-- seed_admin_user.sql (MariaDB)
-- 초기 관리자 계정 1명 생성 + ADMIN 역할 부여(user_role)
-- 실행 순서: schema.sql -> seed_rbac.sql -> seed_admin_user.sql
--
-- 중요:
-- 1) password_hash는 "평문"이 아닙니다. 아래 값은 샘플(placeholder)입니다.
--    실제 구현에서 BCrypt 등으로 해시한 값을 넣어주세요.
-- 2) 이미 같은 email이 있으면 UNIQUE 제약으로 실패합니다.

START TRANSACTION;

-- =========================
-- 1) ADMIN role_id 조회
-- =========================
SELECT role_id INTO @R_ADMIN
FROM role
WHERE role_key = 'ADMIN';

-- =========================
-- 2) 초기 관리자 사용자 생성
-- =========================
INSERT INTO app_user (
  email, password_hash, name, status, last_login_at,
  created_at, updated_at
) VALUES (
  'admin@smartops.local',
  '$2a$10$REPLACE_WITH_BCRYPT_HASH_VALUE', -- TODO: 실제 BCrypt 해시로 교체
  '초기관리자',
  'ACTIVE',
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
);

-- 생성된 user_id 가져오기
SELECT user_id INTO @U_ADMIN
FROM app_user
WHERE email = 'admin@smartops.local';

-- =========================
-- 3) user_role로 ADMIN 역할 부여
-- =========================
INSERT INTO user_role (user_id, role_id, created_at, updated_at)
VALUES (@U_ADMIN, @R_ADMIN, CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3));

COMMIT;

-- (선택) 확인
-- SELECT u.email, r.role_key
-- FROM app_user u
-- JOIN user_role ur ON ur.user_id = u.user_id
-- JOIN role r ON r.role_id = ur.role_id
-- WHERE u.email = 'admin@smartops.local';