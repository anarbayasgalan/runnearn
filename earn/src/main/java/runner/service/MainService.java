package runner.service;

import org.springframework.security.core.context.SecurityContextHolder;
import runner.exception.RunnerException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import runner.db.*;
import runner.request.*;

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

        // 4. Generate session with user_id
        String token = generateSession(cred.getId().getUserId());

        // 5.response
        LoginRes res = new LoginRes();
        res.setResponseCode(0); // success
        res.setResponseDesc("Login successful");
        res.setSession(token);

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
                // 3. Generate secure One time token(OTT)
                String tkn = generateOtt(25);

                // 4. Save token
                Token token = new Token();
                token.setUserId(u.getUserId());
                token.setTkn(tkn);
                token.setStatus(1);
                token.setCompanyName(u.getCompanyName());
                token.setCreatedDate(Core.getNow());
                token.setExpireDate(req.getExpireDate());
                token.setPrice(req.getPrice());
                token.setChallenge(req.getChallenge());
                param.addToken(token);

                res.setResponseDesc("Successfully created token");
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


    //need this for security for request responses
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

    public User getCurrentUser() {
        // Get userId from SecurityContext
        String userId = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return param.findUser(userId);
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
}
