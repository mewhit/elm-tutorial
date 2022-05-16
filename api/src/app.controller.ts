import { Body, Controller, Get, Header, Post, Res, StreamableFile, UploadedFile, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { AppService } from './app.service';
import { TestResult } from './elm/test-result.model';
import * as Either from 'fp-ts/Either'

interface Error { error: string }
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) { }

  @Post("excercise-1")
  @UseInterceptors(FileInterceptor(""))
  @Header("content-type", "application/json")
  getHello(@Body() body): Error | readonly TestResult[] {
    const t = Either.fold<string, readonly TestResult[], Error | readonly TestResult[]>(x => ({ error: x }), (x => x))(this.appService.compile(body.code))
    return t;
    // return { result: t }
  }
}
