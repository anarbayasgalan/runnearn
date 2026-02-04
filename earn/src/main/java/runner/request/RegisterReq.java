package runner.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RegisterReq {
    public String userName;
    public String userPass;
    public String userType;
    public String companyName;
}
