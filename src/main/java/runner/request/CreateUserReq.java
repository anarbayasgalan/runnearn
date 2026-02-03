package runner.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateUserReq {

    String userName;
    String userId;
    String type;
    String companyName;
    int status;
}
