package com.Gaurang.AiCodeReviewApp.Service;

import com.Gaurang.AiCodeReviewApp.Repository.UserRepository;
import com.Gaurang.AiCodeReviewApp.dto.AuthResponse;
import com.Gaurang.AiCodeReviewApp.dto.LoginRequestDTO;
import com.Gaurang.AiCodeReviewApp.dto.SignupRequestDTO;
import com.Gaurang.AiCodeReviewApp.entity.User;
import com.Gaurang.AiCodeReviewApp.jwt.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final UserRepository userRepository;
    @Autowired
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    public AuthResponse signup(SignupRequestDTO request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("Email already registered");
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setProvider("Basic Auth");
        userRepository.save(user);
        String token = jwtUtil.generateToken(user.getEmail());
        return new AuthResponse(token, user.getEmail(), user.getUsername(), "Basic Auth",user.getId());

    }
    public AuthResponse login(LoginRequestDTO request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("Invalid credentials");
        }
        String token = jwtUtil.generateToken(user.getEmail());
        return new AuthResponse(token, user.getEmail(), user.getUsername(), "local",user.getId());
    }

    public AuthResponse  googleLogin(String email, String username) {
        User user = userRepository.findByEmail(email).orElse(null);
        if (user == null) {
            user = new User();
            user.setEmail(email);
            user.setUsername(username);
            user.setPassword("");
            user.setProvider("Google");
            userRepository.save(user);
        }
        String token = jwtUtil.generateToken(email);
        return new AuthResponse(
                token,
                user.getEmail(),
                user.getUsername(),
                user.getProvider(),
                user.getId()
        );
    }
}

