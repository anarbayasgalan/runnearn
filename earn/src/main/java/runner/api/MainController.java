package runner.api;

import runner.request.*;
import runner.db.Company;
import runner.service.MainService;
import runner.service.RedisService;
import runner.repositories.TokenRepository;
import runner.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api")
public class MainController {

    @Autowired
    private MainService service;

    @Autowired
    private RedisService redisService;

    @Autowired
    private TokenRepository tokenRepository;

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/registerUser")
    public RegisterRes registerUser(@RequestBody RegisterReq req) {
        return service.registerUser(req);
    }

    @PostMapping("/login")
    public LoginRes login(@RequestBody LoginReq req) {
        return service.login(req);
    }

    @PostMapping("/login/social")
    public LoginRes loginSocial(@RequestBody LoginSocialReq req) {
        return service.loginSocial(req);
    }

    @GetMapping("/home")
    public GetCurrentUserRes getCurrentUser() {
        return service.getCurrentUser();
    }

    @GetMapping("/me")
    public GetCurrentUserRes getMe() {
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
    public java.util.List<GetTokenRes> getTokens() {
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

    @GetMapping("/challenges")
    public java.util.List<GetActiveChallengeRes> getActiveChallenges() {
        return service.getActiveChallenges();
    }

    @PostMapping("/challenge/accept")
    public GenericResponse acceptChallenge(@RequestBody AcceptChallengeReq req) {
        return service.acceptChallenge(req);
    }

    @GetMapping("/my-rewards")
    public java.util.List<GetTokenRes> getMyRewards() {
        return service.getMyRewards();
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            redisService.deleteSession(token);
        }
        return ResponseEntity.ok().build();
    }

    @GetMapping("/leaderboard")
    public List<Map<String, Object>> getLeaderboard() {
        List<Object[]> rows = tokenRepository.findLeaderboard();
        List<Map<String, Object>> result = new ArrayList<>();
        int rank = 1;
        for (Object[] row : rows) {
            String userId = (String) row[0];
            long count = (Long) row[1];

            // Get display name (username/email) from User table
            String displayName = userId;
            try {
                var user = userRepository.findById(userId);
                if (user.isPresent())
                    displayName = user.get().getUserName();
            } catch (Exception ignored) {
            }

            Map<String, Object> entry = new LinkedHashMap<>();
            entry.put("rank", rank++);
            entry.put("userId", userId);
            entry.put("displayName", displayName);
            entry.put("tokenCount", count);
            result.add(entry);
        }
        return result;
    }
}
