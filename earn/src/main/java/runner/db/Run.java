package runner.db;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
public class Run {
    @Id
    @GeneratedValue
    private Long id;

    private double distance;

    @Lob
    private String routeJson;
}
