import {
  ArgumentsHost,
  CanActivate,
  ExecutionContext,
  Injectable,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Reflector } from '@nestjs/core';
import { GqlContextType, GqlExecutionContext } from '@nestjs/graphql';
import { Observable } from 'rxjs';
import { JwtAuthGuard } from '../../auth/jwt/jwt-auth.guard';
// import { fieldsProjection } from 'graphql-fields-list';

@Injectable()
export class ExcerciseAuthGuard extends JwtAuthGuard implements CanActivate {
  constructor(reflector: Reflector, config: ConfigService) {
    super(reflector, config);
  }
  canActivate(context: ExecutionContext): Promise<boolean> {
    if (context.getType() === 'http') {
      const request = context.switchToHttp().getRequest<Request>();
      const id = +request.url.split('/').slice(-1)[0];
      if (this.validate(id)) return Promise.resolve(true);

      return super.canActivate(context);
      // do something that is only important in the context of Microservice requests
    } else if (context.getType<GqlContextType>() === 'graphql') {
      const ctx = GqlExecutionContext.create(context);
      // do something that is only important in the context of GraphQL requests
      console.log(ctx.getArgs());
      if (this.validate(+ctx.getArgs()?.data?.excerciseId))
        return Promise.resolve(true);

      return super.canActivate(context);
    }
  }

  validate(id: number) {
    if (!Number.isInteger(id)) {
      throw new Error('Something wrong, cannot find the id');
    }
    if (id > 3) {
      return false;
    }
    return true;
  }
}
