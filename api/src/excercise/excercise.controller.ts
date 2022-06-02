import {
  Body,
  Controller,
  Header,
  Param,
  Post,
  Req,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import * as Either from 'fp-ts/Either';
import { JwtAuthGuard } from '../auth/jwt/jwt-auth.guard';

import { CompileResult } from '../elm/test-result.model';
import { ExcerciseService } from './excercise.service';
import { ExcerciseAuthGuard } from './guard/excercise-auth.guard';

interface Error {
  error: string;
}

@UseGuards(JwtAuthGuard || ExcerciseAuthGuard)
@Controller('excercise')
export class ExcerciseController {
  constructor(private excerciseService: ExcerciseService) {}

  @Post(':id')
  @UseInterceptors(FileInterceptor(''))
  @Header('content-type', 'application/json')
  run(
    @Param('id') id: string,
    @Body() body: { code: string },
  ): Error | readonly CompileResult[] {
    return Either.fold<
      string,
      readonly CompileResult[],
      Error | readonly CompileResult[]
    >(
      (x) => ({ error: x }),
      (x) => x,
    )(this.excerciseService.compile(id, body.code));
  }
}
