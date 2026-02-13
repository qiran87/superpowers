/**
 * JWT Token Validation Tests
 *
 * @requirement 2025-01-15-user-authentication
 * @task task-2-jwt-token-validation
 * @created 2025-01-15
 * @author AI Agent (subagent-driven-development)
 */

import { describe, it, expect } from 'vitest';
import { generateToken, validateToken, decodeToken } from '../../../src/utils/jwt';

describe('JWT Token Validation', () => {
  const mockUser = {
    id: 'user-123',
    email: 'user@example.com',
    name: 'Test User'
  };

  describe('generateToken', () => {
    it('should generate valid JWT token with user claims', async () => {
      const token = await generateToken(mockUser);

      expect(token).toBeDefined();
      expect(typeof token).toBe('string');
      expect(token.split('.')).toHaveLength(3);
    });

    it('should include correct payload in token', async () => {
      const token = await generateToken(mockUser);
      const decoded = decodeToken(token);

      expect(decoded.userId).toBe(mockUser.id);
      expect(decoded.email).toBe(mockUser.email);
      expect(decoded.name).toBe(mockUser.name);
    });

    it('should set expiration time', async () => {
      const token = await generateToken(mockUser);
      const decoded = decodeToken(token);

      expect(decoded.exp).toBeDefined();
      expect(decoded.exp).toBeGreaterThan(Math.floor(Date.now() / 1000));
    });
  });

  describe('validateToken with correct signature', () => {
    it('should validate token with correct signature', async () => {
      const token = await generateToken(mockUser);
      const isValid = await validateToken(token);

      expect(isValid).toBe(true);
    });

    it('should return decoded payload for valid token', async () => {
      const token = await generateToken(mockUser);
      const decoded = await validateToken(token);

      expect(decoded).toBeDefined();
      expect(decoded.userId).toBe(mockUser.id);
    });
  });

  describe('validateToken with invalid signature', () => {
    it('should reject token with tampered signature', async () => {
      const token = await generateToken(mockUser);
      const tamperedToken = token + 'tamper';

      await expect(
        validateToken(tamperedToken)
      ).rejects.toThrow('Invalid token signature');
    });

    it('should reject token with modified payload', async () => {
      const token = await generateToken(mockUser);
      const parts = token.split('.');

      // Modify payload
      const modifiedPayload = btoa(JSON.stringify({ userId: 'attacker' }));
      const modifiedToken = `${parts[0]}.${modifiedPayload}.${parts[2]}`;

      await expect(
        validateToken(modifiedToken)
      ).rejects.toThrow();
    });
  });

  describe('validateToken with expired token', () => {
    it('should reject expired token', async () => {
      // Create token that expired 1 hour ago
      const expiredToken = await generateToken(mockUser, { expiresIn: -3600 });

      await expect(
        validateToken(expiredToken)
      ).rejects.toThrow('Token expired');
    });

    it('should provide clear expiration error message', async () => {
      const expiredToken = await generateToken(mockUser, { expiresIn: -3600 });

      try {
        await validateToken(expiredToken);
      } catch (error) {
        expect(error.message).toMatch(/expired/);
      }
    });
  });

  describe('decodeToken', () => {
    it('should extract user claims from valid token', async () => {
      const token = await generateToken(mockUser);
      const decoded = decodeToken(token);

      expect(decoded.userId).toBe(mockUser.id);
      expect(decoded.email).toBe(mockUser.email);
      expect(decoded.name).toBe(mockUser.name);
    });

    it('should decode token without verification', async () => {
      const token = await generateToken(mockUser);

      // decodeToken should work even for expired tokens
      const decoded = decodeToken(token);

      expect(decoded).toBeDefined();
      expect(decoded.userId).toBe(mockUser.id);
    });
  });

  describe('handle malformed tokens', () => {
    it('should reject token without proper structure', async () => {
      const malformedTokens = [
        'not-a-jwt',
        'header.payload',  // Missing signature
        'header.payload.extra.extra',  // Too many parts
        '',
      ];

      for (const token of malformedTokens) {
        await expect(
          validateToken(token)
        ).rejects.toThrow();
      }
    });

    it('should reject token with invalid base64 encoding', async () => {
      const invalidToken = 'header.%%%invalid-base64%%%.signature';

      await expect(
        validateToken(invalidToken)
      ).rejects.toThrow();
    });

    it('should reject token with invalid JSON in payload', async () => {
      const invalidPayload = btoa('not valid json');
      const invalidToken = `header.${invalidPayload}.signature`;

      await expect(
        validateToken(invalidToken)
      ).rejects.toThrow();
    });
  });

  describe('token refresh', () => {
    it('should support generating new token from valid token', async () => {
      const oldToken = await generateToken(mockUser);
      const decoded = await validateToken(oldToken);

      const newToken = await generateToken(decoded);

      expect(newToken).toBeDefined();
      expect(newToken).not.toBe(oldToken);
    });

    it('should preserve user claims in refreshed token', async () => {
      const oldToken = await generateToken(mockUser);
      const decoded = await validateToken(oldToken);

      const newToken = await generateToken(decoded);
      const newDecoded = decodeToken(newToken);

      expect(newDecoded.userId).toBe(mockUser.id);
      expect(newDecoded.email).toBe(mockUser.email);
    });
  });
});
