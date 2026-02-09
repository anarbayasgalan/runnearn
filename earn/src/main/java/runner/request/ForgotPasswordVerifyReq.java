package runner.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ForgotPasswordVerifyReq {
    String userName;
    String otpCode;
}
