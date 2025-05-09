package com.Gaurang.AiCodeReviewApp.Service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
@Component
public class AiService {

    @Autowired
    private GeminiService geminiService;
    @Autowired
    private GroqService groqService;
    @Autowired
    private DeepSeekService deepSeekService;

    public String generateSummary(String code) {
        String prompt = "Short Summarize the following code:\n" + code;

        try {
            return geminiService.getSummary(prompt);
        } catch (Exception e) {
            System.out.println("Gemini failed: " + e.getMessage());
        }

        try {
            return groqService.getSummary(prompt);
        } catch (Exception e) {
            System.out.println("Groq failed: " + e.getMessage());
        }

        try {
            return deepSeekService.getSummary(prompt);
        } catch (Exception e) {
            System.out.println("DeepSeek failed: " + e.getMessage());
        }

        return "All AI APIs failed.";
    }
    public List<Map<String, String>> generateReview(String code) {
        String prompt = "Review the following code and provide issues and fixes Only in the following format:\n" +
                "Type: <Error or Suggestion Only>\nMessage: <explanation>\nFix: <fix>\n---\nCode:\n" + code;

        String rawResponse = null;
        try {
            rawResponse = geminiService.getSummary(prompt);
        } catch (Exception e) {
            System.out.println("Gemini failed: " + e.getMessage());
        }

        if (rawResponse == null) {
            try {
                rawResponse = groqService.getSummary(prompt);
            } catch (Exception e) {
                System.out.println("Groq failed: " + e.getMessage());
            }
        }

        if (rawResponse == null) {
            try {
                rawResponse = deepSeekService.getSummary(prompt);
            } catch (Exception e) {
                System.out.println("DeepSeek failed: " + e.getMessage());
            }
        }

        if (rawResponse == null) {
            return List.of(Map.of("type", "Error", "message", "All AI services failed", "fix", "Please try again later"));
        }

        return parseResponse(rawResponse);
    }

    private List<Map<String, String>> parseResponse(String raw) {
        List<Map<String, String>> suggestions = new ArrayList<>();

        String[] parts = raw.split("(?=Type: )");

        for (String part : parts) {
            if (!part.trim().isEmpty()) {
                String type = extractField(part, "Type:");
                String message = extractField(part, "Message:");
                String fix = extractField(part, "Fix:");

                if (type != null && message != null && fix != null) {
                    suggestions.add(Map.of(
                            "type", type.trim(),
                            "message", message.trim(),
                            "fix", fix.trim()
                    ));
                }
            }
        }

        return suggestions;
    }

    private String extractField(String text, String field) {
        int start = text.indexOf(field);
        if (start == -1) return null;

        int end = text.indexOf("\n", start + field.length());
        if (end == -1) end = text.length();

        return text.substring(start + field.length(), end).trim();
    }
}
