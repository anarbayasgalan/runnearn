package runner.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LoginSocialReq {
    private String provider; // "GOOGLE", "FACEBOOK"
    private String token; // ID Token or Access Token
    private String email; // Optional, can be extracted from token
    private String name; // Optional, can be extracted from token
    private String photoUrl; // Optional
    private String clientType;// "WEB", "MOBILE"
}
