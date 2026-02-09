package runner.api;

import runner.request.*;
import runner.db.User;
import runner.db.Company;
import runner.db.Token;
import runner.service.MainService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api")
public class MainController {

    @Autowired
    private MainService service;

    @PostMapping("/registerUser")
    public RegisterRes registerUser(@RequestBody RegisterReq req) {
        return service.registerUser(req);
    }

    @PostMapping("/login")
    public LoginRes login(@RequestBody LoginReq req) {
        return service.login(req);
    }

    @GetMapping("/home")
    public User getCurrentUser() {
        return service.getCurrentUser();
    }

    @GetMapping("/me")
    public User getMe() {
        return service.getCurrentUser();
    }

    @PostMapping("/updateCompany")
    public UpdateCompanyRes updateCompany(@RequestBody UpdateCompanyReq req) {
        return service.updateCompany(req);
    }

    @GetMapping("/company")
    public Company getCompany() {
        return service.getCompany();
    }

    @PostMapping("/updateUserCred")
    public CreateUserCredRes updateUserCred(@RequestBody CreateUserCredReq req) {
        return service.updateUserCred(req);
    }

    @PostMapping("/token/generate")
    public GenerateTokenRes generateToken(@RequestBody GenerateTokenReq req) {
        return service.generateToken(req);
    }

    @PostMapping("/token/redeem")
    public CheckAndRedeemTokenRes checkAndRedeemToken(@RequestBody CheckAndRedeemTokenReq req) {
        return service.checkAndRedeemToken(req);
    }

    @GetMapping("/public-key")
    public String getPublicKey() {
        try {
            java.security.PublicKey key = service.getPublicKey();
            return java.util.Base64.getEncoder().encodeToString(key.getEncoded());
        } catch (Exception e) {
            throw new RuntimeException("Failed to get public key", e);
        }
    }

    @GetMapping("/tokens")
    public java.util.List<Token> getTokens() {
        return service.getTokens();
    }

    @PostMapping("/forgot-password/request")
    public GenericResponse requestPasswordReset(@RequestBody ForgotPasswordRequestReq req) {
        return service.requestPasswordReset(req);
    }

    @PostMapping("/forgot-password/verify")
    public GenericResponse verifyOTP(@RequestBody ForgotPasswordVerifyReq req) {
        return service.verifyOTP(req);
    }

    @PostMapping("/forgot-password/reset")
    public GenericResponse resetPassword(@RequestBody ForgotPasswordResetReq req) {
        return service.resetPassword(req);
    }
}
