-- seed_rbac.sql (MariaDB)
-- RBAC 초기 시드: role / permission / role_permission
-- 실행 순서: schema.sql -> seed_codes.sql(선택) -> seed_rbac.sql
-- 주의: 본 파일은 code_item을 사용하지 않고 RBAC 자체 테이블만 채웁니다.

START TRANSACTION;

-- =========================
-- 1) Roles
-- =========================
INSERT INTO role (role_key, name) VALUES
('ADMIN',   '시스템 관리자'),
('OPERATOR','관제 운영자'),
('AUDITOR', '감사/보안 담당자');

-- role_id 변수
SELECT role_id INTO @R_ADMIN    FROM role WHERE role_key='ADMIN';
SELECT role_id INTO @R_OPERATOR FROM role WHERE role_key='OPERATOR';
SELECT role_id INTO @R_AUDITOR  FROM role WHERE role_key='AUDITOR';

-- =========================
-- 2) Permissions (최소 권한 묶음)
-- =========================
-- 공통 조회
INSERT INTO permission (perm_key, name) VALUES
('DASHBOARD_READ',     '대시보드 조회'),
('TARGET_READ',        '관제 대상 조회'),
('EVENT_READ',         '이벤트 조회'),

-- 케이스
('CASE_READ',          '케이스 조회'),
('CASE_CREATE',        '케이스 생성'),
('CASE_UPDATE',        '케이스 수정(상태/내용)'),
('CASE_ASSIGN',        '케이스 담당자 할당/변경'),
('CASE_COMMENT',       '케이스 코멘트 작성'),

-- 알림
('NOTIFICATION_READ',  '알림 이력 조회'),
('NOTIFICATION_SEND',  '알림 발송'),

-- 감사
('AUDIT_READ',         '감사 로그 조회'),

-- 관리자
('USER_MANAGE',        '사용자 관리'),
('ROLE_MANAGE',        '역할/권한 관리');

-- permission_id 변수
SELECT permission_id INTO @P_DASHBOARD_READ    FROM permission WHERE perm_key='DASHBOARD_READ';
SELECT permission_id INTO @P_TARGET_READ       FROM permission WHERE perm_key='TARGET_READ';
SELECT permission_id INTO @P_EVENT_READ        FROM permission WHERE perm_key='EVENT_READ';

SELECT permission_id INTO @P_CASE_READ         FROM permission WHERE perm_key='CASE_READ';
SELECT permission_id INTO @P_CASE_CREATE       FROM permission WHERE perm_key='CASE_CREATE';
SELECT permission_id INTO @P_CASE_UPDATE       FROM permission WHERE perm_key='CASE_UPDATE';
SELECT permission_id INTO @P_CASE_ASSIGN       FROM permission WHERE perm_key='CASE_ASSIGN';
SELECT permission_id INTO @P_CASE_COMMENT      FROM permission WHERE perm_key='CASE_COMMENT';

SELECT permission_id INTO @P_NOTI_READ         FROM permission WHERE perm_key='NOTIFICATION_READ';
SELECT permission_id INTO @P_NOTI_SEND         FROM permission WHERE perm_key='NOTIFICATION_SEND';

SELECT permission_id INTO @P_AUDIT_READ        FROM permission WHERE perm_key='AUDIT_READ';

SELECT permission_id INTO @P_USER_MANAGE       FROM permission WHERE perm_key='USER_MANAGE';
SELECT permission_id INTO @P_ROLE_MANAGE       FROM permission WHERE perm_key='ROLE_MANAGE';

-- =========================
-- 3) role_permission 매핑
-- =========================
-- ADMIN: 전체
INSERT INTO role_permission (role_id, permission_id) VALUES
(@R_ADMIN, @P_DASHBOARD_READ),
(@R_ADMIN, @P_TARGET_READ),
(@R_ADMIN, @P_EVENT_READ),
(@R_ADMIN, @P_CASE_READ),
(@R_ADMIN, @P_CASE_CREATE),
(@R_ADMIN, @P_CASE_UPDATE),
(@R_ADMIN, @P_CASE_ASSIGN),
(@R_ADMIN, @P_CASE_COMMENT),
(@R_ADMIN, @P_NOTI_READ),
(@R_ADMIN, @P_NOTI_SEND),
(@R_ADMIN, @P_AUDIT_READ),
(@R_ADMIN, @P_USER_MANAGE),
(@R_ADMIN, @P_ROLE_MANAGE);

-- OPERATOR: 관제/운영 중심 (사용자/역할 관리는 제외)
INSERT INTO role_permission (role_id, permission_id) VALUES
(@R_OPERATOR, @P_DASHBOARD_READ),
(@R_OPERATOR, @P_TARGET_READ),
(@R_OPERATOR, @P_EVENT_READ),
(@R_OPERATOR, @P_CASE_READ),
(@R_OPERATOR, @P_CASE_CREATE),
(@R_OPERATOR, @P_CASE_UPDATE),
(@R_OPERATOR, @P_CASE_ASSIGN),
(@R_OPERATOR, @P_CASE_COMMENT),
(@R_OPERATOR, @P_NOTI_READ),
(@R_OPERATOR, @P_NOTI_SEND);

-- AUDITOR: 읽기 중심 (수정/발송 불가)
INSERT INTO role_permission (role_id, permission_id) VALUES
(@R_AUDITOR, @P_DASHBOARD_READ),
(@R_AUDITOR, @P_TARGET_READ),
(@R_AUDITOR, @P_EVENT_READ),
(@R_AUDITOR, @P_CASE_READ),
(@R_AUDITOR, @P_NOTI_READ),
(@R_AUDITOR, @P_AUDIT_READ);

COMMIT;

-- (선택) 확인 쿼리
-- SELECT r.role_key, p.perm_key
-- FROM role_permission rp
-- JOIN role r ON r.role_id = rp.role_id
-- JOIN permission p ON p.permission_id = rp.permission_id
-- ORDER BY r.role_key, p.perm_key;