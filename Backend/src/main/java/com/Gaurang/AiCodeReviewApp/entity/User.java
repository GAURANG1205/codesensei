package com.Gaurang.AiCodeReviewApp.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;
@Data
@Entity
@Table(name = "users")
public class User {

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;
        private String email;
        private String username;
        private String password;
        private  String Provider;
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}

