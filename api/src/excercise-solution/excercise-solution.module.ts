import { Module } from '@nestjs/common';
import { ExcerciseSolutionService } from './excercise-solution.service';
import { ExcerciseSolutionResolver } from './excercise-solution.resolver';

@Module({
  providers: [ExcerciseSolutionService, ExcerciseSolutionResolver]
})
export class ExcerciseSolutionModule {}
