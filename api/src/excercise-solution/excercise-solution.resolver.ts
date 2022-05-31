import {
  Args,
  createUnionType,
  Mutation,
  Parent,
  ResolveField,
  Resolver,
} from '@nestjs/graphql';
import { ExcerciseSolutionService } from './excercise-solution.service';
import { ExcerciseSolutionInput } from './models/excercise-solution-input';
import { ExcerciseSolution } from './models/excercise-solution.model';
import * as Either from 'fp-ts/Either';
import { Req } from '@nestjs/common';
import { Err } from '../libs/Err';

export const ExcerciseSolutionResult = createUnionType({
  name: 'ExcerciseSolutionResult',
  types: () => [Err, ExcerciseSolution] as const,
  resolveType(value) {
    if (value.err) {
      return Err;
    }

    return ExcerciseSolution;
  },
});
@Resolver(() => ExcerciseSolution)
export class ExcerciseSolutionResolver {
  constructor(
    private readonly excerciseSolutionService: ExcerciseSolutionService,
  ) {}

  @Mutation(() => ExcerciseSolutionResult, { name: 'compile' })
  async compile(
    @Args('data') excercise: ExcerciseSolutionInput,
    @Req() req: any,
  ) {
    const user = req?.user;

    return Either.fold(
      (x: string) => ({
        err: x,
      }),
      (x) => x,
    )(
      await this.excerciseSolutionService.compile({
        ...excercise,
        userId: user?.id,
      }),
    );
  }

  @ResolveField(() => ExcerciseSolution)
  student(@Parent() solution: ExcerciseSolution): any {
    return { __typename: 'Student', id: solution.solverId };
  }
}
