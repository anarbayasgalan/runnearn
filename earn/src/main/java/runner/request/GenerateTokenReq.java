package runner.request;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class GenerateTokenReq {

    String userPass;
    LocalDateTime expireDate;
    String price;
    String challenge;
    Integer quantity;
}
