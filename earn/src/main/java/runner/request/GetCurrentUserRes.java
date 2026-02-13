package runner.request;

import lombok.Getter;
import lombok.Setter;
import runner.db.User;

@Getter
@Setter
public class GetCurrentUserRes {
    private String userId;
    private String userType;
    private String userName;
    private String companyName;

    public static GetCurrentUserRes fromUser(User user) {
        GetCurrentUserRes dto = new GetCurrentUserRes();
        dto.setUserId(user.getUserId());
        dto.setUserType(user.getUserType());
        dto.setUserName(user.getUserName());
        dto.setCompanyName(user.getCompanyName());
        return dto;
    }
}
