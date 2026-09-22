package com.college.canteen.server;

import com.college.canteen.controller.*;
import com.college.canteen.util.DBConnection;
import com.sun.net.httpserver.*;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.util.concurrent.Executors;

/**
 * CampusEats — Main Server
 * Pure Java HTTP server (no frameworks).
 * Run: javac then java com.college.canteen.server.Main
 * Visit: http://localhost:8080
 */
public class Main {

    public static void main(String[] args) throws IOException {
        // Test DB connection on startup
        System.out.println("📦 Connecting to database...");
        try {
            DBConnection.getConnection().close();
            System.out.println("✅ Database connected successfully.");
        } catch (Exception e) {
            System.err.println("❌ Database connection failed: " + e.getMessage());
            System.err.println("   Make sure MySQL is running and schema.sql has been executed.");
        }

        HttpServer server = HttpServer.create(new InetSocketAddress(8080), 0);

        // ── Static files (serves index.html and assets)
        server.createContext("/", new StaticFileHandler());

        // ── REST API routes
        server.createContext("/api/auth/signup",  new AuthController.SignupHandler());
        server.createContext("/api/auth/login",   new AuthController.LoginHandler());

        server.createContext("/api/menu",         new MenuController.MenuHandler());

        server.createContext("/api/orders",       new OrderController.OrdersHandler());
        server.createContext("/api/orders/token", new OrderController.OrderByTokenHandler());

        // Thread pool so multiple requests can be handled concurrently
        server.setExecutor(Executors.newFixedThreadPool(10));
        server.start();

        System.out.println("🔥 CampusEats server running at http://localhost:8080");
    }
}
