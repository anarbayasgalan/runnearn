package runner.config;

import io.github.resilience4j.ratelimiter.RateLimiter;
import io.github.resilience4j.ratelimiter.RateLimiterConfig;
import io.github.resilience4j.ratelimiter.RateLimiterRegistry;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Duration;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Rate limits login and password-reset endpoints to prevent brute-force
 * attacks.
 * Each IP address gets 10 requests per minute on protected endpoints.
 */
@Component
public class RateLimitFilter extends OncePerRequestFilter {

    private final RateLimiterConfig config = RateLimiterConfig.custom()
            .limitForPeriod(10)
            .limitRefreshPeriod(Duration.ofMinutes(1))
            .timeoutDuration(Duration.ZERO)
            .build();

    private final ConcurrentHashMap<String, RateLimiter> limiters = new ConcurrentHashMap<>();

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String path = request.getRequestURI();

        if (isRateLimited(path)) {
            String clientIp = getClientIp(request);
            RateLimiter limiter = limiters.computeIfAbsent(clientIp,
                    ip -> RateLimiter.of("rate-limiter-" + ip, config));

            if (!limiter.acquirePermission()) {
                response.setStatus(429);
                response.setContentType("application/json");
                response.getWriter().write(
                        "{\"responseCode\":429,\"responseDesc\":\"Too many requests. Please try again later.\"}");
                return;
            }
        }

        filterChain.doFilter(request, response);
    }

    private boolean isRateLimited(String path) {
        return path.startsWith("/api/login")
                || path.startsWith("/api/registerUser")
                || path.startsWith("/api/forgot-password");
    }

    private String getClientIp(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
