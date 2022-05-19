import { Directive, Field, ObjectType } from '@nestjs/graphql';
import { ExcerciseSolution } from 'src/excercise-solution/models/excercise-solution.model';

@ObjectType()
@Directive('@extends')
@Directive('@key(fields: "id")')
export class Student {
  @Field()
  @Directive('@external')
  id: string;

  @Field()
  firstName: string;

  @Field()
  lastName: string;

  @Field()
  nickName: string;

  @Field()
  email: string;

  @Field(() => [ExcerciseSolution])
  completedExcercise: ExcerciseSolution[];
}
