-- V2__seed_codes.sql (MariaDB)
-- code_group / code_item 초기 데이터 세트

START TRANSACTION;

-- =========================
-- 1) code_group
-- =========================
INSERT INTO code_group (group_key, name, description) VALUES
('TARGET_STATUS', '관제 대상 상태', '대상(시설/센서/차량 등)의 현재 상태'),
('TARGET_TYPE', '관제 대상 유형', '대상의 분류(센서/시설/차량 등)'),
('EVENT_TYPE', '이벤트 유형', '장애/이상징후 이벤트 분류'),
('EVENT_SEVERITY', '이벤트 심각도', '이벤트 심각도 레벨'),
('EVENT_STATUS', '이벤트 상태', '이벤트 처리 상태(선택)'),
('CASE_STATUS', '케이스 상태', '케이스 워크플로우 상태'),
('CASE_CAUSE', '케이스 원인 분류', '완료 시 원인 분류'),
('CASE_ACTION', '케이스 조치 분류', '완료 시 조치 분류'),
('NOTIFICATION_CHANNEL', '알림 채널', '알림 전송 채널');

-- =========================
-- 2) code_item 유틸: group_key -> code_group_id 조회
-- =========================
SELECT code_group_id INTO @G_TARGET_STATUS FROM code_group WHERE group_key='TARGET_STATUS';
SELECT code_group_id INTO @G_TARGET_TYPE   FROM code_group WHERE group_key='TARGET_TYPE';
SELECT code_group_id INTO @G_EVENT_TYPE    FROM code_group WHERE group_key='EVENT_TYPE';
SELECT code_group_id INTO @G_EVENT_SEV     FROM code_group WHERE group_key='EVENT_SEVERITY';
SELECT code_group_id INTO @G_EVENT_STATUS  FROM code_group WHERE group_key='EVENT_STATUS';
SELECT code_group_id INTO @G_CASE_STATUS   FROM code_group WHERE group_key='CASE_STATUS';
SELECT code_group_id INTO @G_CASE_CAUSE    FROM code_group WHERE group_key='CASE_CAUSE';
SELECT code_group_id INTO @G_CASE_ACTION   FROM code_group WHERE group_key='CASE_ACTION';
SELECT code_group_id INTO @G_NOTI_CH       FROM code_group WHERE group_key='NOTIFICATION_CHANNEL';

-- =========================
-- 3) TARGET_STATUS
-- =========================
INSERT INTO code_item (code_group_id, item_key, name, sort_order, is_active) VALUES
(@G_TARGET_STATUS, 'NORMAL',      '정상', 10, 1),
(@G_TARGET_STATUS, 'WARNING',     '주의', 20, 1),
(@G_TARGET_STATUS, 'ERROR',       '장애', 30, 1),
(@G_TARGET_STATUS, 'MAINTENANCE', '점검', 40, 1);

-- =========================
-- 4) TARGET_TYPE
-- =========================
INSERT INTO code_item (code_group_id, item_key, name, sort_order, is_active) VALUES
(@G_TARGET_TYPE, 'SENSOR',   '센서', 10, 1),
(@G_TARGET_TYPE, 'FACILITY', '시설', 20, 1),
(@G_TARGET_TYPE, 'VEHICLE',  '차량', 30, 1),
(@G_TARGET_TYPE, 'WORKER',   '작업자', 40, 1);

-- =========================
-- 5) EVENT_SEVERITY
-- =========================
INSERT INTO code_item (code_group_id, item_key, name, sort_order, is_active) VALUES
(@G_EVENT_SEV, 'LOW',      '낮음', 10, 1),
(@G_EVENT_SEV, 'MEDIUM',   '보통', 20, 1),
(@G_EVENT_SEV, 'HIGH',     '높음', 30, 1),
(@G_EVENT_SEV, 'CRITICAL', '치명', 40, 1);

-- =========================
-- 6) EVENT_STATUS
-- =========================
INSERT INTO code_item (code_group_id, item_key, name, sort_order, is_active) VALUES
(@G_EVENT_STATUS, 'OPEN',        '오픈', 10, 1),
(@G_EVENT_STATUS, 'ACKED',       '확인', 20, 1),
(@G_EVENT_STATUS, 'SUPPRESSED',  '억제', 30, 1),
(@G_EVENT_STATUS, 'CLOSED',      '종료', 40, 1);

-- =========================
-- 7) EVENT_TYPE
-- =========================
INSERT INTO code_item (code_group_id, item_key, name, sort_order, is_active) VALUES
(@G_EVENT_TYPE, 'SENSOR_FAIL',      '센서 장애', 10, 1),
(@G_EVENT_TYPE, 'NO_SIGNAL',        '신호 미수신', 20, 1),
(@G_EVENT_TYPE, 'OVER_THRESHOLD',   '임계치 초과', 30, 1),
(@G_EVENT_TYPE, 'DEVICE_RESTART',   '장비 재시작', 40, 1),
(@G_EVENT_TYPE, 'POWER_ISSUE',      '전원 이슈', 50, 1),
(@G_EVENT_TYPE, 'NETWORK_ISSUE',    '네트워크 이슈', 60, 1);

-- =========================
-- 8) CASE_STATUS
-- =========================
INSERT INTO code_item (code_group_id, item_key, name, sort_order, is_active) VALUES
(@G_CASE_STATUS, 'NEW',         '신규', 10, 1),
(@G_CASE_STATUS, 'IN_PROGRESS', '처리중', 20, 1),
(@G_CASE_STATUS, 'ON_HOLD',     '보류', 30, 1),
(@G_CASE_STATUS, 'RESOLVED',    '완료', 40, 1);

-- =========================
-- 9) CASE_CAUSE
-- =========================
INSERT INTO code_item (code_group_id, item_key, name, sort_order, is_active) VALUES
(@G_CASE_CAUSE, 'NETWORK', '네트워크', 10, 1),
(@G_CASE_CAUSE, 'POWER',   '전원', 20, 1),
(@G_CASE_CAUSE, 'DEVICE',  '장비', 30, 1),
(@G_CASE_CAUSE, 'CONFIG',  '설정', 40, 1),
(@G_CASE_CAUSE, 'UNKNOWN', '미상', 99, 1);

-- =========================
-- 10) CASE_ACTION
-- =========================
INSERT INTO code_item (code_group_id, item_key, name, sort_order, is_active) VALUES
(@G_CASE_ACTION, 'REBOOT',     '재부팅', 10, 1),
(@G_CASE_ACTION, 'REPLACE',    '교체', 20, 1),
(@G_CASE_ACTION, 'PATCH',      '패치/업데이트', 30, 1),
(@G_CASE_ACTION, 'RECONFIG',   '재설정', 40, 1),
(@G_CASE_ACTION, 'CONTACTED',  '연락/안내', 50, 1);

-- =========================
-- 11) NOTIFICATION_CHANNEL
-- =========================
INSERT INTO code_item (code_group_id, item_key, name, sort_order, is_active) VALUES
(@G_NOTI_CH, 'EMAIL', '이메일', 10, 1),
(@G_NOTI_CH, 'SMS',   '문자', 20, 0),
(@G_NOTI_CH, 'PUSH',  '푸시', 30, 0);

COMMIT;
