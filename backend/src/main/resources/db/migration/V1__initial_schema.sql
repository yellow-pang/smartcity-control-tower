-- V1__initial_schema.sql (MariaDB / InnoDB / utf8mb4)
-- 스마트시티 운영 관제 컨트롤타워 - 초기 DDL
-- 실행 순서: Flyway가 자동 관리
-- 주의: created_by/updated_by는 순환 FK 방지를 위해 FK를 걸지 않고 BIGINT 컬럼만 둡니다.

SET NAMES utf8mb4;

-- =========================
-- 1) 공통 코드
-- =========================
CREATE TABLE code_group (
  code_group_id BIGINT NOT NULL AUTO_INCREMENT,
  group_key VARCHAR(50) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255) NULL,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (code_group_id),
  UNIQUE KEY uq_code_group_group_key (group_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE code_item (
  code_item_id BIGINT NOT NULL AUTO_INCREMENT,
  code_group_id BIGINT NOT NULL,
  item_key VARCHAR(50) NOT NULL,
  name VARCHAR(100) NOT NULL,
  sort_order INT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (code_item_id),
  UNIQUE KEY uq_code_item_group_item (code_group_id, item_key),
  KEY ix_code_item_group (code_group_id),

  CONSTRAINT fk_code_item_group
    FOREIGN KEY (code_group_id) REFERENCES code_group(code_group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- 2) 사용자 / 권한(RBAC)
-- =========================
CREATE TABLE app_user (
  user_id BIGINT NOT NULL AUTO_INCREMENT,
  email VARCHAR(200) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  last_login_at DATETIME(3) NULL,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  created_by BIGINT NULL,
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  updated_by BIGINT NULL,
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (user_id),
  UNIQUE KEY uq_app_user_email (email),
  KEY ix_app_user_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE role (
  role_id BIGINT NOT NULL AUTO_INCREMENT,
  role_key VARCHAR(50) NOT NULL,
  name VARCHAR(100) NOT NULL,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (role_id),
  UNIQUE KEY uq_role_role_key (role_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE permission (
  permission_id BIGINT NOT NULL AUTO_INCREMENT,
  perm_key VARCHAR(80) NOT NULL,
  name VARCHAR(120) NOT NULL,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (permission_id),
  UNIQUE KEY uq_permission_perm_key (perm_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_role (
  user_role_id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  role_id BIGINT NOT NULL,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (user_role_id),
  UNIQUE KEY uq_user_role (user_id, role_id),
  KEY ix_user_role_user (user_id),
  KEY ix_user_role_role (role_id),

  CONSTRAINT fk_user_role_user
    FOREIGN KEY (user_id) REFERENCES app_user(user_id),
  CONSTRAINT fk_user_role_role
    FOREIGN KEY (role_id) REFERENCES role(role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE role_permission (
  role_permission_id BIGINT NOT NULL AUTO_INCREMENT,
  role_id BIGINT NOT NULL,
  permission_id BIGINT NOT NULL,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (role_permission_id),
  UNIQUE KEY uq_role_permission (role_id, permission_id),
  KEY ix_role_permission_role (role_id),
  KEY ix_role_permission_perm (permission_id),

  CONSTRAINT fk_role_permission_role
    FOREIGN KEY (role_id) REFERENCES role(role_id),
  CONSTRAINT fk_role_permission_permission
    FOREIGN KEY (permission_id) REFERENCES permission(permission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- 3) 구역 / 관제 대상
-- =========================
CREATE TABLE zone (
  zone_id BIGINT NOT NULL AUTO_INCREMENT,
  parent_zone_id BIGINT NULL,
  zone_code VARCHAR(50) NOT NULL,
  name VARCHAR(100) NOT NULL,
  center_lat DECIMAL(10,7) NULL,
  center_lng DECIMAL(10,7) NULL,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  created_by BIGINT NULL,
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  updated_by BIGINT NULL,
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (zone_id),
  UNIQUE KEY uq_zone_code (zone_code),
  KEY ix_zone_parent (parent_zone_id),

  CONSTRAINT fk_zone_parent
    FOREIGN KEY (parent_zone_id) REFERENCES zone(zone_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE target (
  target_id BIGINT NOT NULL AUTO_INCREMENT,
  zone_id BIGINT NOT NULL,
  target_code VARCHAR(80) NOT NULL,
  name VARCHAR(120) NOT NULL,

  target_type_code_item_id BIGINT NULL,  -- CODE: TARGET_TYPE
  status_code_item_id BIGINT NULL,       -- CODE: TARGET_STATUS

  lat DECIMAL(10,7) NULL,
  lng DECIMAL(10,7) NULL,
  address VARCHAR(255) NULL,
  last_seen_at DATETIME(3) NULL,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  created_by BIGINT NULL,
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  updated_by BIGINT NULL,
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (target_id),
  UNIQUE KEY uq_target_code (target_code),
  KEY ix_target_zone_status (zone_id, status_code_item_id),
  KEY ix_target_type (target_type_code_item_id),
  KEY ix_target_last_seen (last_seen_at),

  CONSTRAINT fk_target_zone
    FOREIGN KEY (zone_id) REFERENCES zone(zone_id),
  CONSTRAINT fk_target_type_code
    FOREIGN KEY (target_type_code_item_id) REFERENCES code_item(code_item_id),
  CONSTRAINT fk_target_status_code
    FOREIGN KEY (status_code_item_id) REFERENCES code_item(code_item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE target_status_history (
  target_status_history_id BIGINT NOT NULL AUTO_INCREMENT,
  target_id BIGINT NOT NULL,
  from_status_code_item_id BIGINT NULL,
  to_status_code_item_id BIGINT NOT NULL,
  changed_at DATETIME(3) NOT NULL,
  changed_by BIGINT NULL,
  reason VARCHAR(255) NULL,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (target_status_history_id),
  KEY ix_target_status_hist_target_time (target_id, changed_at DESC),

  CONSTRAINT fk_tsh_target
    FOREIGN KEY (target_id) REFERENCES target(target_id),
  CONSTRAINT fk_tsh_from_status
    FOREIGN KEY (from_status_code_item_id) REFERENCES code_item(code_item_id),
  CONSTRAINT fk_tsh_to_status
    FOREIGN KEY (to_status_code_item_id) REFERENCES code_item(code_item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- 4) 케이스 / 이벤트
-- =========================
CREATE TABLE case_ticket (
  case_id BIGINT NOT NULL AUTO_INCREMENT,
  zone_id BIGINT NOT NULL,
  target_id BIGINT NULL,
  primary_event_id BIGINT NULL,

  title VARCHAR(200) NOT NULL,
  description TEXT NULL,

  status_code_item_id BIGINT NOT NULL,     -- CODE: CASE_STATUS
  severity_code_item_id BIGINT NOT NULL,   -- CODE: EVENT_SEVERITY 재사용(권장)

  assignee_user_id BIGINT NULL,

  opened_at DATETIME(3) NOT NULL,
  resolved_at DATETIME(3) NULL,

  cause_code_item_id BIGINT NULL,          -- CODE: CASE_CAUSE
  action_code_item_id BIGINT NULL,         -- CODE: CASE_ACTION
  sla_due_at DATETIME(3) NULL,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  created_by BIGINT NULL,
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  updated_by BIGINT NULL,
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (case_id),

  KEY ix_case_zone_status_opened (zone_id, status_code_item_id, opened_at DESC),
  KEY ix_case_status_opened (status_code_item_id, opened_at DESC),
  KEY ix_case_severity_opened (severity_code_item_id, opened_at DESC),
  KEY ix_case_assignee_status (assignee_user_id, status_code_item_id),
  KEY ix_case_target_opened (target_id, opened_at DESC),
  KEY ix_case_resolved (resolved_at),

  CONSTRAINT fk_case_zone
    FOREIGN KEY (zone_id) REFERENCES zone(zone_id),
  CONSTRAINT fk_case_target
    FOREIGN KEY (target_id) REFERENCES target(target_id),
  CONSTRAINT fk_case_status_code
    FOREIGN KEY (status_code_item_id) REFERENCES code_item(code_item_id),
  CONSTRAINT fk_case_severity_code
    FOREIGN KEY (severity_code_item_id) REFERENCES code_item(code_item_id),
  CONSTRAINT fk_case_assignee
    FOREIGN KEY (assignee_user_id) REFERENCES app_user(user_id),
  CONSTRAINT fk_case_cause_code
    FOREIGN KEY (cause_code_item_id) REFERENCES code_item(code_item_id),
  CONSTRAINT fk_case_action_code
    FOREIGN KEY (action_code_item_id) REFERENCES code_item(code_item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE event_log (
  event_id BIGINT NOT NULL AUTO_INCREMENT,
  target_id BIGINT NOT NULL,

  event_type_code_item_id BIGINT NOT NULL,  -- CODE: EVENT_TYPE
  severity_code_item_id BIGINT NOT NULL,    -- CODE: EVENT_SEVERITY
  status_code_item_id BIGINT NULL,          -- CODE: EVENT_STATUS (선택)

  occurred_at DATETIME(3) NOT NULL,
  received_at DATETIME(3) NOT NULL,

  lat DECIMAL(10,7) NULL,
  lng DECIMAL(10,7) NULL,

  payload_json JSON NULL,
  case_id BIGINT NULL,  -- 케이스 승격 시 연결

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  created_by BIGINT NULL,
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  updated_by BIGINT NULL,
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (event_id),

  KEY ix_event_occurred (occurred_at DESC),
  KEY ix_event_target_occurred (target_id, occurred_at DESC),
  KEY ix_event_type_occurred (event_type_code_item_id, occurred_at DESC),
  KEY ix_event_severity_occurred (severity_code_item_id, occurred_at DESC),
  KEY ix_event_case (case_id),

  CONSTRAINT fk_event_target
    FOREIGN KEY (target_id) REFERENCES target(target_id),
  CONSTRAINT fk_event_type_code
    FOREIGN KEY (event_type_code_item_id) REFERENCES code_item(code_item_id),
  CONSTRAINT fk_event_severity_code
    FOREIGN KEY (severity_code_item_id) REFERENCES code_item(code_item_id),
  CONSTRAINT fk_event_status_code
    FOREIGN KEY (status_code_item_id) REFERENCES code_item(code_item_id),
  CONSTRAINT fk_event_case
    FOREIGN KEY (case_id) REFERENCES case_ticket(case_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- primary_event_id는 event_log 생성 후 FK 추가(순서 문제 해결)
ALTER TABLE case_ticket
  ADD CONSTRAINT fk_case_primary_event
  FOREIGN KEY (primary_event_id) REFERENCES event_log(event_id);

CREATE TABLE case_status_history (
  case_status_history_id BIGINT NOT NULL AUTO_INCREMENT,
  case_id BIGINT NOT NULL,
  from_status_code_item_id BIGINT NULL,
  to_status_code_item_id BIGINT NOT NULL,
  changed_at DATETIME(3) NOT NULL,
  changed_by BIGINT NOT NULL,
  memo VARCHAR(255) NULL,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (case_status_history_id),
  KEY ix_case_status_hist_case_time (case_id, changed_at DESC),

  CONSTRAINT fk_csh_case
    FOREIGN KEY (case_id) REFERENCES case_ticket(case_id),
  CONSTRAINT fk_csh_from_status
    FOREIGN KEY (from_status_code_item_id) REFERENCES code_item(code_item_id),
  CONSTRAINT fk_csh_to_status
    FOREIGN KEY (to_status_code_item_id) REFERENCES code_item(code_item_id),
  CONSTRAINT fk_csh_changed_by
    FOREIGN KEY (changed_by) REFERENCES app_user(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE case_assignment_history (
  case_assignment_history_id BIGINT NOT NULL AUTO_INCREMENT,
  case_id BIGINT NOT NULL,
  from_user_id BIGINT NULL,
  to_user_id BIGINT NULL,
  changed_at DATETIME(3) NOT NULL,
  changed_by BIGINT NOT NULL,
  memo VARCHAR(255) NULL,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (case_assignment_history_id),
  KEY ix_case_assign_hist_case_time (case_id, changed_at DESC),
  KEY ix_case_assign_hist_to_user_time (to_user_id, changed_at DESC),

  CONSTRAINT fk_cah_case
    FOREIGN KEY (case_id) REFERENCES case_ticket(case_id),
  CONSTRAINT fk_cah_from_user
    FOREIGN KEY (from_user_id) REFERENCES app_user(user_id),
  CONSTRAINT fk_cah_to_user
    FOREIGN KEY (to_user_id) REFERENCES app_user(user_id),
  CONSTRAINT fk_cah_changed_by
    FOREIGN KEY (changed_by) REFERENCES app_user(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE case_comment (
  case_comment_id BIGINT NOT NULL AUTO_INCREMENT,
  case_id BIGINT NOT NULL,
  author_user_id BIGINT NOT NULL,
  comment TEXT NOT NULL,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  created_by BIGINT NULL,
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  updated_by BIGINT NULL,
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (case_comment_id),
  KEY ix_case_comment_case_time (case_id, created_at DESC),

  CONSTRAINT fk_case_comment_case
    FOREIGN KEY (case_id) REFERENCES case_ticket(case_id),
  CONSTRAINT fk_case_comment_author
    FOREIGN KEY (author_user_id) REFERENCES app_user(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE case_attachment (
  case_attachment_id BIGINT NOT NULL AUTO_INCREMENT,
  case_id BIGINT NOT NULL,
  uploader_user_id BIGINT NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_url VARCHAR(500) NOT NULL,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  created_by BIGINT NULL,
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  updated_by BIGINT NULL,
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (case_attachment_id),
  KEY ix_case_attach_case_time (case_id, created_at DESC),

  CONSTRAINT fk_case_attach_case
    FOREIGN KEY (case_id) REFERENCES case_ticket(case_id),
  CONSTRAINT fk_case_attach_uploader
    FOREIGN KEY (uploader_user_id) REFERENCES app_user(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- 5) 알림(이메일) + 보안
-- =========================
CREATE TABLE notification_template (
  template_id BIGINT NOT NULL AUTO_INCREMENT,
  channel_code_item_id BIGINT NOT NULL, -- CODE: NOTIFICATION_CHANNEL
  template_key VARCHAR(80) NOT NULL,
  subject VARCHAR(200) NOT NULL,
  body TEXT NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  created_by BIGINT NULL,
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  updated_by BIGINT NULL,
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (template_id),
  UNIQUE KEY uq_notification_template_key (template_key),
  KEY ix_notification_template_channel (channel_code_item_id),

  CONSTRAINT fk_notification_template_channel
    FOREIGN KEY (channel_code_item_id) REFERENCES code_item(code_item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notification_send (
  notification_send_id BIGINT NOT NULL AUTO_INCREMENT,
  channel_code_item_id BIGINT NOT NULL, -- EMAIL
  template_id BIGINT NULL,

  related_case_id BIGINT NULL,
  related_event_id BIGINT NULL,

  recipient VARCHAR(200) NOT NULL,
  subject VARCHAR(200) NOT NULL,
  body TEXT NOT NULL,

  send_status VARCHAR(20) NOT NULL, -- SUCCESS / FAIL
  fail_reason VARCHAR(255) NULL,
  sent_at DATETIME(3) NOT NULL,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  created_by BIGINT NULL,
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  updated_by BIGINT NULL,
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (notification_send_id),

  KEY ix_notification_send_sent_at (sent_at DESC),
  KEY ix_notification_send_recipient_time (recipient, sent_at DESC),
  KEY ix_notification_send_case_time (related_case_id, sent_at DESC),
  KEY ix_notification_send_status_time (send_status, sent_at DESC),

  CONSTRAINT fk_notification_send_channel
    FOREIGN KEY (channel_code_item_id) REFERENCES code_item(code_item_id),
  CONSTRAINT fk_notification_send_template
    FOREIGN KEY (template_id) REFERENCES notification_template(template_id),
  CONSTRAINT fk_notification_send_case
    FOREIGN KEY (related_case_id) REFERENCES case_ticket(case_id),
  CONSTRAINT fk_notification_send_event
    FOREIGN KEY (related_event_id) REFERENCES event_log(event_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE email_security_result (
  email_security_result_id BIGINT NOT NULL AUTO_INCREMENT,
  notification_send_id BIGINT NOT NULL,

  sender_domain VARCHAR(200) NULL,
  domain_allowed TINYINT(1) NOT NULL DEFAULT 1,

  risk_score INT NOT NULL DEFAULT 0,  -- 0~100
  risk_reason VARCHAR(255) NULL,
  extracted_urls JSON NULL,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (email_security_result_id),
  UNIQUE KEY uq_email_security_send (notification_send_id),
  KEY ix_email_security_risk (risk_score),

  CONSTRAINT fk_email_security_send
    FOREIGN KEY (notification_send_id) REFERENCES notification_send(notification_send_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE email_domain_allowlist (
  allowlist_id BIGINT NOT NULL AUTO_INCREMENT,
  domain VARCHAR(200) NOT NULL,
  description VARCHAR(255) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  created_by BIGINT NULL,
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  updated_by BIGINT NULL,
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (allowlist_id),
  UNIQUE KEY uq_allowlist_domain (domain),
  KEY ix_allowlist_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- 6) 감사 로그
-- =========================
CREATE TABLE audit_log (
  audit_log_id BIGINT NOT NULL AUTO_INCREMENT,
  actor_user_id BIGINT NULL,

  action VARCHAR(80) NOT NULL,         -- LOGIN, CASE_STATUS_CHANGE 등
  resource_type VARCHAR(50) NOT NULL,  -- CASE, EVENT, USER, NOTIFICATION 등
  resource_id BIGINT NULL,

  summary VARCHAR(255) NOT NULL,
  detail_json JSON NULL,

  ip_address VARCHAR(45) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (audit_log_id),

  KEY ix_audit_created_at (created_at DESC),
  KEY ix_audit_actor_time (actor_user_id, created_at DESC),
  KEY ix_audit_action_time (action, created_at DESC),
  KEY ix_audit_resource (resource_type, resource_id),

  CONSTRAINT fk_audit_actor
    FOREIGN KEY (actor_user_id) REFERENCES app_user(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- 7) 저장 필터(선택)
-- =========================
CREATE TABLE saved_filter (
  saved_filter_id BIGINT NOT NULL AUTO_INCREMENT,
  owner_user_id BIGINT NOT NULL,
  scope VARCHAR(20) NOT NULL,        -- PERSONAL / SHARED
  target_screen VARCHAR(50) NOT NULL, -- CASE_LIST 등
  name VARCHAR(100) NOT NULL,
  filter_json JSON NOT NULL,

  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  created_by BIGINT NULL,
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  updated_by BIGINT NULL,
  deleted_at DATETIME(3) NULL,

  PRIMARY KEY (saved_filter_id),
  KEY ix_saved_filter_owner_screen (owner_user_id, target_screen),

  CONSTRAINT fk_saved_filter_owner
    FOREIGN KEY (owner_user_id) REFERENCES app_user(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
