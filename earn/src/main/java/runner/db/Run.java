package runner.db;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
public class Run {
    @Id
    @GeneratedValue
    private Long id;

    @Column(name = "user_id")
    private String userId;

    private double distance;

    /** Pace in min/km (e.g. 5.5 = 5 min 30 sec per km) */
    private Double pace;

    /** Total run duration in seconds */
    @Column(name = "duration_seconds")
    private Long durationSeconds;

    @Column(name = "created_date")
    private LocalDateTime createdDate;

    @Lob
    private String routeJson;
}
