package com.Gaurang.AiCodeReviewApp.Controller;

import com.Gaurang.AiCodeReviewApp.Service.AiService;
import com.Gaurang.AiCodeReviewApp.dto.CodeRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/review")
public class CodeReviewController {

    @Autowired private AiService aiService;

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
}


