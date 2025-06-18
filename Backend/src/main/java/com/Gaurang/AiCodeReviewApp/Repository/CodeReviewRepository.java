package com.Gaurang.AiCodeReviewApp.Repository;

import com.Gaurang.AiCodeReviewApp.entity.codeReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
@Repository
public interface CodeReviewRepository extends JpaRepository<codeReview,Long> {
List<codeReview> findByUserId(String userId);
}
