import { Directive, Field, Int, ObjectType } from '@nestjs/graphql';
import { Student } from 'src/student/models/student.model';
import { CompileResult } from '../../elm/test-result.model';
import { Excercise } from '../../excercise/models/excercise.model';

@ObjectType()
@Directive('@key(fields: "id")')
export class ExcerciseSolution {
  @Field(Int)
  id: number;

  @Field()
  code: string;

  @Field(() => Excercise)
  excercise: string;

  @Field()
  solverId: string;

  @Field(() => Student)
  student: Student;

  @Field(() => [CompileResult])
  results: CompileResult[];
}
