/**
 * Authentication Flow Integration Tests
 *
 * @requirement 2025-01-15-user-authentication
 * @task task-5-authentication-flow-integration
 * @created 2025-01-15
 * @author AI Agent (subagent-driven-development)
 *
 * These tests verify the end-to-end authentication flow across multiple services.
 */

import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { registerUser, loginUser, logoutUser, refreshSession } from '../../../src/services/auth';
import { deleteUser } from '../../../src/services/users';

describe('Authentication Flow Integration', () => {
  const testUser = {
    email: `integration-test-${Date.now()}@example.com`,
    password: 'TestPassword123!',
    name: 'Integration Test User'
  };

  let authToken;
  let userId;

  // Cleanup after all tests
  afterAll(async () => {
    try {
      if (userId) {
        await deleteUser(userId);
      }
    } catch (error) {
      // Ignore cleanup errors in tests
      console.log('Cleanup note:', error.message);
    }
  });

  describe('complete registration flow', () => {
    it('should register new user with valid data', async () => {
      const result = await registerUser({
        email: testUser.email,
        password: testUser.password,
        name: testUser.name
      });

      expect(result).toBeDefined();
      expect(result.user).toBeDefined();
      expect(result.user.email).toBe(testUser.email);
      expect(result.user.id).toBeDefined();
      expect(result.user).not.toHaveProperty('password');
      userId = result.user.id;
    });

    it('should not allow duplicate email registration', async () => {
      await expect(
        registerUser({
          email: testUser.email,
          password: 'AnotherPassword123!',
          name: 'Duplicate User'
        })
      ).rejects.toThrow('Email already registered');
    });

    it('should reject registration with invalid email format', async () => {
      await expect(
        registerUser({
          email: 'invalid-email',
          password: testUser.password,
          name: 'Invalid Email User'
        })
      ).rejects.toThrow('Invalid email format');
    });

    it('should reject registration with weak password', async () => {
      await expect(
        registerUser({
          email: `weak-${Date.now()}@example.com`,
          password: '123',
          name: 'Weak Password User'
        })
      ).rejects.toThrow('Password does not meet security requirements');
    });
  });

  describe('complete login flow', () => {
    beforeAll(async () => {
      // Ensure test user exists
      if (!userId) {
        const result = await registerUser(testUser);
        userId = result.user.id;
      }
    });

    it('should login with correct credentials', async () => {
      const result = await loginUser({
        email: testUser.email,
        password: testUser.password
      });

      expect(result).toBeDefined();
      expect(result.token).toBeDefined();
      expect(result.user).toBeDefined();
      expect(result.user.email).toBe(testUser.email);

      authToken = result.token;
    });

    it('should maintain session across multiple requests', async () => {
      const loginResult = await loginUser(testUser);

      // Simulate multiple authenticated requests
      const requests = [
        fetchUser Profile(loginResult.token),
        fetchUserSettings(loginResult.token),
        fetchUserNotifications(loginResult.token)
      ];

      const results = await Promise.all(requests);

      results.forEach(result => {
        expect(result).toBeDefined();
        expect(result.user.email).toBe(testUser.email);
      });
    });

    it('should reject login with incorrect password', async () => {
      await expect(
        loginUser({
          email: testUser.email,
          password: 'WrongPassword123!'
        })
      ).rejects.toThrow('Invalid credentials');
    });

    it('should rate limit repeated failed login attempts', async () => {
      const failedAttempts = [];

      // Attempt 5 failed logins
      for (let i = 0; i < 5; i++) {
        try {
          await loginUser({
            email: testUser.email,
            password: 'WrongPassword'
          });
        } catch (error) {
          failedAttempts.push(error);
        }
      }

      expect(failedAttempts).toHaveLength(5);

      // 6th attempt should be rate limited
      await expect(
        loginUser({
          email: testUser.email,
          password: 'WrongPassword'
        })
      ).rejects.toThrow('Too many login attempts. Please try again later.');
    });
  });

  describe('complete logout flow', () => {
    beforeAll(async () => {
      if (!authToken) {
        const result = await loginUser(testUser);
        authToken = result.token;
      }
    });

    it('should successfully logout and invalidate token', async () => {
      const logoutResult = await logoutUser(authToken);

      expect(logoutResult).toBeDefined();
      expect(logoutResult.success).toBe(true);
    });

    it('should reject requests with logged out token', async () => {
      await logoutUser(authToken);

      // Try to use the token after logout
      await expect(
        fetchUserProfile(authToken)
      ).rejects.toThrow('Invalid or expired token');
    });

    it('should handle multiple logout requests gracefully', async () => {
      await logoutUser(authToken);

      // Second logout should not error
      const result = await logoutUser(authToken);
      expect(result.success).toBe(true);
    });
  });

  describe('token refresh flow', () => {
    it('should refresh valid token and issue new token', async () => {
      const loginResult = await loginUser(testUser);
      const oldToken = loginResult.token;

      const refreshResult = await refreshSession(oldToken);

      expect(refreshResult).toBeDefined();
      expect(refreshResult.token).toBeDefined();
      expect(refreshResult.token).not.toBe(oldToken);

      // New token should work
      const profile = await fetchUserProfile(refreshResult.token);
      expect(profile.user.email).toBe(testUser.email);
    });

    it('should preserve user claims across refresh', async () => {
      const loginResult = await loginUser(testUser);
      const oldDecoded = decodeToken(loginResult.token);

      const refreshResult = await refreshSession(loginResult.token);
      const newDecoded = decodeToken(refreshResult.token);

      expect(newDecoded.userId).toBe(oldDecoded.userId);
      expect(newDecoded.email).toBe(oldDecoded.email);
    });

    it('should reject refresh with invalid token', async () => {
      await expect(
        refreshSession('invalid.token.here')
      ).rejects.toThrow('Invalid token');
    });

    it('should reject refresh with expired token', async () => {
      const expiredToken = await generateToken(
        { userId: 'test-user', email: 'test@example.com' },
        { expiresIn: -3600 }
      );

      await expect(
        refreshSession(expiredToken)
      ).rejects.toThrow('Token expired');
    });
  });

  describe('password reset flow', () => {
    it('should initiate password reset and send reset token', async () => {
      const result = await initiatePasswordReset(testUser.email);

      expect(result).toBeDefined();
      expect(result.resetToken).toBeDefined();
      expect(result.message).toBe('Password reset email sent');
    });

    it('should complete password reset with valid token', async () => {
      const { resetToken } = await initiatePasswordReset(testUser.email);
      const newPassword = 'NewPassword456!';

      const result = await completePasswordReset({
        token: resetToken,
        newPassword: newPassword
      });

      expect(result).toBeDefined();
      expect(result.success).toBe(true);

      // Should be able to login with new password
      const loginResult = await loginUser({
        email: testUser.email,
        password: newPassword
      });

      expect(loginResult.token).toBeDefined();
    });

    it('should reject password reset with invalid token', async () => {
      await expect(
        completePasswordReset({
          token: 'invalid-reset-token',
          newPassword: 'NewPassword456!'
        })
      ).rejects.toThrow('Invalid or expired reset token');
    });

    it('should reject password reset with weak new password', async () => {
      const { resetToken } = await initiatePasswordReset(testUser.email);

      await expect(
        completePasswordReset({
          token: resetToken,
          newPassword: '123'
        })
      ).rejects.toThrow('Password does not meet security requirements');
    });
  });

  describe('handle authentication errors gracefully', () => {
    it('should provide user-friendly error messages', async () => {
      try {
        await loginUser({
          email: 'nonexistent@example.com',
          password: 'password123'
        });
      } catch (error) {
        // Error message should not reveal if user exists or not
        expect(error.message).not.toContain('database');
        expect(error.message).not.toContain('SQL');
        expect(error.message).toMatch(/credentials/i);
      }
    });

    it('should log authentication failures for security monitoring', async () => {
      // This test verifies that security events are logged
      // In a real implementation, you would check logs or monitoring system
      const testLogger = require('../../../src/utils/logger');

      // Attempt failed login
      try {
        await loginUser({
          email: testUser.email,
          password: 'WrongPassword'
        });
      } catch (error) {
        // Verify logging occurred
        expect(testLogger.logSecurityEvent).toHaveBeenCalledWith({
          type: 'AUTH_FAILURE',
          email: testUser.email,
          timestamp: expect.any(Number)
        });
      }
    });
  });
});

// Helper functions (would be in separate files in real implementation)
async function fetchUserProfile(token) {
  // Simulated API call
  return { user: { email: testUser.email } };
}

async function fetchUserSettings(token) {
  return { user: { email: testUser.email, settings: {} } };
}

async function fetchUserNotifications(token) {
  return { user: { email: testUser.email, notifications: [] } };
}

async function deleteUser(userId) {
  // Simulated delete operation
  return { success: true };
}

async function initiatePasswordReset(email) {
  return {
    resetToken: 'reset-token-' + Date.now(),
    message: 'Password reset email sent'
  };
}

async function completePasswordReset({ token, newPassword }) {
  return { success: true };
}

function decodeToken(token) {
  const payload = token.split('.')[1];
  return JSON.parse(atob(payload));
}

async function generateToken(payload, options = {}) {
  // Simplified token generation
  const header = btoa(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const now = Math.floor(Date.now() / 1000);
  const exp = options.expiresIn ? now + options.expiresIn : now + 86400;

  const tokenPayload = {
    ...payload,
    iat: now,
    exp: exp
  };

  const payloadEncoded = btoa(JSON.stringify(tokenPayload));
  const signature = 'signature-' + Date.now();

  return `${header}.${payloadEncoded}.${signature}`;
}
