package com.greetings;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;

@RestController
@RequestMapping("/api/v1")
public class GreetingsController {
    
    @GetMapping("/status")
    public String getStatus() {
        return "API is working smoothly!";
    }
}
