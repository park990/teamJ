package com.teamj.enums;

/**
 * 모임 참가자 역할 Enum
 * - HOST: 모임 방장 (생성자, 삭제 권한)
 * - GUEST: 일반 참가자 (나가기 권한)
 */
public enum ParticipantRole {
    HOST("HOST"),
    GUEST("GUEST");

    private final String value;

    ParticipantRole(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }

    /**
     * String 값으로 Enum 찾기
     */
    public static ParticipantRole fromValue(String value) {
        for (ParticipantRole role : ParticipantRole.values()) {
            if (role.value.equals(value)) {
                return role;
            }
        }
        throw new IllegalArgumentException("Unknown role: " + value);
    }
}
