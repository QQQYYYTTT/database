package com.cd.dto;

public class ScoreAnalyticsOverviewResponse {

    private Long totalStudents;
    private Long totalScoreRecords;
    private Long semesterCount;
    private Double averageScore;
    private Double passRate;

    public Long getTotalStudents() {
        return totalStudents;
    }

    public void setTotalStudents(Long totalStudents) {
        this.totalStudents = totalStudents;
    }

    public Long getTotalScoreRecords() {
        return totalScoreRecords;
    }

    public void setTotalScoreRecords(Long totalScoreRecords) {
        this.totalScoreRecords = totalScoreRecords;
    }

    public Long getSemesterCount() {
        return semesterCount;
    }

    public void setSemesterCount(Long semesterCount) {
        this.semesterCount = semesterCount;
    }

    public Double getAverageScore() {
        return averageScore;
    }

    public void setAverageScore(Double averageScore) {
        this.averageScore = averageScore;
    }

    public Double getPassRate() {
        return passRate;
    }

    public void setPassRate(Double passRate) {
        this.passRate = passRate;
    }
}
