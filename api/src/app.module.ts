import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ElmService } from './elm/elm.service';

@Module({
  imports: [],
  controllers: [AppController],
  providers: [AppService, ElmService],
})
export class AppModule {}
