package runner.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import runner.db.User;

public interface UserRepository extends JpaRepository<User, String> {
    User findByUserName(String userName);
}
