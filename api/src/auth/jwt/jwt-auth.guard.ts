import {
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Reflector } from '@nestjs/core';
import { ExecutionContextHost } from '@nestjs/core/helpers/execution-context-host';
import { GqlExecutionContext } from '@nestjs/graphql';
import { AuthGuard } from '@nestjs/passport';
import { Observable } from 'rxjs';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(
    private reflector: Reflector,
    private readonly config: ConfigService,
  ) {
    super();
  }
  handleRequest(err: any, user: any, info: any) {
    // You can throw an exception based on either "info" or "err" arguments
    if (err || !user) {
      throw err || new UnauthorizedException();
    }
    return user;
  }

  async canActivate(ctx: ExecutionContext) {
    const context = GqlExecutionContext.create(ctx);
    const isPublic = this.reflector.getAllAndOverride<boolean>(
      this.config.get<string>('jwt.secret'),
      [context.getHandler(), context.getClass()],
    );

    if (isPublic) {
      return true;
    }
    const { req } = context.getContext();
    try {
      await super.canActivate(new ExecutionContextHost([req])); // NOTE
      return true;
    } catch (err) {
      if (err?.status === 401) {
        return false;
      }
      throw err;
    }
  }
}
