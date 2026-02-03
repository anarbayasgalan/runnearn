package runner.service;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import runner.db.User;

public interface UserRepository extends JpaRepository<User, String> {
    @Query(value = "SELECT * FROM USER WHERE USER_NAME = ?1", nativeQuery = true)
    User findByUserNameNative(String userName);

    User findByUserName(String userName);
}
