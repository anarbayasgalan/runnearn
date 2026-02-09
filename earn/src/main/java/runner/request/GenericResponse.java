package runner.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class GenericResponse extends BaseRes {
    String message;
    String otpCode;
    String otpExpiry;
}
