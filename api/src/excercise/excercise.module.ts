import { Module } from '@nestjs/common';
import { ElmModule } from '../elm/elm.module';
import { ExcerciseController } from './excercise.controller';
import { ExcerciseService } from './excercise.service';

@Module({
  controllers: [ExcerciseController],
  providers: [ExcerciseService],
  imports: [ElmModule],
})
export class ExcerciseModule {}
