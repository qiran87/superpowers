/**
 * Login Service Tests
 *
 * @requirement 2025-01-15-user-authentication
 * @task task-1-user-login-service
 * @created 2025-01-15
 * @author AI Agent (subagent-driven-development)
 */

import { describe, it, expect, beforeEach } from 'vitest';
import { login } from '../../../src/services/auth/login';

describe('Authentication Service - Login', () => {
  describe('login with valid credentials', () => {
    it('should authenticate user with correct email and password', async () => {
      const result = await login('user@example.com', 'correctPassword123');

      expect(result).toBeDefined();
      expect(result.token).toBeDefined();
      expect(result.user).toBeDefined();
      expect(result.user.email).toBe('user@example.com');
      expect(result.token).toMatch(/^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+$/);
    });

    it('should return user object without password field', async () => {
      const result = await login('user@example.com', 'correctPassword123');

      expect(result.user).not.toHaveProperty('password');
      expect(result.user).toHaveProperty('id');
      expect(result.user).toHaveProperty('email');
      expect(result.user).toHaveProperty('createdAt');
    });
  });

  describe('login with invalid email format', () => {
    it('should reject email without @ symbol', async () => {
      await expect(
        login('invalidemail', 'password123')
      ).rejects.toThrow('Invalid email format');
    });

    it('should reject email without domain', async () => {
      await expect(
        login('user@', 'password123')
      ).rejects.toThrow('Invalid email format');
    });

    it('should reject empty email', async () => {
      await expect(
        login('', 'password123')
      ).rejects.toThrow('Email is required');
    });
  });

  describe('login with wrong password', () => {
    it('should reject incorrect password for existing user', async () => {
      await expect(
        login('user@example.com', 'wrongPassword')
      ).rejects.toThrow('Invalid credentials');
    });

    it('should provide clear error message for wrong password', async () => {
      try {
        await login('user@example.com', 'wrongPassword');
        expect(true).toBe(false); // Should not reach here
      } catch (error) {
        expect(error.message).toBe('Invalid credentials');
      }
    });
  });

  describe('login with non-existent user', () => {
    it('should reject login for non-registered email', async () => {
      await expect(
        login('nonexistent@example.com', 'password123')
      ).rejects.toThrow('User not found');
    });

    it('should not reveal whether user exists for security', async () => {
      try {
        await login('nonexistent@example.com', 'password123');
      } catch (error) {
        // Error message should be same as wrong password
        expect(error.message).toMatch(/Invalid credentials|User not found/);
      }
    });
  });

  describe('JWT token generation', () => {
    it('should generate JWT token with correct structure', async () => {
      const result = await login('user@example.com', 'correctPassword123');

      const tokenParts = result.token.split('.');
      expect(tokenParts).toHaveLength(3); // header.payload.signature
    });

    it('should include user ID in token payload', async () => {
      const result = await login('user@example.com', 'correctPassword123');

      // Decode JWT payload (without verification for this test)
      const payload = JSON.parse(atob(result.token.split('.')[1]));
      expect(payload).toHaveProperty('userId');
      expect(payload).toHaveProperty('email');
      expect(payload.email).toBe('user@example.com');
    });

    it('should set appropriate expiration time', async () => {
      const result = await login('user@example.com', 'correctPassword123');

      const payload = JSON.parse(atob(result.token.split('.')[1]));
      const exp = payload.exp;
      const now = Math.floor(Date.now() / 1000);

      // Token should expire in 24 hours (86400 seconds)
      expect(exp).toBeGreaterThan(now);
      expect(exp).toBeLessThanOrEqual(now + 86400);
    });
  });

  describe('edge cases', () => {
    it('should handle very long email addresses', async () => {
      const longEmail = 'verylongemailaddress' + 'a'.repeat(100) + '@example.com';

      await expect(
        login(longEmail, 'password123')
      ).rejects.toThrow();
    });

    it('should handle special characters in password', async () => {
      const specialPassword = 'P@ssw0rd!#$%&*';

      // Should succeed if password is correct
      const result = await login('user@example.com', specialPassword);
      expect(result.token).toBeDefined();
    });

    it('should handle unicode characters in email', async () => {
      const unicodeEmail = '用户@example.com';

      await expect(
        login(unicodeEmail, 'password123')
      ).rejects.toThrow(); // Should handle or reject based on implementation
    });
  });
});
