package runner.db;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_session")
@Getter
@Setter
@NoArgsConstructor
public class UserSession {
    @Id
    @Column(name = "session", nullable = false, length = 10000)
    private String session;

    @Column(name = "user_id", nullable = false, length = 100)
    private String userId;

    @Column(name = "status", nullable = false, length = 30)
    private int status;

    @Column(name = "expire_date")
    private LocalDateTime expireDate;
}
