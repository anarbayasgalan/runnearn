package runner.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import runner.db.Company;

public interface CompanyRepository extends JpaRepository<Company, String> {
}
