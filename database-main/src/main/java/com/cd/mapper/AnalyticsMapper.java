package com.cd.mapper;

import com.cd.dto.AnalyticsDistributionItemResponse;
import com.cd.dto.AnalyticsRankingItemResponse;
import com.cd.dto.ScoreAnalyticsOverviewResponse;
import com.cd.dto.SensitiveCoverageItemResponse;
import com.cd.dto.SensitiveVisibilitySampleResponse;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface AnalyticsMapper {

    ScoreAnalyticsOverviewResponse selectScoreOverview();

    List<AnalyticsRankingItemResponse> selectCollegeAverageRanking(@Param("limit") int limit);

    List<AnalyticsRankingItemResponse> selectMajorAverageRanking(@Param("limit") int limit);

    List<AnalyticsRankingItemResponse> selectCourseAverageRanking(@Param("limit") int limit);

    List<AnalyticsDistributionItemResponse> selectScoreDistribution();

    List<SensitiveCoverageItemResponse> selectSensitiveCoverage();

    List<SensitiveVisibilitySampleResponse> selectSensitiveVisibilitySamples(@Param("roleId") Long roleId);
}
