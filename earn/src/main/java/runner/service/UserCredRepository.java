package runner.service;

import org.springframework.data.jpa.repository.JpaRepository;
import runner.db.UserCred;
import runner.db.UserCredPK;

public interface UserCredRepository extends JpaRepository<UserCred, UserCredPK> {
}
