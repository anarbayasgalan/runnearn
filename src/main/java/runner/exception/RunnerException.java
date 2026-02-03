package runner.exception;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RunnerException extends RuntimeException {

    private int code;
    private String message;

    public RunnerException(int code, String message) {
        super(message);
        this.code = code;
        this.message = message;
    }
}
