package runner.service;

import org.springframework.data.jpa.repository.JpaRepository;
import runner.db.Run;

public interface RunRepository extends JpaRepository<Run, Long> {
}

