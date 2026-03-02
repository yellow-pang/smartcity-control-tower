package com.yellowpang.backend.common;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.LocalDateTime;

/**
 * 공통 API 응답 포맷
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {

    private Integer code;
    private String message;
    private T data;
    private LocalDateTime timestamp;

    // 성공 응답
    public static <T> ApiResponse<T> success(T data) {
        return ApiResponse.<T>builder()
                .code(200)
                .message("Success")
                .data(data)
                .timestamp(LocalDateTime.now())
                .build();
    }

    // 성공 응답 (데이터 없음)
    public static ApiResponse<Void> success() {
        return ApiResponse.<Void>builder()
                .code(200)
                .message("Success")
                .timestamp(LocalDateTime.now())
                .build();
    }

    // 에러 응답
    public static ApiResponse<Void> error(Integer code, String message) {
        return ApiResponse.<Void>builder()
                .code(code)
                .message(message)
                .timestamp(LocalDateTime.now())
                .build();
    }

    // 에러 응답 + 데이터
    public static <T> ApiResponse<T> error(Integer code, String message, T data) {
        return ApiResponse.<T>builder()
                .code(code)
                .message(message)
                .data(data)
                .timestamp(LocalDateTime.now())
                .build();
    }
}
