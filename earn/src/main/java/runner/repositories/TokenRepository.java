package runner.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import runner.db.Token;
import java.util.List;

public interface TokenRepository extends JpaRepository<Token, Long> {
    Token findByTkn(String tkn);

    List<Token> findByCompanyNameOrderByCreatedDateDesc(String companyName);

    List<Token> findByStatusOrderByCreatedDateDesc(int status);

    List<Token> findByUserIdAndStatusOrderByClaimedDateDesc(String userId, int status);

    /**
     * Leaderboard: count tokens claimed per user (status=2), sorted by most tokens.
     * Returns Object[] where [0]=userId, [1]=tokenCount (Long).
     */
    @Query("SELECT t.userId, COUNT(t) FROM Token t WHERE t.userId IS NOT NULL AND t.status = 2 " +
            "GROUP BY t.userId ORDER BY COUNT(t) DESC")
    List<Object[]> findLeaderboard();
}
