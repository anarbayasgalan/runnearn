package runner.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateCompanyReq {
    private String userId;
    private String companyName;
    private String picture;
    private String details;
}
