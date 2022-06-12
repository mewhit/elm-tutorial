import { Module } from '@nestjs/common';
import { ElmModule } from '../elm/elm.module';

@Module({
  controllers: [],
  providers: [],
  imports: [ElmModule],
})
export class ExcerciseModule {}
