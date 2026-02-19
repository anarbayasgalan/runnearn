package runner.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import runner.db.SocialAccount;

@Repository
public interface SocialAccountRepository extends JpaRepository<SocialAccount, String> {
    SocialAccount findByProviderAndProviderId(String provider, String providerId);

    SocialAccount findByUserIdAndProvider(String userId, String provider);
}
