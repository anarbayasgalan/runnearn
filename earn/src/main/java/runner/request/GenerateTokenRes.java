package runner.request;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class GenerateTokenRes extends BaseRes {
    private List<String> tokens; // List of generated token codes
}
