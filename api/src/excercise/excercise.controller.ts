import { Body, Controller, Header, Param, Post, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import * as Either from 'fp-ts/Either'

import { TestResult } from '../elm/test-result.model';
import { ExcerciseService } from './excercise.service';

interface Error { error: string }

@Controller('excercise')
export class ExcerciseController {

    constructor(private appService: ExcerciseService) { }

    @Post(":id")
    @UseInterceptors(FileInterceptor(""))
    @Header("content-type", "application/json")
    getHello(@Param("id") id, @Body() body): Error | readonly TestResult[] {
        return Either.fold<string, readonly TestResult[], Error | readonly TestResult[]>(x => ({ error: x }), (x => x))(this.appService.compile(id, body.code))
    }
}
