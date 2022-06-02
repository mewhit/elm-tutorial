import {
  Args,
  Query,
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
import { UseGuards } from '@nestjs/common';
import { Err } from '../libs/Err';
import { ExcerciseAuthGuard } from '../excercise/guard/excercise-auth.guard';
import { JwtAuthGuard } from '../auth/jwt/jwt-auth.guard';
import { User } from '../libs/UserDecorator';

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

  @UseGuards(JwtAuthGuard)
  @Query(() => [ExcerciseSolution])
  async solutionByStudentId(@User() user: any) {
    if (user) return this.excerciseSolutionService.getAllByUserId(user.id);

    return [];
  }

  @UseGuards(ExcerciseAuthGuard)
  @Mutation(() => ExcerciseSolutionResult, { name: 'compile' })
  async compile(
    @Args('data') excercise: ExcerciseSolutionInput,
    @User() user: any,
  ) {
    const result = await this.excerciseSolutionService.compile({
      ...excercise,
      userId: user?.id,
    });

    return Either.fold(
      (x: string) => ({
        err: x,
      }),
      (x) => x,
    )(result);
  }

  @ResolveField(() => ExcerciseSolution)
  student(@Parent() solution: ExcerciseSolution): any {
    return { __typename: 'Student', id: solution.userId };
  }
}
