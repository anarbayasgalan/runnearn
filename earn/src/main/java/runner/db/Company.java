package runner.db;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "company")
@Getter
@Setter
@NoArgsConstructor
public class Company {
    @Id
    @Column(name = "user_id", nullable = false, length = 10000)
    private String userId;

    @Column(name = "company", nullable = false, length = 100)
    private String company;

    @Column(name = "picture")
    private String picture;

    @Column(name = "details")
    private String details;
}
