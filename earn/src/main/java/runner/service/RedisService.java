package runner.service;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

@Service
public class RedisService {

    private static final String SESSION_PREFIX = "session:";

    private final StringRedisTemplate redis;

    public RedisService(StringRedisTemplate redis) {
        this.redis = redis;
    }

    /**
     * Store a session token → userId mapping in Redis with a TTL.
     */
    public void cacheSession(String token, String userId, long ttlMinutes) {
        redis.opsForValue().set(SESSION_PREFIX + token, userId, ttlMinutes, TimeUnit.MINUTES);
    }

    /**
     * Get the userId for a given token. Returns null if not found (expired or
     * logged out).
     */
    public String getUserId(String token) {
        return redis.opsForValue().get(SESSION_PREFIX + token);
    }

    /**
     * Delete a session from Redis — used on logout to immediately invalidate the
     * token.
     */
    public void deleteSession(String token) {
        redis.delete(SESSION_PREFIX + token);
    }
}
