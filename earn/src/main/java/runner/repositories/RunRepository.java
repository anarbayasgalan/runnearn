package runner.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import runner.db.Run;

import java.util.List;

public interface RunRepository extends JpaRepository<Run, Long> {
    List<Run> findByUserIdOrderByCreatedDateDesc(String userId);

    @Query("SELECT COALESCE(SUM(r.distance), 0) FROM Run r WHERE r.userId = :userId")
    double getTotalDistanceByUserId(@Param("userId") String userId);
}
