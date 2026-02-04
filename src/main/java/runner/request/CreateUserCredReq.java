package runner.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateUserCredReq {

    String userId;
    String userName;
    String userPass;

}
