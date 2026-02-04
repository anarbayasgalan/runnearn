package runner.api;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import runner.db.Run;
import runner.request.*;
import runner.service.MainService;
import runner.service.RunRepository;

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

        Run run = new Run();
        run.setDistance(
                Double.parseDouble(data.get("distance").toString()));

        run.setRouteJson(
                objectMapper.writeValueAsString(data.get("route")));
        return runRepo.save(run);
    }

    @GetMapping
    public List<Run> getAll() {
        return runRepo.findAll();
    }
}
