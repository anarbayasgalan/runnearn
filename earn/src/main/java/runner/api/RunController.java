package runner.api;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import runner.db.Run;
import runner.request.*;
import runner.service.MainService;
import runner.service.Core;
import runner.repositories.RunRepository;

import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api")
public class RunController {

    @Autowired
    private RunRepository runRepo;

    @Autowired
    private ObjectMapper objectMapper;

    @PostMapping("/run")
    public Run save(@RequestBody Map<String, Object> data) throws JsonProcessingException {
        String userId = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        Run run = new Run();
        run.setUserId(userId);
        run.setDistance(
                Double.parseDouble(data.get("distance").toString()));
        run.setCreatedDate(Core.getNow());
        run.setRouteJson(
                objectMapper.writeValueAsString(data.get("route")));
        return runRepo.save(run);
    }

    @GetMapping("/runs")
    public List<Run> getMyRuns() {
        String userId = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return runRepo.findByUserIdOrderByCreatedDateDesc(userId);
    }

    @GetMapping("/runs/total-distance")
    public Map<String, Double> getTotalDistance() {
        String userId = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        double total = runRepo.getTotalDistanceByUserId(userId);
        return Map.of("totalDistance", total);
    }
}
