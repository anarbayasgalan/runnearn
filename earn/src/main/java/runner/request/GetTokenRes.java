package runner.request;

import lombok.Getter;
import lombok.Setter;
import runner.db.Token;

import java.time.LocalDateTime;

@Getter
@Setter
public class GetTokenRes {
    private Long id;
    private String tkn;
    private String companyName;
    private int status;
    private String price;
    private String challenge;
    private Double requiredDistance;
    private LocalDateTime createdDate;
    private LocalDateTime expireDate;
    private LocalDateTime redeemedDate;
    private LocalDateTime claimedDate;

    public static GetTokenRes fromToken(Token token) {
        GetTokenRes dto = new GetTokenRes();
        dto.setId(token.getId());
        dto.setTkn(token.getTkn());
        dto.setCompanyName(token.getCompanyName());
        dto.setStatus(token.getStatus());
        dto.setPrice(token.getPrice());
        dto.setChallenge(token.getChallenge());
        dto.setRequiredDistance(token.getRequiredDistance());
        dto.setCreatedDate(token.getCreatedDate());
        dto.setExpireDate(token.getExpireDate());
        dto.setRedeemedDate(token.getRedeemedDate());
        dto.setClaimedDate(token.getClaimedDate());
        return dto;
    }
}
