package com.college.canteen.dao;

import com.college.canteen.model.User;
import com.college.canteen.util.DBConnection;

import java.security.MessageDigest;
import java.sql.*;
import java.util.Optional;

/**
 * Data Access Object for User operations.
 * All DB work done via plain JDBC — no ORM.
 */
public class UserDAO {

    /** Hash a password using SHA-256 (simple, no external libs). */
    public static String hashPassword(String plain) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(plain.getBytes("UTF-8"));
            StringBuilder hex = new StringBuilder();
            for (byte b : hash) hex.append(String.format("%02x", b));
            return hex.toString();
        } catch (Exception e) {
            throw new RuntimeException("Hashing failed", e);
        }
    }

    /**
     * Register a new student.
     * Returns the saved User (with generated ID), or throws if roll/email exists.
     */
    public User createUser(User user) throws SQLException {
        String sql = "INSERT INTO users (first_name, last_name, roll_number, email, department, password_hash) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, user.getFirstName());
            ps.setString(2, user.getLastName());
            ps.setString(3, user.getRollNumber().toUpperCase().trim());
            ps.setString(4, user.getEmail().toLowerCase().trim());
            ps.setString(5, user.getDepartment());
            ps.setString(6, hashPassword(user.getPasswordHash())); // getPasswordHash holds plain pw at this stage

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) user.setId(rs.getInt(1));
            }
        }
        return user;
    }

    /**
     * Find a user by roll number.
     */
    public Optional<User> findByRoll(String rollNumber) throws SQLException {
        String sql = "SELECT * FROM users WHERE roll_number = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, rollNumber.toUpperCase().trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapRow(rs));
            }
        }
        return Optional.empty();
    }

    /**
     * Find a user by email.
     */
    public Optional<User> findByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email.toLowerCase().trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapRow(rs));
            }
        }
        return Optional.empty();
    }

    /**
     * Verify login: roll number + password.
     * Returns the User if credentials match, empty otherwise.
     */
    public Optional<User> authenticate(String rollNumber, String plainPassword) throws SQLException {
        Optional<User> userOpt = findByRoll(rollNumber);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (user.getPasswordHash().equals(hashPassword(plainPassword))) {
                return Optional.of(user);
            }
        }
        return Optional.empty();
    }

    /** Check whether a roll number is already registered. */
    public boolean rollExists(String rollNumber) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE roll_number = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, rollNumber.toUpperCase().trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    /** Check whether an email is already registered. */
    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email.toLowerCase().trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setFirstName(rs.getString("first_name"));
        u.setLastName(rs.getString("last_name"));
        u.setRollNumber(rs.getString("roll_number"));
        u.setEmail(rs.getString("email"));
        u.setDepartment(rs.getString("department"));
        u.setPasswordHash(rs.getString("password_hash"));
        return u;
    }
}
