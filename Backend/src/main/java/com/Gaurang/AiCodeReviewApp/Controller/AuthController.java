package com.Gaurang.AiCodeReviewApp.Controller;

import com.Gaurang.AiCodeReviewApp.Service.AuthService;
import com.Gaurang.AiCodeReviewApp.dto.AuthResponse;
import com.Gaurang.AiCodeReviewApp.dto.LoginRequestDTO;
import com.Gaurang.AiCodeReviewApp.dto.SignupRequestDTO;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/signup")
    public ResponseEntity<AuthResponse> signup(@RequestBody SignupRequestDTO request) {
        return ResponseEntity.ok(authService.signup(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequestDTO request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/google")
    public ResponseEntity<AuthResponse> googleLogin(@RequestParam String email, @RequestParam String username) {
        AuthResponse response= authService.googleLogin(email, username);
        return ResponseEntity.ok(response);
    }
}
