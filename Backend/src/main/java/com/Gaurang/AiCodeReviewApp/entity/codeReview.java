package com.Gaurang.AiCodeReviewApp.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;
@Data
@Entity
public class codeReview {
    @Id
    @GeneratedValue(strategy =  GenerationType.IDENTITY)
    private Long id;
    private String status;
    private  String fileName;
    @Column(length = 20000)
    private String code;
    private String userId;
    @Column(length = 5000)
    private  String summary;
    private int rating;
    private LocalDate reviewedOn;
}
