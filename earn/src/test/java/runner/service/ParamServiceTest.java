package runner.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import runner.db.Company;
import runner.db.Token;
import runner.db.User;
import runner.repositories.CompanyRepository;
import runner.repositories.TokenRepository;
import runner.repositories.UserRepository;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ParamServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private CompanyRepository companyRepository;

    @Mock
    private TokenRepository tokenRepository;

    @InjectMocks
    private ParamService paramService;

    @Test
    void findUser_Success() {
        // 1. setup
        String userId = "user123";
        User mockUser = new User();
        mockUser.setUserId(userId);
        when(userRepository.findById(userId)).thenReturn(Optional.of(mockUser));

        // 2. act
        User result = paramService.findUser(userId);

        // 3. result
        assertNotNull(result);
        assertEquals(userId, result.getUserId());
        verify(userRepository).findById(userId);
    }

    @Test
    void findUser_NotFound() {
        // 1. setup
        String userId = "unknown";
        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // 2. act
        User result = paramService.findUser(userId);

        // 3. result
        assertNull(result);
        verify(userRepository).findById(userId);
    }

    @Test
    void createCompany_Success() {
        // 1. setup
        Company company = new Company();
        company.setCompany("Test Company");

        // 2. act
        paramService.createCompany(company);

        // 3. result
        verify(companyRepository).save(company);
    }

    @Test
    void getTokensByCompany_Success() {
        // 1. setup
        String companyName = "Test Company";
        Token t1 = new Token();
        Token t2 = new Token();
        List<Token> mockTokens = Arrays.asList(t1, t2);

        when(tokenRepository.findByCompanyNameOrderByCreatedDateDesc(companyName))
                .thenReturn(mockTokens);

        // 2. act
        List<Token> result = paramService.getTokensByCompany(companyName);

        // 3. result
        assertNotNull(result);
        assertEquals(2, result.size());
        verify(tokenRepository).findByCompanyNameOrderByCreatedDateDesc(companyName);
    }
}
