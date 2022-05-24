import { Controller, Get, Query, Req, Res, UseGuards } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AuthService } from './auth.service';
import { GithubAuthGuard } from './github/github-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly configService: ConfigService,
  ) {}

  @UseGuards(GithubAuthGuard)
  @Get('/github')
  async githubAuth() {
    return '<p> loading </p>';
  }

  @UseGuards(GithubAuthGuard)
  @Get('/github/callback')
  async githubAuthCallback(@Req() req: any, @Res() res: any) {
    const { access_token } = this.authService.login((req as any).user);
    res.redirect(
      `${this.configService.get('callbackURL')}?access_token=${access_token}`,
    );
  }
}
