package com.example.api.interceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class LoggingInterceptor implements HandlerInterceptor {
    private static final Logger logger = LoggerFactory.getLogger(LoggingInterceptor.class);

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String clientIp = request.getRemoteAddr();
        String method = request.getMethod();
        String uri = request.getRequestURI();
        String queryString = request.getQueryString();
        
        logger.info("API Request - Method: {}, Path: {}, Query: {}, Client IP: {}", 
                   method, uri, queryString != null ? queryString : "none", clientIp);
        
        long startTime = System.currentTimeMillis();
        request.setAttribute("startTime", startTime);
        
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        long startTime = (Long) request.getAttribute("startTime");
        long duration = System.currentTimeMillis() - startTime;
        
        String method = request.getMethod();
        String uri = request.getRequestURI();
        int status = response.getStatus();
        
        logger.info("API Response - Method: {}, Path: {}, Status: {}, Duration: {}ms", 
                   method, uri, status, duration);
        
        if (ex != null) {
            logger.error("API Exception - Method: {}, Path: {}, Exception: {}", 
                        method, uri, ex.getMessage());
        }
    }
}
