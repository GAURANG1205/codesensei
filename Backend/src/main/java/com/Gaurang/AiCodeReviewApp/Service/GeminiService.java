package com.Gaurang.AiCodeReviewApp.Service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

@Service
public class GeminiService {

    @Value("${api.gemini.key}")
    private String apiKey;

    public String getSummary(String prompt) {
        RestTemplate restTemplate = new RestTemplate();

        String url = "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=" + apiKey;

        Map<String, Object> content = Map.of(
                "contents", List.of(
                        Map.of("parts", List.of(Map.of("text", prompt)))
                )
        );
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> request = new HttpEntity<>(content, headers);
        ResponseEntity<Map> response = restTemplate.postForEntity(url, request, Map.class);
        List<Map<String, Object>> candidates = (List<Map<String, Object>>) response.getBody().get("candidates");
        Map<String, Object> contentMap = (Map<String, Object>) candidates.get(0).get("content");
        List<Map<String, Object>> parts = (List<Map<String, Object>>) contentMap.get("parts");
        return parts.get(0).get("text").toString();
    }
}

