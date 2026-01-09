package dev.ailuruslabs.emmaserver.user;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/register")
public class RegisterController {

    @GetMapping("/confirmed")
    String showConfirmationMessage() {
        return """
            <html>
              <body style="font-family: sans-serif; text-align: center; padding-top: 50px;">
                <h1>Email Verified!</h1>
                <p>You may now return to the app to log in.</p>
              </body>
            </html>
            """;
    }
}
