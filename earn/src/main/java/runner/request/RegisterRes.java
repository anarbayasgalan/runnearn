package runner.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RegisterRes extends BaseRes {
    private String session;
}
