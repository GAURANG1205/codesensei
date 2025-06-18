package com.Gaurang.AiCodeReviewApp.Controller;

import com.Gaurang.AiCodeReviewApp.Repository.CodeReviewRepository;
import com.Gaurang.AiCodeReviewApp.Service.AiService;
import com.Gaurang.AiCodeReviewApp.dto.CodeRequest;
import com.Gaurang.AiCodeReviewApp.entity.codeReview;
import org.aspectj.apache.bcel.classfile.Code;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/review")
public class CodeReviewController {

    @Autowired private AiService aiService;
    @Autowired
    private CodeReviewRepository reviewRepository;

    @PostMapping("/summary")
    public ResponseEntity<String> getSummary(@RequestBody CodeRequest request) {
        return ResponseEntity.ok(aiService.generateSummary(request.getCode()));
    }
    @PostMapping("/code_review")
    public ResponseEntity<Map<String, Object>> reviewCode(@RequestBody Map<String, String> request) {
        String code = request.get("code");
        if (code == null || code.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of(
                    "error", "Code cannot be empty"
            ));
        }
        Map<String, Object> result = aiService.generateReview(code);
        return ResponseEntity.ok(result);
    }
    @PostMapping("/save")
    public ResponseEntity<codeReview> saveReview(@RequestBody codeReview review) {
        review.setReviewedOn(LocalDate.now());
        codeReview saved = reviewRepository.save(review);
        return ResponseEntity.ok(saved);
    }
    @GetMapping("/user/{userId}")
    public List<codeReview> getUserReviews(@PathVariable String userId) {
        return reviewRepository.findByUserId(userId);
    }
    @PutMapping("/update/{id}")
    public ResponseEntity<codeReview> updateReview(@PathVariable Long id, @RequestBody codeReview updated) {
        codeReview existing = reviewRepository.findById(id).orElseThrow();
        existing.setCode(updated.getCode());
        existing.setRating(updated.getRating());
        existing.setSummary(updated.getSummary());
        existing.setStatus(updated.getStatus());
        existing.setReviewedOn(LocalDate.from(LocalDateTime.now()));
        return ResponseEntity.ok(reviewRepository.save(existing));
    }
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deleteReview(@PathVariable Long id) {
        reviewRepository.deleteById(id);
        return ResponseEntity.ok("Review deleted successfully.");
    }

}


