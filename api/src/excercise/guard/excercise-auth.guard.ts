import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { Observable } from 'rxjs';

@Injectable()
export class ExcerciseAuthGuard implements CanActivate {
  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    const request = context.switchToHttp().getRequest<Request>();
    const id = +request.url.split('/').slice(-1)[0];
    if (!Number.isInteger(id)) {
      throw new Error('Something wrong, cannot find the id');
    }
    if (id > 3) {
      return false;
    }

    console.log('here');
    return true;
  }
}
