package com.college.canteen.controller;

import com.college.canteen.dao.UserDAO;
import com.college.canteen.model.User;
import com.college.canteen.util.HttpUtil;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Optional;

/**
 * Handles /api/auth/signup and /api/auth/login
 * No JWT — we keep it simple: returns user data, frontend stores in sessionStorage.
 */
public class AuthController {

    private static final UserDAO userDAO = new UserDAO();

    // ── POST /api/auth/signup ────────────────────────────────────────────────
    public static class SignupHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange ex) throws IOException {
            if (HttpUtil.handleCors(ex)) return;
            if (!ex.getRequestMethod().equalsIgnoreCase("POST")) {
                HttpUtil.sendJson(ex, 405, HttpUtil.error("Method not allowed"));
                return;
            }

            String body = HttpUtil.readBody(ex);

            // Parse fields from JSON
            String firstName  = HttpUtil.extractString(body, "firstName");
            String lastName   = HttpUtil.extractString(body, "lastName");
            String rollNumber = HttpUtil.extractString(body, "rollNumber");
            String email      = HttpUtil.extractString(body, "email");
            String department = HttpUtil.extractString(body, "department");
            String password   = HttpUtil.extractString(body, "password");

            // ── Validation ───────────────────────────────────────────────────
            if (isBlank(firstName))  { HttpUtil.sendJson(ex, 400, HttpUtil.error("First name is required")); return; }
            if (isBlank(lastName))   { HttpUtil.sendJson(ex, 400, HttpUtil.error("Last name is required")); return; }
            if (isBlank(rollNumber)) { HttpUtil.sendJson(ex, 400, HttpUtil.error("Roll number is required")); return; }
            if (isBlank(email))      { HttpUtil.sendJson(ex, 400, HttpUtil.error("Email is required")); return; }
            if (!email.contains("@"))  { HttpUtil.sendJson(ex, 400, HttpUtil.error("Invalid email address")); return; }
            if (isBlank(department)) { HttpUtil.sendJson(ex, 400, HttpUtil.error("Department is required")); return; }
            if (isBlank(password))   { HttpUtil.sendJson(ex, 400, HttpUtil.error("Password is required")); return; }
            if (password.length() < 6) { HttpUtil.sendJson(ex, 400, HttpUtil.error("Password must be at least 6 characters")); return; }

            try {
                if (userDAO.rollExists(rollNumber)) {
                    HttpUtil.sendJson(ex, 409, HttpUtil.error("Roll number already registered"));
                    return;
                }
                if (userDAO.emailExists(email)) {
                    HttpUtil.sendJson(ex, 409, HttpUtil.error("Email already registered"));
                    return;
                }

                User user = new User(firstName, lastName, rollNumber, email, department, password);
                User saved = userDAO.createUser(user);
                // clear hash before sending back
                saved.setPasswordHash(null);

                HttpUtil.sendJson(ex, 201, "{\"message\":\"Account created successfully!\",\"user\":" + saved.toJson() + "}");

            } catch (SQLException e) {
                System.err.println("DB error during signup: " + e.getMessage());
                HttpUtil.sendJson(ex, 500, HttpUtil.error("Database error. Please try again."));
            }
        }
    }

    // ── POST /api/auth/login ─────────────────────────────────────────────────
    public static class LoginHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange ex) throws IOException {
            if (HttpUtil.handleCors(ex)) return;
            if (!ex.getRequestMethod().equalsIgnoreCase("POST")) {
                HttpUtil.sendJson(ex, 405, HttpUtil.error("Method not allowed"));
                return;
            }

            String body = HttpUtil.readBody(ex);
            String rollNumber = HttpUtil.extractString(body, "rollNumber");
            String password   = HttpUtil.extractString(body, "password");

            if (isBlank(rollNumber) || isBlank(password)) {
                HttpUtil.sendJson(ex, 400, HttpUtil.error("Roll number and password are required"));
                return;
            }

            try {
                Optional<User> userOpt = userDAO.authenticate(rollNumber, password);
                if (userOpt.isEmpty()) {
                    HttpUtil.sendJson(ex, 401, HttpUtil.error("Invalid roll number or password"));
                    return;
                }

                User user = userOpt.get();
                user.setPasswordHash(null); // Never send the hash to client

                HttpUtil.sendJson(ex, 200, "{\"message\":\"Login successful\",\"user\":" + user.toJson() + "}");

            } catch (SQLException e) {
                System.err.println("DB error during login: " + e.getMessage());
                HttpUtil.sendJson(ex, 500, HttpUtil.error("Database error. Please try again."));
            }
        }
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
