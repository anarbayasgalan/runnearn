package runner.db;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "social_account")
@Getter
@Setter
@NoArgsConstructor
public class SocialAccount {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false, length = 100)
    private String id;

    @Column(name = "user_id", nullable = false, length = 100)
    private String userId;

    @Column(name = "provider", nullable = false, length = 20)
    private String provider; // GOOGLE, FACEBOOK

    @Column(name = "provider_id", nullable = false, length = 100)
    private String providerId; // Unique ID from provider

    @Column(name = "email", length = 100)
    private String email;
}
