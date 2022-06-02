import { Strategy } from 'passport-github2';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { UserService } from '../../user/user.service';

@Injectable()
export class GithubStrategy extends PassportStrategy(Strategy) {
  constructor(
    configService: ConfigService,
    private readonly userService: UserService,
  ) {
    const { clientID, clientSecret } = configService.get('githubAuth');
    super({
      clientID,
      clientSecret,
    });
  }

  async validate(_: string, __: string, profile: any): Promise<any> {
    const user = await this.validateUser(profile);
    if (!user) {
      throw new UnauthorizedException();
    }
    return user;
  }

  async validateUser(profile: { id: string; username: string }): Promise<any> {
    if (!profile.id) return null;

    try {
      const user = await this.userService.findByGitHubId(profile.id);
      if (!user) {
        return await this.userService.create({
          githubId: profile.id,
          username: profile.username,
        });
      }
      return user;
    } catch (e) {
      console.log('error', e);
      return null;
    }
  }
}
