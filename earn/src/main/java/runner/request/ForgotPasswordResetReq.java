package runner.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ForgotPasswordResetReq {
    String userName;
    String otpCode;
    String newPassword;
}
