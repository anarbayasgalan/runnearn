package runner.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CheckAndRedeemTokenReq {

    String userPass;
    String token;
}
