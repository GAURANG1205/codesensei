package com.Gaurang.AiCodeReviewApp.dto;


import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class SignupRequestDTO {

    private String email;
    private String username;
    private String password;
}
