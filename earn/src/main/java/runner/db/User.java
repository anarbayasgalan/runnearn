package runner.db;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "\"user\"")
@Getter
@Setter
@NoArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "user_id", nullable = false, length = 100)
    private String userId;

    @Column(name = "user_type", nullable = false, length = 100)
    private String userType;

    @Column(name = "status", nullable = false, length = 30)
    private int status;

    @Column(name = "user_name", nullable = false, length = 500)
    private String userName;

    @Column(name = "company_name")
    private String companyName;
}
