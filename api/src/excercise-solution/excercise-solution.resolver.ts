import { Parent, ResolveField, Resolver } from '@nestjs/graphql';
import { ExcerciseSolution } from './models/excercise-solution.model';

@Resolver(() => ExcerciseSolution)
export class ExcerciseSolutionResolver {
  @ResolveField(() => ExcerciseSolution)
  student(@Parent() solution: ExcerciseSolution): any {
    return { __typename: 'Student', id: solution.solverId };
  }
}
