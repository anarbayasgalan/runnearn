package runner.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LoginRes extends BaseRes {
    public String session;
    public String userType;
}
