package runner.service;

import org.springframework.data.jpa.repository.JpaRepository;
import runner.db.Token;
import java.util.Optional;

public interface TokenRepository extends JpaRepository<Token, Long> {
    Token findByTkn(String tkn);
}
