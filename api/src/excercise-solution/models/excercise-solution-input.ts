import { Field, InputType } from '@nestjs/graphql';

@InputType()
export class ExcerciseSolutionInput {
  @Field()
  excerciseId: string;

  @Field()
  code: string;
}
