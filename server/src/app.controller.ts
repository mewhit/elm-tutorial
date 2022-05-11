import { Body, Controller, Get, Header, Post, Res, StreamableFile, UploadedFile, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { execSync } from 'child_process';
import { Response } from 'express';
import * as fs from 'fs';
import * as path from 'path';
import { Readable, Stream } from 'stream';
import { AppService } from './app.service';


@Controller()
export class AppController {
  constructor(private readonly appService: AppService) { }

  @Post("excercise-1")
  @UseInterceptors(FileInterceptor(""))
  @Header("Content-Type", "text/html")
  async getHello(@Body() body, @Res() response: Response): Promise<void> {

    const [dirPath, filePath] = await this.appService.compile(body.code);
    const file = fs.createReadStream(filePath)

    const resp = file.pipe(response)

    resp.on("finish", () => {
      fs.rmdirSync(`${dirPath}`, { recursive: true })
    })
  }
}
