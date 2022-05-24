import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { User } from '../user/schemas/user.schema';

export interface AuthPayload {
  user: any;
  access_token: any;
}

@Injectable()
export class AuthService {
  constructor(private readonly jwtService: JwtService) {}

  login(currentUserWithoutPwd: User): AuthPayload {
    const payload = {
      username: currentUserWithoutPwd.username,
      id: currentUserWithoutPwd._id,
    };
    return {
      user: currentUserWithoutPwd,
      access_token: this.jwtService.sign(payload),
    };
  }
}
