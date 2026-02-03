package runner.db;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "token")
@Getter
@Setter
@NoArgsConstructor
public class Token {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "tkn", unique = true, nullable = false)
    private String tkn;

    @Column(name = "user_id")
    private String userId;

    @Column(name = "company_name", nullable = false, length = 30)
    private String companyName;

    @Column(name = "status", nullable = false, length = 1)
    private int status;

    @Column(name = "price")
    private String price;

    @Column(name = "challenge")
    private String challenge;

    @Column(name = "created_date")
    private LocalDateTime createdDate;

    @Column(name = "expire_date")
    private LocalDateTime expireDate;

    @Column(name = "redeemed_date")
    private LocalDateTime redeemedDate;
}
