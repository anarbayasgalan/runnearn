package runner.exception;

import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;
import runner.request.BaseRes;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RunnerException.class)
    @ResponseBody
    public BaseRes handleRunnerException(RunnerException e) {
        BaseRes res = new BaseRes();
        res.setResponseCode(e.getCode());
        res.setResponseDesc(e.getMessage());
        return res;
    }

    @ExceptionHandler(Exception.class)
    @ResponseBody
    public BaseRes handleException(Exception e) {
        BaseRes res = new BaseRes();
        res.setResponseCode(99);
        res.setResponseDesc("Error on server: " + e.getMessage());
        return res;
    }
}
