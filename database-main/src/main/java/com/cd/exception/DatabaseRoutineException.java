package com.cd.exception;

public class DatabaseRoutineException extends RuntimeException {

    private final int statusCode;
    private final String sqlState;

    public DatabaseRoutineException(int statusCode, String sqlState, String message, Throwable cause) {
        super(message, cause);
        this.statusCode = statusCode;
        this.sqlState = sqlState;
    }

    public int getStatusCode() {
        return statusCode;
    }

    public String getSqlState() {
        return sqlState;
    }
}
