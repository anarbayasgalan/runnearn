package runner.service;

import org.springframework.security.core.context.SecurityContextHolder;
import runner.exception.RunnerException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import runner.db.*;
import runner.request.*;
import runner.repositories.RunRepository;

import javax.crypto.Cipher;
import java.security.*;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.Base64;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MainService {

    @Autowired
    private ParamService param;
    @Autowired
    PasswordEncoder passwordEncoder;
    @Autowired
    private RunRepository runRepo;

    private static final Logger log = LoggerFactory.getLogger(MainService.class);

    @Transactional
    public RegisterRes registerUser(RegisterReq req) {
        if (!Core.nullOrEmpty(req.getUserName()) && param.findUserByUserName(req.getUserName()) != null) {
            throw new RunnerException(1, "Already user!");
        }

        CreateUserReq user = new CreateUserReq();
        user.setUserName(req.getUserName());
        user.setType(req.getUserType());
        user.setStatus(1);
        user.setCompanyName(req.getCompanyName());
        CreateUserRes u = createUser(user);

        CreateUserCredReq userCred = new CreateUserCredReq();
        userCred.setUserId(u.getUserId());
        userCred.setUserName(req.getUserName());
        userCred.setUserPass(req.getUserPass());
        createUserCred(userCred);

        log.info("User created: " + req.getUserName());

        // Generate session token for auto-login
        String token = generateSession(u.getUserId());

        RegisterRes res = new RegisterRes();
        res.setResponseCode(0);
        res.setResponseDesc("Registration successful");
        res.setSession(token);

        return res;
    }

    public LoginRes login(LoginReq req) {
        // 1. find user
        User u = param.findUserByUserName(req.getUserName());
        Core.validate(u != null, 1, "User not found");

        UserCredPK pk = new UserCredPK();
        pk.setUserName(req.getUserName());
        pk.setUserId(u.getUserId());

        // 2. Find user credentials
        UserCred cred = param.getUserCred(pk);
        Core.validate(cred != null, 2, "UserCred not found");

        // 3. Check password
        Core.validate(passwordEncoder.matches(req.getUserPass(), cred.getUserPass()), 3, "Invalid password");

        // 4. Check client type restrictions
        if ("WEB".equalsIgnoreCase(req.getClientType())) {
            // Web portal is only for ADMIN and COMPANY
            if (!"ADMIN".equalsIgnoreCase(u.getUserType()) && !"COMPANY".equalsIgnoreCase(u.getUserType())) {
                throw new RunnerException(4, "Access Denied: Runners cannot access the Admin Portal");
            }
        } else if ("MOBILE".equalsIgnoreCase(req.getClientType())) {
            // Mobile app is only for Runners
            if ("ADMIN".equalsIgnoreCase(u.getUserType()) || "COMPANY".equalsIgnoreCase(u.getUserType())) {
                throw new RunnerException(4, "Access Denied: Admins cannot use the Runner App");
            }
        }

        // 5. Generate session with user_id
        String token = generateSession(cred.getId().getUserId());

        // 5.response
        LoginRes res = new LoginRes();
        res.setResponseCode(0); // success
        res.setResponseDesc("Login successful");
        res.setSession(token);
        res.setUserType(u.getUserType());

        return res;
    }

    private String generateSession(String userId) {
        UserSession res = new UserSession();

        String session = generateOtt(20);

        res.setSession(session);
        res.setUserId(userId);
        res.setStatus(1);
        // it can be config and make it more dynamic minutes
        res.setExpireDate(Core.getNow().plusMinutes(5));

        param.addUserSession(res);

        return session;
    }

    private CreateUserRes createUser(CreateUserReq req) {
        CreateUserRes res = new CreateUserRes();

        User p = new User();
        p.setUserType(req.getType());
        p.setStatus(1);
        p.setUserName(req.getUserName());
        p.setCompanyName(req.getCompanyName());

        param.createUser(p);
        res.setUserId(p.getUserId());

        return res;
    }

    private CreateUserCredRes createUserCred(CreateUserCredReq req) {
        CreateUserCredRes res = new CreateUserCredRes();

        UserCredPK pk = new UserCredPK();
        pk.setUserId(req.getUserId());
        pk.setUserName(req.getUserName());

        UserCred p = new UserCred();
        p.setId(pk);

        // check password is common? or length?
        p.setUserPass(passwordEncoder.encode(req.getUserPass()));
        param.createUserCred(p);

        res.setResponseDesc("Successfully created password");

        return res;
    }

    public CreateUserCredRes updateUserCred(CreateUserCredReq req) {
        CreateUserCredRes res = new CreateUserCredRes();

        // Get userId from SecurityContext (set by AuthenticationFilter)
        String userId = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        UserCredPK pk = new UserCredPK();
        pk.setUserId(userId);
        pk.setUserName(req.getUserName());

        UserCred p = new UserCred();
        p.setId(pk);
        p.setUserPass(passwordEncoder.encode(req.getUserPass()));
        param.updateUserCred(p);

        return res;
    }

    public GenerateTokenRes generateToken(GenerateTokenReq req) {
        GenerateTokenRes res = new GenerateTokenRes();

        // Get userId from SecurityContext
        String userId = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        // 1. check company user
        User u = param.findUser(userId);
        if (u != null && !Core.nullOrEmpty(u.getCompanyName())) {
            // 2. check password
            UserCredPK pk = new UserCredPK();
            pk.setUserName(u.getUserName());
            pk.setUserId(u.getUserId());

            UserCred cred = param.getUserCred(pk);
            if (cred != null && passwordEncoder.matches(req.getUserPass(), cred.getUserPass())) {
                // 3. Determine quantity (default to 1 if not provided)
                int quantity = (req.getQuantity() != null && req.getQuantity() > 0) ? req.getQuantity() : 1;

                // Limit max quantity to 100 for safety
                if (quantity > 100) {
                    throw new RunnerException(4, "Maximum 100 tokens can be created at once");
                }

                // 4. Generate multiple tokens
                java.util.List<String> tokenCodes = new java.util.ArrayList<>();

                for (int i = 0; i < quantity; i++) {
                    // Generate secure One time token(OTT)
                    String tkn = generateOtt(25);

                    // Save token
                    Token token = new Token();

                    // it need to be filled with application user who wins challenge.
                    // token.setUserId(u.getUserId());
                    token.setTkn(tkn);
                    token.setStatus(1);
                    token.setCompanyName(u.getCompanyName());
                    token.setCreatedDate(Core.getNow());
                    token.setExpireDate(req.getExpireDate());
                    token.setPrice(req.getPrice());
                    token.setChallenge(req.getChallenge());
                    token.setRequiredDistance(req.getRequiredDistance());
                    param.addToken(token);

                    tokenCodes.add(tkn);
                }

                res.setTokens(tokenCodes);
                res.setResponseDesc("Successfully created " + quantity + " token" + (quantity > 1 ? "s" : ""));
            } else {
                throw new RunnerException(3, "Incorrect password!");
            }

        } else {
            throw new RunnerException(2, "Not company user");
        }

        return res;
    }

    private String generateOtt(int length) {

        SecureRandom random = new SecureRandom();
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        StringBuilder sb = new StringBuilder();

        for (int i = 0; i < length; i++) {
            int index = random.nextInt(chars.length());
            sb.append(chars.charAt(index));
        }

        return sb.toString();
    }

    public CheckAndRedeemTokenRes checkAndRedeemToken(CheckAndRedeemTokenReq req) {
        CheckAndRedeemTokenRes res = new CheckAndRedeemTokenRes();

        // Get userId from SecurityContext
        String userId = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        // 1. check company user
        User u = param.findUser(userId);
        if (u != null && !Core.nullOrEmpty(u.getCompanyName())) {
            // 2. check password
            UserCredPK pk = new UserCredPK();
            pk.setUserName(u.getUserName());
            pk.setUserId(u.getUserId());

            UserCred cred = param.getUserCred(pk);
            if (cred != null && passwordEncoder.matches(req.getUserPass(), cred.getUserPass())) {

                // 3. token checking
                Token t = param.findTokenByTkn(req.getToken());

                if (t != null) {
                    if ((t.getExpireDate() != null && t.getExpireDate().isAfter(Core.getNow())
                            && Core.equal(t.getStatus(), 1))
                            || Core.equal(t.getStatus(), 1)) {
                        // 4. successfully redeemed.
                        t.setStatus(0);
                        t.setRedeemedDate(Core.getNow());
                        param.updateToken(t);
                        res.setResponseDesc("Token is successfully redeemed.");
                    } else {
                        throw new RunnerException(6, "Token is expired!");
                    }
                } else {
                    throw new RunnerException(5, "Incorrect token!");
                }

            } else {
                throw new RunnerException(3, "Incorrect password!");
            }

        } else {
            throw new RunnerException(2, "Not company user");
        }

        return res;
    }

    // need this for security for request responses
    public PublicKey getPublicKey() throws NoSuchAlgorithmException {

        KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
        keyGen.initialize(2048); // 2048-bit is secure
        KeyPair pair = keyGen.generateKeyPair();

        PublicKey publicKey = pair.getPublic();
        PrivateKey privateKey = pair.getPrivate();

        return publicKey;
    }

    public String decrypt(String encryptedTextBase64, String privateKeyBase64) throws Exception {
        byte[] privateBytes = Base64.getDecoder().decode(privateKeyBase64);
        PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(privateBytes);
        PrivateKey privateKey = KeyFactory.getInstance("RSA").generatePrivate(keySpec);

        Cipher cipher = Cipher.getInstance("RSA/ECB/OAEPWithSHA-256AndMGF1Padding");
        cipher.init(Cipher.DECRYPT_MODE, privateKey);

        byte[] decryptedBytes = cipher.doFinal(Base64.getDecoder().decode(encryptedTextBase64));
        return new String(decryptedBytes);
    }

    public GetCurrentUserRes getCurrentUser() {
        // Get userId from SecurityContext
        String userId = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        User u = param.findUser(userId);
        return GetCurrentUserRes.fromUser(u);
    }

    public UpdateCompanyRes updateCompany(UpdateCompanyReq req) {
        UpdateCompanyRes res = new UpdateCompanyRes();

        // Get userId from SecurityContext
        String userId = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        User u = param.findUser(userId);
        if (u == null) {
            throw new RunnerException(1, "User not found");
        }

        Company c = new Company();
        c.setUserId(userId);
        c.setCompany(u.getCompanyName());
        c.setPicture(req.getPicture());
        c.setDetails(req.getDetails());

        param.updateCompany(c);

        res.setResponseDesc("Company details updated successfully");
        return res;
    }

    public Company getCompany() {
        // Get userId from SecurityContext
        String userId = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        Company company = param.getCompany(userId);
        if (company == null) {
            throw new RunnerException(1, "Company not found");
        }

        return company;
    }

    public java.util.List<GetTokenRes> getTokens() {
        // Get userId from SecurityContext
        String userId = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        User u = param.findUser(userId);
        if (u == null || Core.nullOrEmpty(u.getCompanyName())) {
            throw new RunnerException(1, "User or company not found");
        }

        return param.getTokensByCompany(u.getCompanyName()).stream()
                .map(GetTokenRes::fromToken)
                .toList();
    }

    private String generateOTP() {
        java.util.Random random = new java.util.Random();
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }

    @Transactional
    public GenericResponse requestPasswordReset(ForgotPasswordRequestReq req) {
        User u = param.findUserByUserName(req.getUserName());
        if (u == null) {
            throw new RunnerException(1, "User not found");
        }

        String otp = generateOTP();
        java.time.LocalDateTime expiry = Core.getNow().plusMinutes(10);

        UserCredPK pk = new UserCredPK();
        pk.setUserName(u.getUserName());
        pk.setUserId(u.getUserId());

        UserCred cred = param.getUserCred(pk);
        if (cred == null) {
            throw new RunnerException(2, "User credentials not found");
        }

        cred.setOtpCode(otp);
        cred.setOtpExpiry(expiry);
        param.updateUserCred(cred);

        log.info("OTP generated for user {}: {}", req.getUserName(), otp);
        log.info("OTP expires at: {}", expiry);

        GenericResponse res = new GenericResponse();
        // TODO: send email
        res.setResponseCode(0);
        res.setResponseDesc("OTP sent successfully");
        return res;
    }

    public GenericResponse verifyOTP(ForgotPasswordVerifyReq req) {
        User u = param.findUserByUserName(req.getUserName());
        if (u == null) {
            throw new RunnerException(1, "User not found");
        }

        UserCredPK pk = new UserCredPK();
        pk.setUserName(u.getUserName());
        pk.setUserId(u.getUserId());

        UserCred cred = param.getUserCred(pk);
        if (cred == null || cred.getOtpCode() == null) {
            throw new RunnerException(2, "No OTP found for this user");
        }

        if (Core.getNow().isAfter(cred.getOtpExpiry())) {
            throw new RunnerException(3, "OTP has expired");
        }

        if (!cred.getOtpCode().equals(req.getOtpCode())) {
            throw new RunnerException(4, "Invalid OTP");
        }

        GenericResponse res = new GenericResponse();
        res.setResponseCode(0);
        res.setResponseDesc("OTP verified successfully");
        res.setMessage("You can now reset your password");
        return res;
    }

    @Transactional
    public GenericResponse resetPassword(ForgotPasswordResetReq req) {
        GenericResponse verifyRes = verifyOTP(new ForgotPasswordVerifyReq() {
            {
                setUserName(req.getUserName());
                setOtpCode(req.getOtpCode());
            }
        });

        if (verifyRes.getResponseCode() != 0) {
            return verifyRes;
        }

        User u = param.findUserByUserName(req.getUserName());
        UserCredPK pk = new UserCredPK();
        pk.setUserName(u.getUserName());
        pk.setUserId(u.getUserId());

        UserCred cred = param.getUserCred(pk);
        cred.setUserPass(passwordEncoder.encode(req.getNewPassword()));
        cred.setOtpCode(null);
        cred.setOtpExpiry(null);
        param.updateUserCred(cred);

        log.info("Password reset successful for user: {}", req.getUserName());

        GenericResponse res = new GenericResponse();
        res.setResponseDesc("Password reset successfully");
        res.setMessage("You can now login with your new password");
        return res;
    }

    public java.util.List<GetActiveChallengeRes> getActiveChallenges() {
        return param.getActiveChallenges().stream()
                .map(GetActiveChallengeRes::fromToken)
                .toList();
    }

    public java.util.List<GetTokenRes> getMyRewards() {
        String userId = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return param.getMyRewards(userId).stream()
                .map(GetTokenRes::fromToken)
                .toList();
    }

    @Transactional
    public GenericResponse acceptChallenge(AcceptChallengeReq req) {
        GenericResponse res = new GenericResponse();

        // Get runner userId from SecurityContext
        String userId = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        Token token = param.findTokenById(req.getTokenId());
        if (token == null) {
            throw new RunnerException(1, "Challenge not found");
        }

        if (token.getStatus() != 1) {
            throw new RunnerException(2, "Challenge is no longer available");
        }

        if (token.getExpireDate() != null && token.getExpireDate().isBefore(Core.getNow())) {
            throw new RunnerException(3, "Challenge has expired");
        }
        if (token.getUserId() != null && token.getUserId().equals(userId)) {
            throw new RunnerException(4, "You have already accepted this challenge");
        }
        if (token.getRequiredDistance() != null && token.getRequiredDistance() > 0) {
            double totalDistance = runRepo.getTotalDistanceByUserId(userId);
            if (totalDistance < token.getRequiredDistance()) {
                throw new RunnerException(5, String.format(
                        "You need %.1f km but have only run %.1f km. Keep running!",
                        token.getRequiredDistance(), totalDistance));
            }
        }

        token.setUserId(userId);
        token.setStatus(2); // 2 = USER
        token.setClaimedDate(Core.getNow());
        param.updateToken(token);

        res.setResponseDesc("Challenge accepted! Show this to the shop to claim your reward.");
        return res;
    }
}
