package runner.service;

import org.springframework.data.jpa.repository.JpaRepository;
import runner.db.UserSession;

public interface UserSessionRepository extends JpaRepository<UserSession, String> {
}
