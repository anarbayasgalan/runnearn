package runner.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BaseRes {
    public int responseCode = 0;
    public String responseDesc;
}
