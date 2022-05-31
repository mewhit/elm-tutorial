import { Module } from '@nestjs/common';
import { ExcerciseSolutionService } from './excercise-solution.service';
import { ExcerciseSolutionResolver } from './excercise-solution.resolver';
import { ElmModule } from '../elm/elm.module';
import {
  ExcerciseSolution,
  ExcerciseSolutionSchema,
} from './schemas/excercise.schema';
import { MongooseModule } from '@nestjs/mongoose';

@Module({
  providers: [ExcerciseSolutionService, ExcerciseSolutionResolver],
  imports: [
    ElmModule,
    MongooseModule.forFeature([
      { name: ExcerciseSolution.name, schema: ExcerciseSolutionSchema },
    ]),
  ],
})
export class ExcerciseSolutionModule {}
