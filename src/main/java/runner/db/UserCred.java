package runner.db;

import jakarta.persistence.Embeddable;
import jakarta.persistence.EmbeddedId;
import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Getter
@Setter
@Entity
@Table(name = "user_cred")
public class UserCred implements Serializable {

    @EmbeddedId
    private UserCredPK id;
    private String userPass;
}
