package runner.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import runner.db.UserSession;
import runner.service.Core;
import runner.service.ParamService;

import java.io.IOException;
import java.util.ArrayList;

@Component
public class AuthenticationFilter extends OncePerRequestFilter {

    private final ParamService paramService;

    public AuthenticationFilter(ParamService paramService) {
        this.paramService = paramService;
    }


    //it's checking every single request because extends OncePerRequestFilter
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String token = request.getHeader("X-Auth-Token");
        if (!Core.nullOrEmpty(token)) {
            UserSession session = paramService.getUserFromSession(token);
            if (session != null && Core.equal(session.getStatus(), 1)) {
                if (session.getExpireDate() == null || session.getExpireDate().isAfter(Core.getNow())) {

                    UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                            session.getUserId(), null, new ArrayList<>());

                    authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                }
            }
        }

        filterChain.doFilter(request, response);
    }
}
