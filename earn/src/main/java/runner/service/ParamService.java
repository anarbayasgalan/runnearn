package runner.service;

import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import runner.db.*;
import runner.exception.RunnerException;
import runner.repositories.*;

import java.util.List;
import java.util.Optional;

@Service
public class ParamService {

    @Autowired
    private UserRepository userRepository;
    @Autowired
    private UserCredRepository userCredRepository;
    @Autowired
    private UserSessionRepository userSessionRepository;
    @Autowired
    private TokenRepository tokenRepository;
    @Autowired
    private CompanyRepository companyRepository;

    public void createUser(User user) {
        userRepository.save(user);
    }

    public User findUserByUserName(String userName) {
        return userRepository.findByUserName(userName);
    }

    public void createUserCred(UserCred u) {
        userCredRepository.save(u);
    }

    public void updateUserCred(UserCred u) {
        Optional<UserCred> user = userCredRepository.findById(u.getId());
        if (user.isPresent()) {
            UserCred existing = user.get();
            existing.setUserPass(u.getUserPass());
            userCredRepository.save(existing);
        }
    }

    public User findUser(String userId) {
        return userRepository.findById(userId).orElse(null);
    }

    public UserCred getUserCred(UserCredPK u) {
        return userCredRepository.findById(u).orElse(null);
    }

    public UserSession getUserFromSession(String session) {
        return userSessionRepository.findById(session).orElse(null);
    }

    @Transactional
    public void addUserSession(UserSession u) {
        userSessionRepository.save(u);
    }

    @Transactional
    public void addToken(Token token) {
        tokenRepository.save(token);
    }

    @Transactional
    public void updateToken(Token token) {
        if (token.getId() != null && tokenRepository.existsById(token.getId())) {
            tokenRepository.save(token);
        } else {
            // exception
        }
    }

    @Transactional
    public Token findTokenByTkn(String tkn) {
        return tokenRepository.findByTkn(tkn);
    }

    public void updateCompany(Company c) {
        // Upsert: save will insert if not exists, or update if exists
        companyRepository.save(c);
    }

    public Company getCompany(String userId) {
        return companyRepository.findById(userId).orElse(null);
    }

    public void createCompany(Company c) {
        companyRepository.save(c);
    }

    public List<Token> getTokensByCompany(String companyName) {
        return tokenRepository.findByCompanyNameOrderByCreatedDateDesc(companyName);
    }

}
