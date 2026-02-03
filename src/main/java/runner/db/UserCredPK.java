package runner.db;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

import java.io.Serializable;
import java.util.Objects;

@Embeddable
public class UserCredPK implements Serializable {

    @Column(name = "user_id", length = 100)
    private String userId;

    @Column(name = "user_name", length = 100)
    private String userName;

    public UserCredPK() {
    }

    public UserCredPK(String userId, String userName) {
        this.userId = userId;
        this.userName = userName;
    }

    // Getters & Setters

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    // Required for composite key
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof UserCredPK)) return false;
        UserCredPK that = (UserCredPK) o;
        return Objects.equals(userId, that.userId) &&
                Objects.equals(userName, that.userName);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId, userName);
    }
}
