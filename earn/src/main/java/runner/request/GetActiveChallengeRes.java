package runner.request;

import lombok.Getter;
import lombok.Setter;
import runner.db.Token;

import java.time.LocalDateTime;

@Getter
@Setter
public class GetActiveChallengeRes {
    private Long id;
    private String companyName;
    private String price;
    private String challenge;
    private Double requiredDistance;
    private LocalDateTime expireDate;
    private LocalDateTime createdDate;

    public static GetActiveChallengeRes fromToken(Token token) {
        GetActiveChallengeRes dto = new GetActiveChallengeRes();
        dto.setId(token.getId());
        dto.setCompanyName(token.getCompanyName());
        dto.setPrice(token.getPrice());
        dto.setChallenge(token.getChallenge());
        dto.setRequiredDistance(token.getRequiredDistance());
        dto.setExpireDate(token.getExpireDate());
        dto.setCreatedDate(token.getCreatedDate());
        return dto;
    }
}
